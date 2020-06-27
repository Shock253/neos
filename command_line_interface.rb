require_relative 'near_earth_objects'

class CommandLineInterface
  def self.start
    puts "________________________________________________________________________________________________________________________________"
    puts "Welcome to NEO. Here you will find information about how many meteors, asteroids, comets pass by the earth every day. \nEnter a date below to get a list of the objects that have passed by the earth on that day."
    puts "Please enter a date in the following format YYYY-MM-DD."
    print ">>"

    date = gets.chomp
    asteroid_details = NearEarthObjects.find_neos_by_date(date)

    column_data = get_column_data(asteroid_details)
    puts "______________________________________________________________________________"
    puts "On #{format_date(date)}, there were #{total_number_of_asteroids(asteroid_details)} objects that almost collided with the earth."
    puts "The largest of these was #{largest_asteroid(asteroid_details)} ft. in diameter."
    puts "\nHere is a list of objects with details:"
    puts divider(column_data)
    puts header(column_data)
    create_rows(asteroid_details)
    puts divider(column_data)
  end
  
  private

  def self.format_row_data(row_data, column_info)
    row = row_data.keys.map { |key| row_data[key].ljust(column_info[key][:width]) }.join(' | ')
    puts "| #{row} |"
  end

  def self.create_rows(asteroid_details)
    column_data = get_column_data(asteroid_details)
    asteroid_details[:asteroid_list].each do |asteroid|
      format_row_data(asteroid, column_data)
    end
  end

  def self.get_column_data(asteroid_details)
    column_labels = {
      name: "Name",
      diameter: "Diameter",
      miss_distance: "Missed The Earth By:"
    }
    column_labels.each_with_object({}) do |(col, label), hash|
      hash[col] = {
        label: label,
        width: [asteroid_details[:asteroid_list].map { |asteroid| asteroid[col].size }.max, label.size].max}
    end
  end

  def self.format_date(date)
    DateTime.parse(date).strftime("%A %b %d, %Y")
  end

  def self.total_number_of_asteroids(asteroid_details)
    asteroid_details[:total_number_of_asteroids]
  end

  def self.largest_asteroid(asteroid_details)
    asteroid_details[:biggest_asteroid]
  end

  def self.header(column_data)
    "| #{ column_data.map { |_,col| col[:label].ljust(col[:width]) }.join(' | ') } |"
  end

  def self.divider(column_data)
    "+-#{column_data.map { |_,col| "-"*col[:width] }.join('-+-') }-+"
  end
end
