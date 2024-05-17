namespace :articles do
    desc 'Remove articles with more than 3 reports'
    task remove_reported: :environment do
      Article.where('reports_count >= ?', 6).destroy_all
    end
  end
  