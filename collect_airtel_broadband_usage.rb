require 'rubygems'
require 'nokogiri'
require 'open-uri'
require "pathname"
require "csv"

class CollectBroadbandUsage

  URL = "http://122.160.230.125:8080/gbod/gb_on_demand.do"

  class SaveUsage
    OUTFILE = "broadband_usage.csv"
    OUT_PATH = "/Users/kaushik/#{OUTFILE}"

    def write_to_file(kvs)
      CSV.open(OUT_PATH, "ab") do |csv|
        kvs.each_with_index do |row, idx|
          csv << row.keys if idx == 0 and File.zero?(OUT_PATH)
          csv << row.values
        end
      end
    end
  end

  def find_usage
    page = Nokogiri::HTML(open(URL))
    time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    usage_info = page.css("li").each_with_object([]) do |e,res|
      res << e.text if passes_criteria?(e.text)
    end
    extract(usage_info).merge('Time' => time)
  end

  def capture_usage_to_file()
    SaveUsage.new.write_to_file([find_usage])
  end

  def passes_criteria?(ele)
    ele.downcase.include?('balance') or ele.downcase.include?('days left')
  end

  def extract(usage_info)
    p usage_info
    usage_info.inject({}) do |res,e|
      arr = e.split(':').collect{|e| e.strip}
      res.merge({arr[0] => arr[1]})
    end
  end


end

p CollectBroadbandUsage.new.capture_usage_to_file