require 'geoip'
require 'useragent'

class Shortener::ShortenedClick < ActiveRecord::Base
  belongs_to :shortened_url

  GeoIPDataPath = File.absolute_path File.join(__FILE__, "../../../../config")

  def track env
    # logger.info(env)

    self.remote_ip = (env["HTTP_X_FORWARDED_FOR"].to_s.split(',').first.try(:strip) || env["REMOTE_ADDR"]).to_s
    self.referer = env["HTTP_REFERER"].to_s.dup.force_encoding("ISO-8859-1").force_encoding("utf-8")
    self.agent = env["HTTP_USER_AGENT"].to_s.dup.force_encoding("ISO-8859-1").force_encoding("utf-8")
    begin
      self.country = geo_ip.country(self.remote_ip).country_name.to_s
    rescue SocketError => e
      self.country = ''
    end  
    self.browser = user_agent.browser.to_s
    self.platform = user_agent.platform.to_s
  end

  def user_agent
    @user_agent ||= UserAgent.parse(self.agent)
  end

  def geo_ip
    @geo_ip ||= GeoIP.new(File.join(GeoIPDataPath, 'GeoIP.dat'))
  end

  def geo_lite_city
    @geo_ip ||= GeoIP.new(File.join(GeoIPDataPath, 'GeoLiteCity.dat'))
  end
end
