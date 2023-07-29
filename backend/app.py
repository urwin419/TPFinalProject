from flask import Flask, session, g

import config
from blueprints.auth import bp as auth_bp
from blueprints.query import bp as query_bp
from blueprints.record import bp as record_bp
from blueprints.test import bp as test_bp
from models import *
from exts import mail

app = Flask(__name__)
app.config.from_object(config)

db.init_app(app)
mail.init_app(app)

with app.app_context():
    db.create_all()

app.register_blueprint(auth_bp)
app.register_blueprint(query_bp)
app.register_blueprint(record_bp)
app.register_blueprint(test_bp)


@app.before_request
def before_request():
    id_user = session.get("id_user")
    setattr(g, "user", session.get(UserModel, id_user) if id_user else None)


if __name__ == '__main__':
    app.run(host='0.0.0.0', ssl_context="adhoc", port=23718)
    # app.run(host='0.0.0.0', debug=False, ssl_context=('cert.pem', 'key.pem'))
