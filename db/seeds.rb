# db/seeds.rb

require 'faker'

# --- Admin user ---
# Avoid duplicates
AdminUser.find_or_create_by!(email: 'admin@example.com') do |admin|
  admin.password = 'password'
  admin.password_confirmation = 'password'
end if Rails.env.development?

# --- Categories ---
categories = [ 'Cotton', 'Mulberry Silk', 'Wool', 'Cashmere', 'Blended' ]
categories.each do |name|
  Category.find_or_create_by!(
    name: name,
    description: "#{name} clothing products"
  )
end

# --- Product types ---
types = [ "T-Shirt", "Blouse", "Dress", "Sweater", "Scarf", "Cardigan" ]

# --- Create 100 products ---
100.times do
  category_name = categories.sample
  type = types.sample
  category = Category.find_by(name: category_name)

  Product.create!(
    name: "#{category_name} #{type}",
    description: Faker::Lorem.sentence(word_count: 12),
    price: Faker::Commerce.price(range: 50..300),
    stock_quantity: rand(5..50),
    sku: Faker::Alphanumeric.alphanumeric(number: 8).upcase,
    category: category,
    on_sale: [ true, false ].sample
  )
end

puts "Seed complete! #{Product.count} products created."

# --- Static Pages ---
{
  "about" => "At Moncella, we believe clothing should feel as good as it looks. Since 2018, we've been creating carefully selected, high-quality pieces made from natural fabrics that are comfortable, stylish, and built to last. From our small Winnipeg store to customers across Canada, Moncella is for anyone who appreciates quality, comfort, and timeless style. We hope you enjoy shopping with us as much as we enjoy creating these pieces.",
  "contact" => "We'd love to hear from you! Whether you have questions about our products, need help with an order, or just want to share your thoughts, our team is here to help. Email us support@moncella.com"
}.each do |name, content|
  page = Page.find_or_initialize_by(name: name)
  page.content = content
  page.save!
end
