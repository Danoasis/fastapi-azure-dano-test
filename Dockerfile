FROM python:3.12-slim
# Base official image for python for a ligther version
WORKDIR /app
# Sets the work directory inside of the container where the files will be copied
COPY requirements.txt .
# Copies the requirements.txt to the WORKDIR to install dependencies
RUN pip install --no-cache-dir -r requirements.txt
# Installs the dependencies from the projecto in to the container
COPY . . 
# Copies the rest of the files from the project including the main.py inside the container
EXPOSE 8000
# Exposes the port 8000 to receive HTTP requests from outside the container
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
# Command that executes when the container is first executed
# uvicorn ejecuta la app FastAPI
# 0.0.0.0 allows access from outside the server
# port 8000 is where the API answers the requests