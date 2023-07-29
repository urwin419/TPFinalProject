from functools import wraps
from flask import g


def login_required(func):
    @wraps(func)
    def inner(*args, **kwargs):
        if g.user:
            return func(*args, **kwargs)
        else:
            return "Accessed denied"

    return inner
