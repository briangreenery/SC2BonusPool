require 'rubygems'
require 'mechanize'

request_delay_seconds = 15

http = Mechanize.new

puts 'Requesting divisions'
divisions = []
http.get( 'http://sc2ranks.com/div/am/master/1/points/0' ) do |page|
  page.search( 'td.division a' ).each do |link|
    divisions.push link['href']
  end
end

players = []
divisions.each_with_index do |division, index|

  sleep request_delay_seconds
  puts 'Requesting division ' + ( index + 1 ).to_s + ' of ' + divisions.length.to_s + ' ' + division

  http.get( 'http://sc2ranks.com' + division ) do |page|
    page.search( 'td.character a' ).each do |link|
      players.push( { :name => link.text, :href => link['href'] } )
    end
  end
end

players.sort! { |a,b| a[:name].downcase <=> b[:name].downcase }

File.open( 'players.csv', 'w' ) do |file|
  file.puts 'name,sc2ranks_url'
  players.each do |player|
    file.puts player[:name] + ',' + player[:href]
  end
end