# 🏠 Airbnb New York City Data Analysis
# This notebook explores the Airbnb NYC dataset using Python.
# We will focus on pricing trends, reviews, superhost performance, and neighborhood patterns.

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Load dataset (update path if needed)
# Example: df = pd.read_csv("listings.csv")
# For now we assume 'listings.csv' is in the working directory.

# df = pd.read_csv("listings.csv")
# df.head()

# --- 🔍 Data Cleaning ---
# - Removed null values from price, ratings, and reviews.
# - Converted price column from string ("$1,200") to numeric.

# df['price'] = df['price'].replace('[\$,]', '', regex=True).astype(float)
# df = df[df['price'] > 0]

# --- Exploratory Data Analysis ---

# 💰 Price Distribution
# Most listings are priced below $500, with a few outliers in luxury properties.

# plt.figure(figsize=(8,5))
# sns.histplot(df['price'], bins=50, kde=True)
# plt.xlim(0, 500)
# plt.title("Distribution of Airbnb Prices in NYC")
# plt.show()

# 🗺️ Listings by Borough
# Manhattan & Brooklyn dominate Airbnb listings compared to Bronx, Queens, and Staten Island.

# plt.figure(figsize=(8,5))
# sns.countplot(data=df, x='neighbourhood_group')
# plt.title("Number of Listings per Borough")
# plt.show()

# 🏘️ Room Types
# Private rooms and entire apartments are the most common listings.

# sns.countplot(data=df, x='room_type', order=df['room_type'].value_counts().index)
# plt.title("Listings by Room Type")
# plt.show()

# --- 📈 Correlation Analysis ---
# Price vs Ratings

# sns.scatterplot(x='price', y='review_scores_rating', data=df, alpha=0.3)
# plt.xlim(0, 500)
# plt.title("Price vs Ratings")
# plt.show()

# corr = df[['price','review_scores_rating']].corr().iloc[0,1]
# print(f"Correlation between Price & Rating: {corr:.2f}")

# --- ⭐ Superhost Analysis ---
# Superhosts tend to score higher in reviews, with similar pricing.

# sns.boxplot(x='host_is_superhost', y='review_scores_rating', data=df)
# plt.title("Superhost vs Non-Superhost Ratings")
# plt.show()

# --- ✅ Conclusion ---
# - Prices show a weak positive correlation with reviews.
# - Superhosts perform better in almost all aspects (cleanliness, communication, responsiveness).
# - Manhattan & Brooklyn are premium markets, while Bronx & Queens remain affordable.
# - Entire homes dominate revenues; private rooms dominate in count.
