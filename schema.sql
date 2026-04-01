-- ============================================================
-- Recipe Tracker Database
-- CS178 Project #1
-- Load with:
--   mysql -h YOUR-RDS-ENDPOINT -P 3306 -u admin -p < recipe_tracker.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS recipe_tracker;
USE recipe_tracker;

-- ============================================================
-- TABLE: categories
-- ============================================================
CREATE TABLE categories (
  id    INT          NOT NULL AUTO_INCREMENT,
  name  VARCHAR(100) NOT NULL UNIQUE,
  PRIMARY KEY (id)
);

-- ============================================================
-- TABLE: recipes
-- ============================================================
CREATE TABLE recipes (
  id           INT           NOT NULL AUTO_INCREMENT,
  title        VARCHAR(255)  NOT NULL,
  description  TEXT,
  servings     INT           DEFAULT 4,
  prep_minutes INT           DEFAULT 0,
  cook_minutes INT           DEFAULT 0,
  instructions TEXT,
  category_id  INT,
  rating       DECIMAL(2,1)  CHECK (rating BETWEEN 1.0 AND 5.0),
  created_at   DATETIME      DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- ============================================================
-- TABLE: ingredients
-- ============================================================
CREATE TABLE ingredients (
  id                INT          NOT NULL AUTO_INCREMENT,
  name              VARCHAR(255) NOT NULL UNIQUE,
  unit_default      VARCHAR(50),
  calories_per_100g DECIMAL(6,2),
  PRIMARY KEY (id)
);

-- ============================================================
-- TABLE: recipe_ingredients  (many-to-many join table)
-- ============================================================
CREATE TABLE recipe_ingredients (
  recipe_id     INT           NOT NULL,
  ingredient_id INT           NOT NULL,
  quantity      DECIMAL(8,2),
  unit          VARCHAR(50),
  notes         VARCHAR(255),
  PRIMARY KEY (recipe_id, ingredient_id),
  FOREIGN KEY (recipe_id)     REFERENCES recipes(id)     ON DELETE CASCADE,
  FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE
);

-- ============================================================
-- TABLE: tags
-- ============================================================
CREATE TABLE tags (
  id        INT          NOT NULL AUTO_INCREMENT,
  name      VARCHAR(100) NOT NULL,
  recipe_id INT          NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
);

-- Indexes for common lookups
CREATE INDEX idx_recipes_category  ON recipes(category_id);
CREATE INDEX idx_tags_recipe       ON tags(recipe_id);
CREATE INDEX idx_tags_name         ON tags(name);

-- ============================================================
-- SEED DATA: categories
-- ============================================================

-- ============================================================
-- SEED DATA: ingredients
-- ============================================================
INSERT INTO ingredients (name, unit_default, calories_per_100g) VALUES
  ('all-purpose flour',  'cups',   364.00),
  ('eggs',               'whole',  155.00),
  ('butter',             'tbsp',   717.00),
  ('milk',               'cups',    42.00),
  ('olive oil',          'tbsp',   884.00),
  ('garlic',             'cloves', 149.00),
  ('chicken breast',     'oz',     165.00),
  ('pasta',              'oz',     371.00),
  ('canned tomatoes',    'cups',    18.00),
  ('parmesan',           'oz',     431.00),
  ('heavy cream',        'cups',   340.00),
  ('onion',              'whole',   40.00),
  ('baking powder',      'tsp',    53.00),
  ('sugar',              'cups',   387.00),
  ('salt',               'tsp',     0.00),
  ('black pepper',       'tsp',   251.00),
  ('chicken broth',      'cups',    15.00),
  ('carrots',            'whole',   41.00),
  ('celery',             'stalks',  16.00),
  ('lemon juice',        'tbsp',    22.00),
  ('spinach',            'cups',    23.00),
  ('cherry tomatoes',    'cups',    27.00),
  ('feta cheese',        'oz',     264.00),
  ('red onion',          'whole',   40.00),
  ('kalamata olives',    'cups',   145.00);

-- ============================================================
-- SEED DATA: recipes
-- ============================================================
INSERT INTO recipes (title, description, servings, prep_minutes, cook_minutes, category_id, rating, instructions) VALUES
  (
    'Classic Pancakes',
    'Fluffy weekend pancakes the whole family loves. Light, golden, and ready in under 30 minutes.',
    4, 10, 20, 1, 4.8,
    '1. Whisk together flour, baking powder, sugar, and salt in a large bowl.\n2. In a separate bowl, beat eggs and mix in milk and melted butter.\n3. Pour wet ingredients into dry and stir until just combined — lumps are fine.\n4. Heat a non-stick griddle or pan over medium heat and grease lightly.\n5. Pour 1/4 cup batter per pancake. Cook until bubbles form on top (about 2 min), then flip.\n6. Cook another 1-2 minutes until golden. Serve immediately.'
  ),
  (
    'Pasta Carbonara',
    'Authentic Roman carbonara — no cream, just eggs and parmesan. Silky and rich.',
    2, 10, 15, 2, 4.9,
    '1. Cook pasta in heavily salted boiling water until al dente. Reserve 1 cup pasta water before draining.\n2. While pasta cooks, whisk together eggs and grated parmesan in a bowl. Season with black pepper.\n3. In a large pan, cook diced pancetta or bacon over medium heat until crispy.\n4. Remove pan from heat. Add drained pasta and toss to coat in the fat.\n5. Pour egg mixture over pasta, tossing constantly and adding pasta water a splash at a time until glossy.\n6. Serve immediately with extra parmesan and cracked black pepper.'
  ),
  (
    'Simple Roast Chicken',
    'Herb-roasted chicken with crispy skin guaranteed — a Sunday dinner staple.',
    4, 15, 90, 2, 4.7,
    '1. Preheat oven to 425°F (220°C).\n2. Pat chicken completely dry with paper towels — this is key for crispy skin.\n3. Rub all over with olive oil, then season generously with salt, pepper, and any herbs you like.\n4. Stuff the cavity with half a lemon, garlic cloves, and a sprig of thyme or rosemary.\n5. Place breast-side up in a roasting pan. Roast 15 minutes per pound, plus 15 minutes extra.\n6. Chicken is done when a thermometer inserted in the thigh reads 165°F.\n7. Rest for 10 minutes before carving.'
  ),
  (
    'Greek Salad',
    'A bright, crisp salad straight from the Mediterranean. No lettuce required.',
    4, 15, 0, 5, 4.6,
    '1. Chop cherry tomatoes in half, slice red onion thinly, and dice cucumber into chunks.\n2. Combine vegetables in a large bowl with kalamata olives.\n3. Drizzle generously with olive oil and a squeeze of fresh lemon juice.\n4. Season with salt, pepper, and dried oregano.\n5. Crumble feta cheese over the top. Do not toss — let it sit on top.\n6. Serve immediately or let it sit 10 minutes for flavors to meld.'
  ),
  (
    'Chicken Noodle Soup',
    'The classic comfort soup. Great for leftovers and even better the next day.',
    6, 20, 45, 4, 4.5,
    '1. In a large pot, sauté diced onion, carrots, and celery in olive oil over medium heat for 5 minutes.\n2. Add minced garlic and cook 1 more minute.\n3. Add chicken broth and bring to a simmer.\n4. Add chicken breasts whole. Simmer 20 minutes until cooked through.\n5. Remove chicken, shred with two forks, and return to the pot.\n6. Add pasta or egg noodles and cook according to package directions.\n7. Season with salt and pepper. Finish with a squeeze of lemon juice and fresh parsley.'
  );

-- ============================================================
-- SEED DATA: recipe_ingredients
-- ============================================================
-- Classic Pancakes (recipe_id = 1)
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit) VALUES
  (1, 1,  1.50, 'cups'),   -- flour
  (1, 2,  2.00, 'whole'),  -- eggs
  (1, 3,  2.00, 'tbsp'),   -- butter
  (1, 4,  1.25, 'cups'),   -- milk
  (1, 13, 2.00, 'tsp'),    -- baking powder
  (1, 14, 2.00, 'tbsp'),   -- sugar
  (1, 15, 0.50, 'tsp');    -- salt

-- Pasta Carbonara (recipe_id = 2)
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit) VALUES
  (2, 8,  8.00, 'oz'),     -- pasta
  (2, 2,  3.00, 'whole'),  -- eggs
  (2, 10, 2.00, 'oz'),     -- parmesan
  (2, 15, 1.00, 'tsp'),    -- salt
  (2, 16, 1.00, 'tsp');    -- black pepper

-- Simple Roast Chicken (recipe_id = 3)
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit) VALUES
  (3, 7,  4.00, 'lb'),     -- chicken breast (whole bird implied)
  (3, 5,  2.00, 'tbsp'),   -- olive oil
  (3, 6,  4.00, 'cloves'), -- garlic
  (3, 15, 1.00, 'tbsp'),   -- salt
  (3, 16, 1.00, 'tsp');    -- black pepper

-- Greek Salad (recipe_id = 4)
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit) VALUES
  (4, 22, 2.00, 'cups'),   -- cherry tomatoes
  (4, 23, 4.00, 'oz'),     -- feta cheese
  (4, 24, 0.50, 'whole'),  -- red onion
  (4, 25, 0.50, 'cups'),   -- kalamata olives
  (4, 5,  3.00, 'tbsp'),   -- olive oil
  (4, 20, 1.00, 'tbsp');   -- lemon juice

-- Chicken Noodle Soup (recipe_id = 5)
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit) VALUES
  (5, 7,  1.50, 'lb'),     -- chicken breast
  (5, 17, 8.00, 'cups'),   -- chicken broth
  (5, 18, 3.00, 'whole'),  -- carrots
  (5, 19, 3.00, 'stalks'), -- celery
  (5, 12, 1.00, 'whole'),  -- onion
  (5, 6,  3.00, 'cloves'), -- garlic
  (5, 8,  6.00, 'oz'),     -- pasta (egg noodles)
  (5, 5,  2.00, 'tbsp'),   -- olive oil
  (5, 20, 1.00, 'tbsp');   -- lemon juice

-- ============================================================
-- SEED DATA: tags
-- ============================================================
INSERT INTO tags (name, recipe_id) VALUES
  ('vegetarian', 1), ('quick', 1), ('kid-friendly', 1),
  ('classic', 2), ('italian', 2), ('quick', 2),
  ('weekend', 3), ('meal-prep', 3), ('gluten-free', 3),
  ('vegetarian', 4), ('quick', 4), ('mediterranean', 4), ('healthy', 4),
  ('comfort-food', 5), ('meal-prep', 5), ('kid-friendly', 5);

-- ============================================================
-- USEFUL QUERIES (reference — not executed on load)
-- ============================================================

-- All recipes with category and total time:
-- SELECT r.id, r.title, c.name AS category, c.emoji,
--        r.prep_minutes + r.cook_minutes AS total_minutes, r.rating
-- FROM recipes r
-- LEFT JOIN categories c ON r.category_id = c.id
-- ORDER BY r.rating DESC;

-- Ingredients for a given recipe (e.g. id=2):
-- SELECT i.name, ri.quantity, ri.unit, ri.notes
-- FROM recipe_ingredients ri
-- JOIN ingredients i ON ri.ingredient_id = i.id
-- WHERE ri.recipe_id = 2;

-- Quick, high-rated recipes:
-- SELECT title, prep_minutes + cook_minutes AS total_minutes, rating
-- FROM recipes
-- WHERE prep_minutes + cook_minutes < 30 AND rating >= 4.5
-- ORDER BY rating DESC;

-- Recipes by tag:
-- SELECT DISTINCT r.title, r.rating
-- FROM recipes r JOIN tags t ON t.recipe_id = r.id
-- WHERE t.name = 'vegetarian';
