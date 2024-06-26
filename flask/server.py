import pandas as pd
import numpy as np
from flask import Flask, request, jsonify
from flask_cors import CORS
import pickle
from sklearn.metrics.pairwise import cosine_similarity
import requests

app = Flask(__name__)
CORS(app)

# Load your models and data
with open('C:/Users/ISSA MASALA/Desktop/BACKUP/get_user_preferences.pkl', 'rb') as f:
    label_encoders, scaler, train_feature_matrix, train_df, knn_model = pickle.load(f)

# Load the original dataset containing performance data
original_df = pd.read_csv('C:/Users/ISSA MASALA/Desktop/BACKUP/school_dataset.csv')

# Print columns of the original dataframe
print("Original DataFrame columns:", original_df.columns)

MAPBOX_ACCESS_TOKEN = 'pk.eyJ1IjoiaW1pc3NhdHoiLCJhIjoiY2x3ZmE3MHJ4MWNuYjJscG41dDV1anRnaiJ9.Me0C9TsGLO6IiJxucSN0GQ'

@app.route('/school', methods=['POST'])
def submit_data():
    data = request.get_json()
    print("Received data:", data)

    # Getting coordinates using the geocoding function
    latitude, longitude = get_coordinates(data['location'], MAPBOX_ACCESS_TOKEN)
    if latitude is None or longitude is None:
        return jsonify({'error': 'Unable to obtain coordinates for the given location.'}), 400

    # Add coordinates to data
    data['Latitude'] = latitude
    data['Longitude'] = longitude
    print("Data with coordinates:", data)

    # Preprocessing the data as required by my model
    user_df = preprocess_user_preferences(data, label_encoders, scaler)

    # Ensure user_df columns match those used during model fitting
    print("user_df columns:", user_df.columns)
    print("train_feature_matrix columns:", train_feature_matrix.columns)

    # Add dummy columns for performance_2021, performance_2022, performance_2023
    for col in ['performance_2021', 'performance_2022', 'performance_2023']:
        user_df[col] = 0

    # Reorder columns to match the order in train_feature_matrix
    user_df = user_df[train_feature_matrix.columns]

    # Use the k-NN model to find similar schools
    distances, indices = knn_model.kneighbors(user_df)
    recommended_schools = train_df.iloc[indices[0]]

    # Generate recommendations
    recommendations = recommend_schools_based_on_preferences(recommended_schools, original_df, top_n=10)

    # Converting numpy integers and floats to native Python types
    response = [row.to_dict() for _, row in recommendations.iterrows()]
    return jsonify(response)

def get_coordinates(location, access_token):
    url = f"https://api.mapbox.com/geocoding/v5/mapbox.places/{location}.json"
    params = {'access_token': access_token, 'limit': 1}
    response = requests.get(url, params=params)
    if response.status_code == 200:
        data = response.json()
        if data['features']:
            coordinates = data['features'][0]['geometry']['coordinates']
            return coordinates[1], coordinates[0]  # return (latitude, longitude)
    return None, None

def preprocess_user_preferences(user_preferences, label_encoders, scaler):
    # Encode categorical features
    for feature in ['religion', 'gender', 'boarding/day']:
        if user_preferences[feature] not in label_encoders[feature].classes_:
            label_encoders[feature].classes_ = np.append(label_encoders[feature].classes_, user_preferences[feature])
        user_preferences[feature] = label_encoders[feature].transform([user_preferences[feature]])[0]

    # Create DataFrame for the user preferences
    user_df = pd.DataFrame([user_preferences])
    
    # Remove 'location' column before scaling
    user_df.drop(columns=['location'], inplace=True)

    # Ensure columns are in the correct order and match the training set
    ordered_columns = [col for col in train_feature_matrix.columns if col in user_df.columns]
    user_df = user_df[ordered_columns]

    # Convert all columns to numeric type
    user_df = user_df.apply(pd.to_numeric)

    # Standardize numerical features
    user_df[['performance', 'Latitude', 'Longitude', 'stars']] = scaler.transform(user_df[['performance', 'Latitude', 'Longitude', 'stars']])
    
    return user_df

def calculate_similarity(user_df, feature_matrix):
    extended_feature_matrix = pd.concat([feature_matrix, user_df], ignore_index=True)
    cosine_sim = cosine_similarity(extended_feature_matrix)
    user_sim_scores = cosine_sim[-1, :-1]
    return user_sim_scores

def performance_to_grade(performance):
    if 1 <= performance <= 1.7:
        return "A (Excellent)"
    elif 1.7 <= performance < 2.5:
        return "B (Very Good)"
    elif 2.5 <= performance < 3.6:
        return "C (Good)"
    elif 3.6 <= performance < 4.6:
        return "D (Satisfactory)"
    elif 4.6 <= performance <= 5:
        return "F (Fail)"
    else:
        return "N/A"

def recommend_schools_based_on_preferences(recommended_schools, original_df, top_n=10):
    recommendations = recommended_schools.copy()

    # Print columns of the recommendations dataframe
    print("Recommendations DataFrame columns before merge:", recommendations.columns)

    # Merge recommendations with the original dataframe to get the original performance data
    performance_cols = ['School', 'performance']
    recommendations_with_performance = recommendations.merge(
        original_df[performance_cols], on='School', how='left'
    )
    
    # Print columns of the merged dataframe
    print("Recommendations DataFrame columns after merge:", recommendations_with_performance.columns)

    # Ensure we use the performance from the original dataframe
    recommendations_with_performance['performance'] = recommendations_with_performance['performance_y']
    unique_recommendations = recommendations_with_performance.drop_duplicates(subset=['School']).head(top_n)

    # Add performance grades
    unique_recommendations['performance_grade'] = unique_recommendations['performance'].apply(performance_to_grade)

    return unique_recommendations[['School', 'performance', 'performance_grade']]

if __name__ == '__main__':
    app.run(debug=True)



