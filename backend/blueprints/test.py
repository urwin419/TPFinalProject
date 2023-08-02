from blueprints.scoring import *
from flask import Blueprint, request, make_response, session, g, jsonify

bp = Blueprint("testing", __name__, url_prefix="/test")

@bp.route("/water_score", methods=["GET"])
def test_water_score():
    json = request.json
    score = get_water_score(json["water_volume"], json["expected_volume"])
    return str(score)

@bp.route("/exercise_score", methods=["GET"])
def test_exercise_score():
    json = request.json
    score = get_exercise_score(json["exercise_amount"], json["expected_amount"])
    return str(score)

@bp.route("/sleep_score", methods=["GET"])
def test_sleep_score():
    json = request.json
    for t in json["sleep_time"]:
        json["sleep_time"][t] = datetime.datetime.fromisoformat(json["sleep_time"][t])
    score = get_sleep_score(json["sleep_time"], json["expected_time"])
    return str(score)

@bp.route("/meal_score", methods=["GET"])
def test_meal_score():
    json = request.json
    for key in json:
        for meal in json[key]:
            json[key][meal] = datetime.time.fromisoformat(json[key][meal])
    score = get_meal_score(json["meal_time"], json["expected_time"])
    return str(score)

