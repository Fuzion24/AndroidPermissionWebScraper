require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'csv'

class AndroidPermissionScraper
	def self.scrape_all_the_permissions
		permissions = {}
		url = "http://developer.android.com/reference/android/Manifest.permission.html"
		doc = Nokogiri::HTML(open(URI.escape(url)))
		doc.css("div.jd-details").each do |details_block|
			title = details_block.css("h4.jd-details-title")
			title.css("span").each { |sp| sp.remove}
			perm_name =  title.text.gsub(" ", "").gsub("\n","")
			api_level = details_block.css("div.api-level a").text.gsub("API Level ", "")
			description = details_block.css("div.jd-details-descr div.jd-tagdescr").text.gsub("\n", "").gsub("  ", " ")
			break if details_block.css("div.jd-details-descr div.jd-tagdata span")[1].nil?
			permission_string = details_block.css("div.jd-details-descr div.jd-tagdata span")[1].text.gsub("\"", "").gsub("\n","").gsub(" ","")
			permissions[perm_name] = {
										:api_level => api_level,
										:description => description,
										:permission => permission_string
										}
		end
		permissions
	end
	def self.export_to_csv(filename)

		CSV.open(filename, "wb") do |csv|
		  perms = AndroidPermissionScraper.scrape_all_the_permissions
		  perms.each do |k,v|
		  	csv << [k, v[:permission], v[:description], v[:api_level] ]
		  end
		end
	end

	def AndroidPermissionScraper.print
		AndroidPermissionScraper.scrape_all_the_permissions.each do |k,v|
			puts "#{k}"
			puts "\tPermission: #{v[:permission]}"
			puts "\tApi Level: #{v[:api_level]}"
			puts "\tDescription: #{v[:description]}"
		end
	end
end

AndroidPermissionScraper.print

#AndroidPermissionScraper.export_to_csv("perms.csv")