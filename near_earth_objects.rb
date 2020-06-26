require 'faraday'
require 'figaro'
require 'pry'
require 'json'
# Load ENV vars via Figaro
Figaro.application = Figaro::Application.new(environment: 'production', path: File.expand_path('../config/application.yml', __FILE__))
Figaro.load

class NearEarthObjects
  def self.find_neos_by_date(date)
    asteroids_data = get_json('/neo/rest/v1/feed')[:"#{date}"]

    formatted_asteroid_data = asteroids_data.map do |asteroid|
      {
        name: asteroid[:name],
        diameter: "#{asteroid[:estimated_diameter][:feet][:estimated_diameter_max].to_i} ft",
        miss_distance: "#{asteroid[:close_approach_data][0][:miss_distance][:miles].to_i} miles"
      }
    end

    {
      asteroid_list: formatted_asteroid_data,
      biggest_asteroid: largest_asteroid_diameter(asteroids_data),
      total_number_of_asteroids: asteroids_data.count
    }
  end

  private

  def largest_astroid_diameter(asteroids_data)
    asteroids_data.map do |asteroid|
      asteroid[:estimated_diameter][:feet][:estimated_diameter_max].to_i
    end.max { |a,b| a<=> b}
  end

  def conn()
    Faraday.new(
      url: 'https://api.nasa.gov',
      params: {
        start_date: date,
        api_key: ENV['nasa_api_key']
      }
    )
  end

  def self.get_json(path)
    json = conn.get(path)
    JSON.parse(json.body, symbolize_names: true)[:near_earth_objects]
  end
end
