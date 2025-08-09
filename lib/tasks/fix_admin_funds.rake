namespace :fix_admin_funds do
  desc "Set admin funds to $1,000,000"
  task set: :environment do
    User.where(role: 'admin').update_all(funds: 1_000_000)
    puts 'Admin funds updated.'
  end
end
