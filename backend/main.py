# from fastapi import FastAPI
# from fastapi.middleware.cors import CORSMiddleware
# from fastapi.staticfiles import StaticFiles
# import os

# app = FastAPI(title="Man U Store API")

# if not os.path.exists("static/images"):
#     os.makedirs("static/images")

# # Mount the static folder
# app.mount("/static", StaticFiles(directory="static"), name="static")


# from fastapi.middleware.cors import CORSMiddleware

# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"], # In production, replace "*" with your domain
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# from api.register import *

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os


UPLOAD_DIR = "static/products"
if not os.path.exists(UPLOAD_DIR):
    os.makedirs(UPLOAD_DIR)

app = FastAPI(title="Man U Store API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True, 
    allow_methods=["*"],
    allow_headers=["*"],
)


app.mount("/static", StaticFiles(directory="static"), name="static")


from api.register import *

@app.get("/")
def root():
    return {"message": "GGMU! The Manchester United Store API is live."}