class CreateFoos < ActiveRecord::Migration[7.0]
  def change
    create_table :foos do |t|
      t.string :name
      t.string :keywords
      t.date :start_date
      t.date :end_date
      t.string :phone_number
      t.string :postal_code
      t.integer :widget_count

      t.timestamps
    end
  end
end
