class CreateShorternedUrls < ActiveRecord::Migration[8.0]
  def change
    create_table :shorterned_urls do |t|
      t.string :compressed_original_url, null: false, index: { unique: true }
      t.string :identifier, null: false, index: { unique: true }
      t.timestamps
    end
  end
end
