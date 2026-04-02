# author: T. Urness and M. Moore
# description: Flask example using redirect, url_for, and flash
# credit: the template html files were constructed with the help of ChatGPT

from flask import Flask
from flask import render_template
from flask import Flask, render_template, request, redirect, url_for, flash
from dbCode import *

app = Flask(__name__)
app.secret_key = 'your_secret_key' # this is an artifact for using flash displays; 
                                   # it is required, but you can leave this alone

@app.route('/')
def home():
    return render_template('home.html')


@app.route('/add-recipe', methods=['GET', 'POST'])
def add_recipe_page():
    if request.method == 'POST':
        add_recipe(
            request.form['title'],
            request.form['description'],
            request.form['category_id'],
            request.form['servings'],
            request.form['prep_minutes'],
            request.form['cook_minutes'],
            request.form['rating'],
            request.form['instructions']
        )
        flash('Recipe added!', 'success')
        return redirect(url_for('home'))

        
    categories = execute_query("SELECT id, name FROM categories")
    return render_template('add_recipe.html', categories=categories)


@app.route('/delete-recipe',methods=['GET', 'POST'])
def delete_recipe_route():
    if request.method == 'POST':
        delete_recipe(request.form['recipe_id'])
        flash('Recipe deleted successfully!', 'warning')
        return redirect(url_for('home'))
    recipes = execute_query("SELECT id, title FROM recipes ORDER BY title")
    return render_template('delete_recipe.html', recipes=recipes)


@app.route('/update-recipe', methods=['GET', 'POST'])
def update_recipe_route():
    if request.method == 'POST':
        recipe_id = request.form['recipe_id']
        rating = request.form['rating']
        update_recipe_rating(recipe_id, rating)
        flash('Recipe updated!', 'success')
        return redirect(url_for('home'))
    recipes = execute_query("SELECT id, title FROM recipes ORDER BY title")
    return render_template('update_recipe.html', recipes=recipes)



@app.route('/display-recipes')
def display_recipes():
    recipes_list = get_recipes() # this is a function we defined in dbCode.py; it returns a list of recipes from the database
    return render_template('display_recipes.html', recipes = recipes_list)


@app.route('/reviews/<int:recipe_id>', methods=['GET', 'POST'])
def reviews(recipe_id):
    if request.method == 'POST':
        add_review(recipe_id, request.form['reviewer_name'], int(request.form['stars']), request.form['comment'])
        flash('Review added!', 'success')
        return redirect(url_for('reviews', recipe_id=recipe_id))
    
    recipe = execute_query("SELECT title FROM recipes WHERE id = %s", (recipe_id,))
    reviews_list = get_reviews(recipe_id)
    return render_template('reviews.html', recipe=recipe[0], reviews=reviews_list, recipe_id=recipe_id)

# these two lines of code should always be the last in the file
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)
