# This file should ensure the existence of records required to run the application in every environment
require 'yaml'
require 'date'

begin
  puts "=== Starting seed process ==="
  puts "Rails environment: #{Rails.env}"

  # Create default admin user
  admin = User.find_or_create_by!(email: 'admin@example.com') do |user|
    user.password = 'password123'
    user.password_confirmation = 'password123'
  end
  puts "✓ Created admin user: #{admin.email} / password123"

  # Seed posts from markdown files
  posts_dir = Rails.root.join('db', 'seeds')
  markdown_files = Dir.glob(posts_dir.join('*.md'))
  puts "Found #{markdown_files.size} markdown files"
  puts ""

  markdown_files.each do |file_path|
    begin
      content = File.read(file_path)

      # Parse frontmatter
      frontmatter_match = content.match(/\A---\s*\n(.*?)\n---\s*\n(.*)\z/m)
      unless frontmatter_match
        puts "✗ Skipping #{File.basename(file_path)}: Invalid frontmatter"
        next
      end

      metadata = YAML.safe_load(frontmatter_match[1])
      body = frontmatter_match[2]

      slug = File.basename(file_path, '.md').parameterize
      title = metadata['title']
      date = Date.parse(metadata['date'])
      excerpt = metadata['excerpt'] || ''
      category = metadata['category'] || 'general'

      post = Post.find_or_initialize_by(slug: slug)
      post.assign_attributes(
        title: title,
        excerpt: excerpt,
        category: category,
        published: true,
        published_at: date.beginning_of_day,
        user: admin
      )

      # Save post first, then set Action Text content
      if post.save
        # Convert markdown to HTML for Action Text
        require 'redcarpet'
        markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true, fenced_code_blocks: true)
        html_content = markdown.render(body)

        # Set Action Text content
        post.content.body = html_content
        post.save!

        puts "✓ Created/Updated post: #{title}"
      else
        puts "✗ Failed to save post #{title}: #{post.errors.full_messages.join(', ')}"
      end
    rescue => e
      puts "✗ Error processing #{File.basename(file_path)}: #{e.message}"
    end
  end

  puts ""
  puts "=== Seeding completed! ==="
  puts "Posts created: #{Post.count}"
  puts "Users created: #{User.count}"

rescue => e
  puts "ERROR in seeds: #{e.message}"
  puts e.backtrace.first(10).join("\n")
  raise
end
