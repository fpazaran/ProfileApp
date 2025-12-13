from fastapi import FastAPI
from db.database import db  # Firebase is initialized on import

app = FastAPI()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)