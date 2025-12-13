import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase
cred = credentials.Certificate("./ServiceAccountKey.json")
firebase_admin.initialize_app(cred)

# Firestore client - import this wherever you need DB access
db = firestore.client()
