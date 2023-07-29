from flask_sqlalchemy import SQLAlchemy
from flask_mail import Mail
import redis

db = SQLAlchemy()
mail = Mail()
r = redis.StrictRedis(host='localhost', port=6379, db=0, decode_responses=True)
