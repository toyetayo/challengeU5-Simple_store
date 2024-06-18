# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb

require 'csv'

# Clear existing data
Product.destroy_all
Category.destroy_all

# Load CSV file
csv_file = Rails.root.join('db/products.csv')
csv_data = File.read(csv_file)

# Parse CSV data
products = CSV.parse(csv_data, headers: true)

products.each do |row|
  begin
    # Extract category name from the row
    category_name = row['category']

    # Find or create the category by name
    category = Category.find_or_create_by!(name: category_name)

    # Ensure required fields are present and valid
    next unless row['title'].present? && row['stock_quantity'].present? && row['stock_quantity'].to_i.to_s == row['stock_quantity']

    # Create a new product associated with the category
    Product.create!(
      title: row['title'],
      description: row['description'],
      price: row['price'],
      stock_quantity: row['stock_quantity'],
      category: category
    )
  rescue ActiveRecord::RecordInvalid => e
    puts "Failed to create product: #{row['title']}. Error: #{e.message}"
  rescue => e
    puts "Unexpected error for product: #{row['title']}. Error: #{e.message}"
  end
end

puts "Loaded products from CSV"
