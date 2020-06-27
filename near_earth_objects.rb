require 'faraday'
require 'figaro'
require 'pry'
require 'json'
# Load ENV vars via Figaro
Figaro.application = Figaro::Application.new(environment: 'production', path: File.expand_path('../config/application.yml', __FILE__))
Figaro.load

class NearEarthObjects
  def self.find_neos_by_date(date)
    asteroid_data = get_json('/neo/rest/v1/feed', date)[:"#{date}"]

    {
      asteroid_list: format_asteroid_data(asteroid_data),
      biggest_asteroid: largest_asteroid_diameter(asteroid_data),
      total_number_of_asteroids: asteroid_data.count
    }
  end

  private

  def self.format_asteroid_data(asteroid_data)
    asteroid_data.map do |asteroid|
      {
        name: asteroid[:name],
        diameter: "#{asteroid[:estimated_diameter][:feet][:estimated_diameter_max].to_i} ft",
        miss_distance: "#{asteroid[:close_approach_data][0][:miss_distance][:miles].to_i} miles"
      }
    end
  end

  def self.largest_asteroid_diameter(asteroid_data)
    asteroid_data.map do |asteroid|
      asteroid[:estimated_diameter][:feet][:estimated_diameter_max].to_i
    end.max { |a,b| a<=> b}
  end

  def self.conn(date)
    Faraday.new(
      url: 'https://api.nasa.gov',
      params: {
        start_date: date,
        api_key: ENV['nasa_api_key']
      }
    )
  end

  def self.get_json(path, date)
    json = conn(date).get(path)
    JSON.parse(json.body, symbolize_names: true)[:near_earth_objects]
  end
end
