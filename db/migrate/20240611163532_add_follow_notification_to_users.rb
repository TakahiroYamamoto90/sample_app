class AddFollowNotificationToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :follow_notification, :boolean, default:false
  end
end
