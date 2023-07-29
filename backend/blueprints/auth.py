import random
import string

from flask import Blueprint, request, session, g
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.datastructures import ImmutableMultiDict
from flask_mail import Message
from models import *
from .forms import RegisterForm, UpdatePwdForm, LoginForm
from exts import mail, r
from decorators import login_required

bp = Blueprint("auth", __name__, url_prefix="/auth")


@bp.route("/login", methods=["POST"])
def login():
    form = LoginForm(ImmutableMultiDict(request.json))
    if not form.validate():
        return "Wrong email or password!"

    email = form.email.data
    password = form.password.data

    user = UserModel.query.filter_by(email=email).first()
    if user and check_password_hash(user.password, password):
        session["id_user"] = user.id_user
        return "Successfully login!"
    else:
        return "Wrong email or password!"


@bp.route("/update/pwd", methods=["POST"])
def update_pwd():
    form = UpdatePwdForm(ImmutableMultiDict(request.json))
    if not form.validate():
        return form.errors
    user = UserModel.query.filter_by(email=form.email.data).first()
    if user:
        user.password = generate_password_hash(form.password.data)
        db.session.commit()
        return "Success!"
    else:
        return "No user found!"


@bp.route("/register", methods=["POST"])
def register():
    form = RegisterForm(ImmutableMultiDict(request.json))
    if not form.validate():
        if "email" in form.errors:
            return form.errors["email"][0]
        else:
            for key in form.errors:
                return form.errors[key][0]
    email = form.email.data
    username = form.username.data
    password = form.password.data
    user = UserModel(email, username, generate_password_hash(password))
    db.session.add(user)
    db.session.commit()
    return "Successfully register!"

@bp.route("/captcha/test")
def mail_test():
    message = Message(subject="mail testing", recipients=["923681262@qq.com"], body="Mail testing")
    mail.send(message)
    return "Success"

@bp.route("/captcha/get", methods=["POST"])
def get_captcha():
    email = request.json["email"]
    source = string.digits * 4
    captcha = "".join(random.sample(source, 4))

    r.set(email, captcha)

    message = Message(subject="Application captcha", recipients=[email],
                      body="Your captcha is: %s" % captcha)
    mail.send(message)
    return "success"

@bp.route("/scoring/update_preference", methods=["POST"])
@login_required
def update_scoring_preference():
    user = UserModel.query.get(g.user)
    user.prefer_personal = request.json["prefer_personal"] is True
    db.session.commit()
    return user.to_dict()
