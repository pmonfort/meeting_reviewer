class CreateAnalyses < ActiveRecord::Migration[8.1]
  def change
    create_table :analyses do |t|
      t.references :user, null: false, foreign_key: true
      t.text :transcript
      t.text :context
      t.text :summary
      t.text :key_points
      t.text :interview_review
      t.text :feedback
      t.text :action_items
      t.text :sentiment
      t.string :language
      t.string :style
      t.string :agent_provider
      t.string :status, default: "pending"

      t.timestamps
    end
    add_index :analyses, :status
  end
end
