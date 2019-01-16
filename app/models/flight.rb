class Flight

  def self.init
    basic('ES','MAD','Anywhere','2019-05-17','2019-05-19')
  end

  def self.basic(country, origin, destination, departure, back)
    conn = Faraday.new(url: 'http://partners.api.skyscanner.net/apiservices/browseroutes/v1.0')

    resp = conn.get mount(country, origin, destination, departure, back), {apikey: ENV['API_KEY']}


    parsed = JSON.parse(resp.body)

    @places = parsed['Places']
    parsed['Routes']
  end

  def self.five_cheapest
    clean_empty_prices(init).min_by(5) { |k,v| k }
  end

  def self.weekend_with_buddies(origins, departure, back)
    chances = []
    origins.each do |origin|
      routes = basic(origin[0], origin[1], 'Anywhere', departure, back)
      chances << clean_empty_prices(routes)
    end
    merged = merge(chances)
    chances

    common = chances.first.values & chances.second.values

    results = get_cheapest(common, chances)
    results.each do |result|
      @places.each do |place|
        next unless place['PlaceId'] === result[3]
        result[3] = place['Name']
      end
    end
    results
  end

  def self.foo
    weekend_with_buddies([['ES','MAD'],['DE','MUC']],'2019-05-17','2019-05-19')
  end

  private

    def self.get_cheapest(common, chances)
      destinies = []
      common.each do |x|
        destinies << [chances.first.key(x) + chances.second.key(x), chances.first.key(x), chances.second.key(x), place_of(x)]
      end

      destinies.sort_by{ |elem| elem[0] }
    end

    def self.place_of(x)
      x
    end

    def self.merge(chances)
      chances
    end

    def self.clean_empty_prices(routes)
      hashed = {}
      routes.each do |route|
        next unless route.flatten.include?('Price')
        hashed[route['Price']] = route['DestinationId']
      end
      hashed
    end


    def self.mount(country, origin, destination, departure, back)
      "#{country}/eur/es-ES/#{origin}/#{destination}/#{departure}/#{back}"
    end
end




#date Format “yyyy-mm-dd”, “yyyy-mm” or “anytime”
# 'FR/eur/en-US/uk/us/anytime/anytime'

#Flight.basic('ES','MAD','Anywhere','2019-05-17','2019-05-19')
