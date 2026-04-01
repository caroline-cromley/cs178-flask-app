# dbCode.py
# Author: Caroline Cromley
# Helper functions for database connection and queries

import pymysql
import creds

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


def update_recipe_rating(recipe_id, rating):
    """Updates the rating of a recipe."""
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("UPDATE recipes SET rating = %s WHERE id = %s", (rating, recipe_id))
    conn.commit()
    cur.close()
    conn.close()
