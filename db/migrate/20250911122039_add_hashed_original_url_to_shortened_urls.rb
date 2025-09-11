class AddHashedOriginalUrlToShortenedUrls < ActiveRecord::Migration[8.0]
  def up
    add_column :shortened_urls, :hashed_original_url, :string, null: false
    add_index :shortened_urls, :hashed_original_url, unique: true
    remove_index :shortened_urls, :compressed_original_url
  end

  def down
    remove_column :shortened_urls, :hashed_original_url
    add_index :shortened_urls, :compressed_original_url, unique: true
  end
end
