class CreateAdmins < ActiveRecord::Migration[5.1]
  def change
    create_table :admins do |t|
      t.jsonb :permissions

      t.timestamps
    end
  end
end
