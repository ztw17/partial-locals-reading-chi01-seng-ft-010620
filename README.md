## Objectives
1. Use the locals keyword
2. Understand why using instance variables in partials is bad
3. Use a partial while rendering a collection
4. Use a partial form another controller with a local

## Introduction

So as you know, with partials we break our code into chunks which then make it easier to reuse these chunks in different contexts. What I am going to try to convince you of in this article, is that whenever our partial depends on data to run, we should always pass through that data using locals.
In the following, we'll see what that sentence means, and how to write using local variables.
So, if you look at the code base, you'll see the same piece of code regarding authors repeated.

```erb
<ul>
  <li> <%= @author.name %></li>
  <li> <%= @author.hometown %></li>
</ul>
```
We will find that code (or very similar code) in the following pages: `app/views/authors/show.html.erb`, `app/views/authors/index.html.erb`, `app/views/posts/show.html.erb`.

Looks like we got some work to do.  So let's start with the author show page.  
Let's remove the code from our `app/views/authors/show.html.erb` page.  So now our file should be empty:
`app/views/authors/show.html.erb`
```

```
We can move the removed code into a partial `app/views/authors/_author.html.erb` that now has the following code.
`app/views/authors/_author.html.erb`
```erb
<ul>
  <li> <%= @author.name %></li>
  <li> <%= @author.hometown %></li>
</ul>
```

So now to keep our code in the show page rendering out the same content, we call the partial from the `app/views/authors/show.html.erb` file.  Doing this, the `app/views/authors/show.html.erb` file now looks like the following.
```erb
<%= render 'author' %>
```
Great! So, now let's take a look at the `app/views/posts/show.html.erb` file.  It currently looks like the following:

`app/views/posts/show.html.erb`
```erb
Information About the Post
<ul>
  <li> <%= @author.name %></li>
  <li> <%= @author.hometown %></li>
</ul>
<%= @post.title %>
<%= @post.content %>
```

So you can see that the first two lines are exactly the same as the code in our authors/author partial.  Let's remove the repetition in our codebase by using that partial instead.  By using the partial, our code will look like the following:

`app/views/posts/show.html.erb`
```erb
Information About the Post
<%= render 'authors/author' %>
<%= @post.title %>
<%= @post.content %>
```

Note that because we are calling a partial from outside the current `app/views/posts` folder, we must specify the folder that our author partial is coming from by calling `render 'authors/author'`.

This code may look ok at first, but it poses some problems.  The reason why is because when calling the partial authors/author, we are not being explicit about that partial's dependencies.
A dependency of code is information or data that the code requires in order to work.  So in this case, the dependency of the author partial is the instance variable @author.  Without that instance variable, the code won't work.  But unfortunately, that dependency is defined far away in the controller.
This is not so hot.  Here's why: let's say our team's designer comes along and tells us we no longer want to display author information with each post - just the post itself.
Ok, so we just delete the line `<%= render 'authors/author' %>` right? Well, unfortunately, we forgot to remove the @author instance variable in the controller as well, because the dependency was not explicit.  This mistake likely would have been avoided if whenever we called the partial,
we also specified the data that the code relied on by passing through local variables.  

Cool, so let's now see how local variables make our code more explicit.  
This is what the entire show view looks like:
`app/views/posts/show.html.erb`
```erb
Information About the Post
<%= render partial: "authors/author", locals: {post_author: @author} %>
<%= @post.title %>
<%= @post.content %>
```

So notice that rendering the authors/author partial without passing through local variables the second line of code looked like `<%= render 'authors/author' %>`.  And now with passing through locals: `<%= render {partial: "authors/author", locals: {post_author: @author}} %>`.

Notice a few things.  First, we are no longer passing the render method a string, now we're passing a hash.  That hash two key value pairs.  

The first key value pair tells rails the name of the partial to render.  The second key-value pair contains a key of locals which points to a hash of variables to pass into the partial.  The key is the name of the variable and its value is the value you'd like it to have in the parial.  For the values of your locals, you can use instance variables set in the controller.

When we use locals we need to make sure that the variables we refer to in our partial have the same names as the keys in our locals hash.

In our example, the partial `app/views/author/_author.html.erb` we need to change our code from:
```erb
<ul>
  <li> <%= @author.name %></li>
  <li> <%= @author.hometown %></li>
</ul>
```

to
`app/views/author/_author.html.erb`
```erb
<ul>
  <li> <%= post_author.name %></li>
  <li> <%= post_author.hometown %></li>
</ul>
```

In other words, the way we use locals with a partial is similar to how we pass arguments into a method.  In the locals hash {post_author: @author}, the key to the hash, is the argument name, and the value of that argument is the corresponding value to the key.  We can name the key's whatever we want (and would probably name it author in a real application, but we wanted to demonstrate that name of the key has no special powers.

Now notice that if we choose to delete the line `<%= render {partial: "authors/author", locals: {post_author: @author}} %>` from the authors/show view, we will also see that calling the partial required me to pass in data about the author, and that line in our controller may no longer be needed.

In fact, with locals, we can eliminate `@author = @post.author` line in the `posts#show` action in the controller completely, by instead only accessing that data in where we need it, in the partial.

So let's remove that line of code in our controller, and in the view pass through the author information by changing our code to the following:

`app/controllers/posts_controller`
```ruby
  ...
  def show
    @post = Post.find(params[:id])
  end

```

`app/views/posts/show.html.erb`
```erb
Information About the Post
<%= render partial: "authors/author", locals: {post_author: @post.author} %>
<%= @post.title %>
<%= @post.content %>
```

This code is much better.  We are being more explicit about our dependencies, reducing lines of code in our codebase, and reducing the scope of the author variable.
Don't worry if you find the syntax for rendering a partial hard to remember - it is.  You can always re-reference this guide or use the Rails Guides.

## Resources
[RailsGuide: Partials](http://guides.rubyonrails.org/layouts_and_rendering.html#using-partials)
