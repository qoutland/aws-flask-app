from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello_world():
    return "<h1>Hello, World!</h1></br><p>This is my flask app running on aws ecs fargate.</p>"