require 'rubygems'
require 'mechanize'

request_delay_seconds = 5

http = Mechanize.new

players = []
skipped_first_line = false
IO.readlines( 'players.csv' ).each do |line|
  if !skipped_first_line
    skipped_first_line = true
    next
  end

  items = line.split ','
  next if items.length != 2
  players.push( { :name => items[0].strip, :href => items[1].strip } )
end

File.open( 'points.csv', 'w' ) do |file|
  file.puts 'name,url,points,bonus,wins,losses'
  players.each_with_index do |player, index|
    puts 'Requesting player ' + ( index + 1 ).to_s + ' of ' + players.length.to_s + ' ' + player[:name]

    bnet_url = ''
    m = player[:href].match '/([^/]*)/([^/]*)/([^/]*)'
    if m[1] == 'us'
      bnet_url = 'http://us.battle.net/sc2/en/profile/' + m[2] + '/1/' + m[3] + '/ladder/leagues'
    elsif m[1] == 'la'
      bnet_url = 'http://us.battle.net/sc2/en/profile/' + m[2] + '/2/' + m[3] + '/ladder/leagues'
    end

    begin
      http.get( bnet_url ) do |page|
        row = page.search( '#current-rank td' )

        first_number = 0
        row.each do |cell|
          break if cell.text.strip.match( '^[0-9]+$' )
          first_number += 1
        end

        points = row[first_number].text.strip
        wins = row[first_number+1].text.strip
        losses = row[first_number+2].text.strip
        bonus = page.search( '#bonus-pool span' )[0].text.strip

        file.puts player[:name] + ',' + bnet_url + ',' + points + ',' + bonus + ',' + wins + ',' + losses
      end
    rescue => error
      puts error
    end

    sleep request_delay_seconds
  end
end
