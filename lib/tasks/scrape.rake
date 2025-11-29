# lib/tasks/scrape.rake

require "nokogiri"
require "open-uri"

namespace :scrape do
  desc "Scrape demo products and categories"
  task products: :environment do
    puts "Starting scraping demo products..."

    # Example: Use a local HTML file as the source
    file_path = Rails.root.join("lib", "assets", "demo_products.html")
    unless File.exist?(file_path)
      puts "Demo file not found at #{file_path}"
      puts "Please create 'lib/assets/demo_products.html' with sample product HTML"
      next
    end

    html = File.read(file_path)
    doc = Nokogiri::HTML(html)

    doc.css(".product-item").each do |item|
      category_name = item.at_css(".category").text.strip
      product_name = item.at_css(".name").text.strip
      description  = item.at_css(".description").text.strip
      price        = item.at_css(".price").text.gsub(/[^0-9\.]/, "").to_f

      # Create or find category
      category = Category.find_or_create_by!(name: category_name) do |c|
        c.description = "#{category_name} clothing products"
      end

      # Create product
      product = Product.create!(
        name: product_name,
        description: description,
        price: price,
        stock_quantity: rand(5..50),
        sku: SecureRandom.alphanumeric(8).upcase,
        category: category,
        on_sale: [ true, false ].sample
      )

      puts "Created product: #{product.name} (#{category.name})"
    end

    puts "Scraping complete! Total products: #{Product.count}"
  end
end
