# ruby-buxus-client
# Copyright (c) 2012 by Martin Riesz
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'mechanize'

class Buxus

  BASE_URL = "https://www.example.com"
  
  def initialize
    @agent = WWW::Mechanize.new do |agent|
      agent.ca_file = File.join(File.dirname(__FILE__), "cert.pem")
      agent.follow_meta_refresh = true
      agent.keep_alive = false
    end
  end

  def login(login, password)
    @agent.get(BASE_URL + "/system/login.php") do |page|
      page.form_with(:name => "login_form") do |form|
	form.login = login
	form.password = password
      end.submit
    end
    self
  end
  
  def update_page(page_id, title, html)
    @agent.get(BASE_URL + "/system/page_details.php?page_id=#{page_id}") do |page|
      page.form_with(:name => "page_details") do |form|
	form["property[1]"]  = "Generovane_#{title}" # "Nazov"
	form["property[12]"] = title # "Title"
	form["property[13]"] = title # "Skrateny nazov" (menu)
	second_textarea_name = page.search("/html/body/table[@id='layouttable']/tr[2]/td[@id='mainbodytd']/table/tr/td/form[@id='page_details']/table[2]/tr[td[1]/div/div[1]='Text:']/td/textarea")[0]["name"]
	form[second_textarea_name] = html   # "Text"
      end.submit
    end
    self
  end

  def clear_archive(page_id, num_to_keep = 0)
    @agent.get(BASE_URL + "/lib/archive/uif/page_history.php?page_id=#{page_id}") do |page|
      page.form_with(:name => "page_history") do |form|
	form.checkboxes_with(:name => "selected_items[]")[num_to_keep..-1].each do |checkbox|
	  checkbox.check
	end rescue nil #nil.each
      end.submit
    end
    self
  rescue URI::InvalidURIError
    self
  end

  def get_content_types(parent_page_id)
    page = @agent.get(BASE_URL + "/system/page_details.php?page_id=#{parent_page_id}")
    content_types = []
    page.search("/html/body/table[@id='layouttable']/tr[2]/td[1]/table[@id='leftmenutable']/tr/td/table[@id='mainmenutable']/tr[2]/td/table[@id='contextmenutable']/tr/td[@class='yellow-menu']/a").each do |a|
      if a.content =~ /^Vložiť /
	content_types << a["href"].sub(/^page_details.php.parent_page_id=\d+&show_type=insert&page_type_id=(\d+).*$/, '\1').to_i
      end
    end
    content_types
  end

  def create_page(parent_page_id, content_type = get_content_types(parent_page_id).min)
    page = @agent.get(BASE_URL + "/system/page_details.php?parent_page_id=#{parent_page_id}&show_type=insert&page_type_id=#{content_type}")
    page_details = page.form_with(:name => "page_details") do |form|
      form["property[1]"] = "empty"
    end.submit
    page_id = page_details.search("/html/body/table[@id='layouttable']/tr[2]/td[@id='mainbodytd']/table/tr/td/form[@id='page_details']/table[1]/tr[td[1]/span='ID:']/td[2]")[0].content.to_i
  end

  def delete_page(page_id)
    @agent.get(BASE_URL + "/system/delete_confirmation.php?page_id=#{page_id}") do |page|
      page.form_with(:name => "delete_confirmation") do |form| 
      end.click_button
    end
    self
  rescue WWW::Mechanize::ResponseCodeError
    self
  end

  def set_page_active(page_id, active = true)
    @agent.get(BASE_URL + "/system/page_details.php?page_id=#{page_id}") do |page|
      page.form_with(:name => "page_details") do |form|
	if active
	  form["property[9]"] = 1
	else
	  form["property[9]"] = 2
	end
      end.submit
    end
    self
  end
  
  def agent
    @agent
  end
  
end