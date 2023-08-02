from functools import wraps
from flask import g, request
import datetime
from exts import r


def login_required(func):
    @wraps(func)
    def inner(*args, **kwargs):
        if g.user is None:
            return "Access denied"
        if g.ip is None or g.ip != request.remote_addr or g.ip != r.get(f"{g.user}_ip"):
            return "Access denied"
        if g.duration is None or datetime.datetime.now() > datetime.datetime.fromisoformat(g.duration):
            return "Access denied"
        return func(*args, **kwargs)

    return inner
