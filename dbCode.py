# dbCode.py
# Author: Caroline Cromley
# Helper functions for database connection and queries

import pymysql
import creds
import boto3
import uuid

dynamodb = boto3.resource(
    'dynamodb',
    aws_access_key_id=creds.aws_access_key_id,
    aws_secret_access_key=creds.aws_secret_access_key,
    region_name=creds.region_name
)
reviews_table = dynamodb.Table('RecipeReviews')


def get_conn():
    """Returns a connection to the MySQL RDS instance."""
    conn = pymysql.connect(
        host=creds.host,
        user=creds.user,
        password=creds.password,
        db=creds.db,
    )
    return conn

def execute_query(query, args=()):
    """Executes a SELECT query and returns all rows as dictionaries."""
    cur = get_conn().cursor(pymysql.cursors.DictCursor)
    cur.execute(query, args)
    rows = cur.fetchall()
    cur.close()
    return rows

def get_recipes():
    """Returns a list of all recipes from the database."""
    query = """
        SELECT r.id, r.title, r.servings, r.prep_minutes, r.cook_minutes, r.rating, c.name AS category
        FROM recipes r
        JOIN categories c ON r.category_id = c.id
        ORDER BY r.rating DESC
    """
    return execute_query(query)


def add_recipe(title, description, category_id, servings, prep_minutes, cook_minutes, rating, instructions):
    """Inserts a new recipe into the database."""
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("""
        INSERT INTO recipes (title, description, category_id, servings, prep_minutes, cook_minutes, rating, instructions)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
    """, (title, description, category_id, servings, prep_minutes, cook_minutes, rating, instructions))
    conn.commit()
    cur.close()
    conn.close()


def add_review(recipe_id, reviewer_name, stars, comment):
    """Inserts a new review into the DynamoDB table."""
    reviews_table.put_item(Item={
        'recipe_id': recipe_id,
        'review_id': str(uuid.uuid4()),
        'reviewer_name': reviewer_name,
        'stars': stars,
        'comment': comment
    })


def get_reviews(recipe_id):
    """Retrieves all reviews for a given recipe ID from DynamoDB."""
    response = reviews_table.query(
        KeyConditionExpression=boto3.dynamodb.conditions.Key('recipe_id').eq(recipe_id)
    )
    return response.get('Items', [])


def delete_recipe(recipe_id):
    """Deletes a recipe from the database by ID."""
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("DELETE FROM recipes WHERE id = %s", (recipe_id,))
    conn.commit()
    cur.close()
    conn.close()


def update_recipe_rating(recipe_id, rating):
    """Updates the rating of a recipe."""
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("UPDATE recipes SET rating = %s WHERE id = %s", (rating, recipe_id))
    conn.commit()
    cur.close()
    conn.close()
