---
title: "Getting Started with Ruby on Rails: A Complete Beginner's Tutorial"
date: "2024-02-15"
excerpt: "Learn how to build your first Ruby on Rails application from scratch. This comprehensive guide covers everything from installation to deployment."
category: "tutorial"
---

Ruby on Rails (often just called Rails) is a powerful web application framework that has been powering websites and applications for over 15 years. Known for its "convention over configuration" philosophy, Rails makes it possible to build robust applications quickly.

## What is Ruby on Rails?

Rails is a full-stack web framework written in Ruby. It provides everything you need to build database-backed web applications following the MVC (Model-View-Controller) pattern.

## Prerequisites

Before we begin, make sure you have:

- Ruby 3.1 or later installed
- SQLite3 (comes with Rails, but good to verify)
- Node.js and Yarn (for JavaScript asset management)

## Installation

### Install Ruby

On macOS with Homebrew:

```bash
brew install ruby
```

On Linux:

```bash
sudo apt-get install ruby-full
```

Verify installation:

```bash
ruby -v
```

### Install Rails

```bash
gem install rails
```

Verify installation:

```bash
rails -v
```

## Creating Your First Rails Application

Let's create a simple blog application to learn the basics:

```bash
rails new my_blog
cd my_blog
```

This command creates a new Rails application with all the necessary files and directory structure.

## Understanding the Rails Structure

Here's what Rails generates:

```
my_blog/
├── app/              # Main application code
│   ├── controllers/  # Controllers handle requests
│   ├── models/       # Models represent data
│   ├── views/        # Views are the templates
│   └── assets/       # CSS, JavaScript, images
├── config/           # Configuration files
├── db/               # Database files and migrations
├── Gemfile           # Ruby dependencies
└── README.md
```

## Generating Your First Resource

Let's create a Post model with a title and content:

```bash
rails generate scaffold Post title:string content:text
```

This single command creates:

- A migration file to create the posts table
- A model file (Post)
- A controller (PostsController)
- Views for CRUD operations
- Routes

## Running Migrations

Now let's create the database table:

```bash
rails db:migrate
```

This runs the migration and creates the `posts` table in your database.

## Starting the Server

```bash
rails server
```

Visit `http://localhost:3000` in your browser. You should see the Rails welcome page.

Visit `http://localhost:3000/posts` to see your posts interface.

## Understanding MVC in Rails

### Models

Models represent your data and business logic:

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  validates :title, presence: true
  validates :content, presence: true, length: { minimum: 10 }
end
```

### Controllers

Controllers handle HTTP requests:

```ruby
# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  def index
    @posts = Post.all
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    if @post.save
      redirect_to @post
    else
      render :new
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :content)
  end
end
```

### Views

Views are your templates (using ERB by default):

```erb
<!-- app/views/posts/index.html.erb -->
<h1>All Posts</h1>

<% @posts.each do |post| %>
  <div>
    <h2><%= post.title %></h2>
    <p><%= truncate(post.content, length: 100) %></p>
    <%= link_to "Read more", post %>
  </div>
<% end %>

<%= link_to "New Post", new_post_path %>
```

## Adding Associations

Let's add comments to posts. First, generate the Comment model:

```bash
rails generate model Comment post:references content:text
rails db:migrate
```

Update the models:

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  has_many :comments, dependent: :destroy
  validates :title, presence: true
end

# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :post
  validates :content, presence: true
end
```

## Routes

Rails uses a RESTful routing system. Check your routes:

```bash
rails routes
```

Common route helpers:
- `posts_path` → `/posts`
- `new_post_path` → `/posts/new`
- `post_path(@post)` → `/posts/1`
- `edit_post_path(@post)` → `/posts/1/edit`

## Adding Authentication (Optional)

For a production app, you'd want authentication. Popular gems include:

- Devise (most popular)
- Sorcery (lightweight)
- Clearance (simple)

Install Devise:

```bash
gem 'devise'
bundle install
rails generate devise:install
rails generate devise User
rails db:migrate
```

## Deployment

### Deploy to Heroku

1. Add to Gemfile:
```ruby
gem 'pg'  # PostgreSQL for production
```

2. Create Procfile:
```
web: bundle exec puma -C config/puma.rb
```

3. Deploy:
```bash
heroku create my-blog-app
git push heroku main
heroku run rails db:migrate
```

## Next Steps

Now that you understand the basics, explore:

- **Active Record queries**: Learn to query your database efficiently
- **Action Mailer**: Send emails from your application
- **Background jobs**: Use Sidekiq or Delayed Job
- **Testing**: RSpec or Minitest for writing tests
- **API mode**: Build JSON APIs with Rails

## Conclusion

Rails provides an excellent foundation for building web applications. Its conventions and built-in features let you focus on your application's unique features rather than boilerplate code.

Remember: Rails follows the principle of "convention over configuration," which means if you follow Rails conventions, you'll write less code and have fewer decisions to make.

Happy coding with Rails!
