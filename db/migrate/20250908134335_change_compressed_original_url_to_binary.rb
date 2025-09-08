class ChangeCompressedOriginalUrlToBinary < ActiveRecord::Migration[8.0]
  def up
    remove_column :shortened_urls, :compressed_original_url
    add_column :shortened_urls, :compressed_original_url, :binary, null: false
    
    add_index :shortened_urls, :compressed_original_url, unique: true
  end

  def down
    remove_column :shortened_urls, :compressed_original_url
    add_column :shortened_urls, :compressed_original_url, :string, null: false
    
    add_index :shortened_urls, :compressed_original_url, unique: true
  end
end
