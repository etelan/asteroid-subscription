# Mindful Chef Subscription Challenge

## What is it?
This is a little project for a fictional subscription service.
I chose a very silly subscription model - **an asteroid, from the solar system, straight to your door every month.**

I worked on this alongside my usual job, so it is hard to estimate how long I spent on this.

There was a peroid of time in which I got really inspired - especially when I realised I could connect it to the real NASA API endpoints - so I suspect in general, I've spent about 4 or 5 hours on this project. I understand that this is more than the 2 hours expected for the project; due to getting hyperfocused when I got inspired - a symptom of my ADHD.

## Technical Overview
The user types in personal details, selects a plan, and then a real asteroid from our database gets selected for them. At each stage their information is saved and updated to the database, including which step they are on. 

### Views
It contains a homepage, an onboarding page (that uses Turbo to only partial refresh / load changes), a admin login page, and an admin dashboard. I enjoyed learning Turbo for this project. There are lots of partial views made to seperate out some of the larger views.

There are also pages to show specific asteroids and plans based on the id. 

Something I would change if I had more time would be to split out the CSS files, as currently they are large and cumbersome, and not best practise. Additionally, I designed the website - but the CSS code was largely AI generated due to time constraints.

### Databases
It contains 3 databases - one for the user, one for the plans (aka, the subscription tiers), and one for the asteroids. 

If I had more time, I'd change what fields are indexed, and change some one to many relations to one to one relations. The asteroid data was injested from the [Small Body Data Base API](https://ssd-api.jpl.nasa.gov/doc/sbdb.html) (maintained by NASA's Jet Propulsion Lab). I enjoyed making that injestion task script. 

Contains database migration files too, so you can see how the database evolved over my project.

### Controllers
There are controllers for each page, and I put the onboarding wizard into services. The onboarding wizard allows the views and controllers to stay light. 

The admin controller contains logic for logging the user in or redirecting them to the login screen, if they go to the admin dashboard url without permission.

### Tests
There are some tests for my code, however my test coverage could certainly be improved. I wrote some request tests and some model validation tests. 

For example, I would also add BDD Cucumber tests.

## Future?
Throughout the codebase, there are comments denoting to what I would do if I had more time.

If this was a serious subscription service, I would scale it up using AWS.
I would use a load balancer and autoscaling groups to satisfy demand, and Amazon Simple Notification Service (SNS) to send basic confirmation emails. Additionally, I would move to a database that would be better for production usage, while utilising AWS infrastructure. I would pick Amazon Aurora - which also has support for PostgreSQL.

If this company wasn't immediately siezed by the government, the entire world would unfortunately perish, so scaling up is not a realistic concern.