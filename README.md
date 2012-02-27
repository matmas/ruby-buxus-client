ruby-buxus-client
=================

It is a [Buxus CMS](http://www.ui42.sk/cms-buxus.html) client library written in Ruby.

*configuration:* change `BASE_URL` to point to your Buxus URL and name your SSL certificate file as `cert.pem`.

*Example usage:*

    buxus = Buxus.new.login("yourusername", "yourpassword")
    buxus.create_page(page_id)
    buxus.update_page(page_id, page_title, html) # updates page contents
    buxus.set_page_active(page_id, true)         # makes page public
    buxus.clear_archive(page_id, 10)             # purge old page history, maintains 10 latest versions
    buxus.delete_page(page_id)                   # deletes page

Tested with Buxus 5.5.7, Mechanize 0.9.3, Ruby 1.8

Code license: [GPLv3](http://www.gnu.org/licenses/gpl.html)
