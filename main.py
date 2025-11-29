from fastapi import FastAPI 
# Imports FastAPI class from framework to create the webapp

app = FastAPI() 
# Create an instance of the FastAPI app that will handle the endpoint/requests

@app.get("/")
# Defines a GET route on the root endpoint "/"
def root():
    # Declares a function called root that will execute when a client makes a GET / request
    return {
        # Returns a dictionary as a response to client (FastAPI converts it to a JSON)
        "message:", "API running on Azure with FastAPI + Docker + Terraform!"
    } 
