# config/initializers/assets.rb

# Propshaft configuration for main app
Rails.application.config.assets.paths << Rails.root.join("app/assets/stylesheets")
Rails.application.config.assets.paths << Rails.root.join("app/assets/images")
