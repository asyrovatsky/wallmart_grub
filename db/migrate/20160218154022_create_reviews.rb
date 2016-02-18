class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.string :title
      t.string :date
      t.string :nick
      t.text :text
      t.integer :search_id

      t.timestamps null: false
    end
  end
end
