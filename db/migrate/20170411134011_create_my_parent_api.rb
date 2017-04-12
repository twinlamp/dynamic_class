class CreateMyParentApi < ActiveRecord::Migration[5.0]
  def change
    create_table :my_parent_apis do |t|
      t.string :internal_param1
      t.string :internal_param2
      t.string :internal_param3
      t.string :internal_param4
    end
  end
end
