# dbCode.py
# Author: Caroline Cromley
# Helper functions for database connection and queries

import pymysql
import creds
import boto3
import uuid

# Connect to DynamoDB using ProjectOneUser IAM credentials
dynamodb = boto3.resource(
    'dynamodb',
    aws_access_key_id=creds.aws_access_key_id,
    aws_secret_access_key=creds.aws_secret_access_key,
    region_name=creds.region_name
)
reviews_table = dynamodb.Table('RecipeReviews')


def get_conn():
    """Returns a connection to the MySQL RDS instance"""
    try:
        conn = pymysql.connect(
            host=creds.host,
            user=creds.user,
            password=creds.password,
            db=creds.db,
        )
        return conn
    except Exception as e:
        print("Error connecting to database:", e)


def execute_query(query, args=()):
    """Executes a SELECT query and returns all rows as dictionaries"""
    try:
        cur = get_conn().cursor(pymysql.cursors.DictCursor)
        cur.execute(query, args)
        rows = cur.fetchall()
        cur.close()
        return rows
    except Exception as e:
        print("Error executing query:", e)
        return []

def get_recipes():
    """Returns all recipes joined with their category name, ordered by rating"""
    query = """
        SELECT r.id, r.title, r.servings, r.prep_minutes, r.cook_minutes, r.rating, c.name AS category
        FROM recipes r
        JOIN categories c ON r.category_id = c.id
        ORDER BY r.rating DESC
    """
    return execute_query(query)


def add_recipe(title, description, category_id, servings, prep_minutes, cook_minutes, rating, instructions):
    """Inserts a new recipe into the MySQL database."""
    try:
        conn = get_conn()
        cur = conn.cursor()
        cur.execute("""
            INSERT INTO recipes (title, description, category_id, servings, prep_minutes, cook_minutes, rating, instructions)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)""",
        (title, description, category_id, servings, prep_minutes, cook_minutes, rating, instructions))
        conn.commit()
        cur.close()
        conn.close()
    except Exception as e:
        print("Error adding recipe:", e)


def add_review(recipe_id, reviewer_name, stars, comment):
    """Inserts a new review into the DynamoDB table."""
    try:
        reviews_table.put_item(Item={
            'recipe_id': recipe_id,
            'review_id': str(uuid.uuid4()),  #Claude AI was used to help generate a unique review_id using the uuid library for each review added to the DynamoDB table.
            'reviewer_name': reviewer_name,
            'stars': stars,
            'comment': comment
        })
    except Exception as e:
        print("Error adding review to DynamoDB:", e)


def get_reviews(recipe_id):
    """Retrieves all reviews for a given recipe ID from DynamoDB."""
    try:
        response = reviews_table.query(
            KeyConditionExpression=boto3.dynamodb.conditions.Key('recipe_id').eq(recipe_id) #Claude AI was used to help code the query for retrieving reviews based on recipe_id from the DynamoDB table.
        )
        return response.get('Items', [])
    except Exception as e:
        print("Error retrieving reviews:", e)
        return []


def delete_recipe(recipe_id):
    """Deletes a recipe from the database by ID."""
    try:
        conn = get_conn()
        cur = conn.cursor()
        cur.execute("DELETE FROM recipes WHERE id = %s", (recipe_id,))
        conn.commit()
        cur.close()
        conn.close()
    except Exception as e:
        print("Error deleting recipe:", e)


def update_recipe_rating(recipe_id, rating):
    """Updates the rating of a recipe."""
    try:
        conn = get_conn()
        cur = conn.cursor()
        cur.execute("UPDATE recipes SET rating = %s WHERE id = %s", (rating, recipe_id))
        conn.commit()
        cur.close()
        conn.close()
    except Exception as e:
        print("Error updating recipe rating:", e)
