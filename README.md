## Objectives
Use the locals keyword
Understand why using instance variables in partials is bad
Use a partial iterating over a collection passing in the local
Use a partial form another controller with a local

## Introduction

So as you know, with partials we break our code into chunks which then make it easier to reuse these chunks in different contexts. What I am going to try to convince you of in this article, is that whenever our partial depends on data to run, we should always pass through that data using locals.
In the following, we'll see what that sentence means, and how to write using local variables.
So, if you look at the code base, you'll see the same piece of code regarding authors repeated.

```
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
```
<ul>
  <li> <%= @author.name %></li>
  <li> <%= @author.hometown %></li>
</ul>
```

So now to keep our code in the show page rendering out the same content, we call the partial from the `app/views/authors/show.html.erb` file.  Doing this, the `app/views/authors/show.html.erb` file now looks like the following.
```
<%= render 'author' %>
```
Great! So, now let's take a look at the `app/views/posts/show.html.erb` file.  It currently looks like the following:

`app/views/posts/show.html.erb`
```
Information About the Post
<ul>
  <li> <%= @author.name %></li>
  <li> <%= @author.hometown %></li>
</ul>
<%= @post.title %>
<%= @post.content %>
```

So you can see that the first four lines are exactly the same as the code in our authors/author partial.  Let's remove the repetition in our codebase by using that partial instead.  By using the partial, our code will look like the following:

`app/views/posts/show.html.erb`
```
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

Cool, so let's now see how local variables makes our code more explicit.  
This is what the entire show view looks like:
`app/views/posts/show.html.erb`
```
Information About the Post
<%= render {partial: "authors/author", locals: {post_author: @author}} %>
<%= @post.title %>
<%= @post.content %>
```

So notice that rendering the authors/author partial without passing through local variables the second line of code looked like `<%= render 'authors/author' %>`.  And now with passing through locals: `<%= render {partial: "authors/author", locals: {post_author: @author}} %>`.

So let's notice a couple things.  First, is that we are no longer passing the render method a string, but instead we are passing the method a hash.  That hash two key value pairs.  

The first key value pair is partial, which specifies the file we are rendering.  The second key-value pair passes through yet another hash which holds my local variables.  Here the locals are a local variable named post_author with the value of that local variable being set as @author, which is defined in my controller.  

Now these are all of the changes to evoke a partial with locals.  To use a partial with locals we need to make sure that the dependent code is given the same name as the local variable defined in the locals hash.  So in the partial `app/views/author/_author.html.erb` we need to change our code from:
```
<ul>
  <li> <%= @author.name %></li>
  <li> <%= @author.hometown %></li>
</ul>
```

to
`app/views/author/_author.html.erb`
```
<ul>
  <li> <%= post_author.name %></li>
  <li> <%= post_author.hometown %></li>
</ul>
```

So in other words, the way we use locals with a partial is similar to how we pass arguments into a method.  In the locals hash {post_author: @author}, the key to the hash, is the argument name, and the value of that argument is the corresponding value to the key.  Note that I can name the key whatever I want (and would probably name it author in a real codebase, but I thought using {author: @author} would make things confusing in this lesson).  

Okay, so now notice that if we choose to delete the line `<%= render {partial: "authors/author", locals: {post_author: @author}} %>` from the authors/show view, we will also see that calling the partial required me to pass in data about the author, and that line in our controller may no longer be needed.

In fact, with locals, we can eliminate `@author = @post.author` line in the `posts#show` action in the controller completely, by instead only accessing that data in where we need it, in the partial.

So let's remove that line of code in our controller, and in the view pass through the author information by changing our code to the following:

`app/controllers/posts_controller`
```
  ...
  def show
    @post = Post.find(params[:id])
  end

```

`app/views/posts/show.html.erb`
```
Information About the Post
<%= render {partial: "authors/author", locals: {post_author: @post.author}} %>
<%= @post.title %>
<%= @post.content %>
```

Now that's some good stuff right there.  We are being more explicit in our code about the dependencies, we are reducing lines of code in our codebase, and we are reducing the scope that our author data is exposed.
Don't worry if you find the syntax for rendering a partial hard to remember - it is.  But just google railsguides partials, whenever you forget.

##Another reason to always use locals: iteration and block variables

Ok, if you're still not convinced of the benefits of using local variables, in our partials, let's see an example where the benefits are even more obvious.
Take a look at the `app/views/authors/index.html.erb` page.  In it, we see our same lines of code repeated, beginning with the <ul> tag.

```
<% @authors.each do |author| %>
  <ul>
    <li> <%= author.name %></li>
    <li> <%= author.hometown %></li>
  </ul>
<% end %>
```

Ok, so it looks like we can use our author partial.  But try to do it without using local variables.
```
<% @authors.each do |author| %>
  <%= render 'authors/author' %>
<% end %>
```
And remember our partial looked like:
```
<ul>
    <li> <%= author.name %></li>
    <li> <%= author.hometown %></li>

</ul>
```
Well without the use of locals, the value of the block argument author is not accessible in the partial.  But I could perhaps use an instance variable, as instance variables are available throughout every rendered view for each request.
To do that I would need to do something like
```
<% @authors.each do |author| %>
  <%= @author = author %>
  <%= render 'authors/author' %>
<% end %>
```
With the partial of:
```
<ul>
    <li> <%= @author.name %></li>
    <li> <%= @author.hometown %></li>
</ul>
```

That should work, but its really wonky.  Let's use local variables:
```
<% @authors.each do |author| %>
  <%= render partial: 'authors/author', locals: {post_author: author} %>
<% end %>
```
With the partial of:
```
<ul>
    <li> <%= post_author.name %></li>
    <li> <%= post_author.hometown %></li>
</ul>
```
Ok, that's much better.  Now the render method is being called once for each existing author, passing through a different author each time.

Ok, one last change.  Now that we know how partials work, let's name our local arguments correctly: that is, let's change them from post_author to just author.
So let's change `app/views/authors/index.html.erb` to
```
<% @authors.each do |author| %>
  <%= render partial: 'authors/author', locals: {author: author} %>
<% end %>
```
With the partial `app/views/authors/_author.html.erb` now as:
```
<ul>
    <li> <%= author.name %></li>
    <li> <%= author.hometown %></li>
</ul>
```

And don't forget the authors show page, which we need to change to:

  `<%= render partial: 'authors/author', locals: {author: @author} %>`

So, whenever our partial depends on data, we don't want that partial to access the data from an instance variable directly from the controller.  Instead, always pass through the data with locals.  It makes our dependencies more explicit, can reduce lines of code in the controller, and allows us to use block variables when iterating through a collection.

## Resources
(RailsGuides)[http://guides.rubyonrails.org/layouts_and_rendering.html#using-partials]
