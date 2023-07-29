import datetime

from flask import Blueprint, request, g, jsonify, make_response
from werkzeug.datastructures import ImmutableMultiDict
from models import *
from decorators import login_required
from .forms import *

bp = Blueprint("record", __name__, url_prefix="/record")


@bp.route("/body", methods=["POST"])
@login_required
def body_record():
    form = BodyRecordForm(ImmutableMultiDict(request.json))
    if not form.validate():
        return form.errors

    id_user = g.user
    date = form.date.data
    height = form.height.data
    weight = form.weight.data

    record = BodyRecordModel.query.filter_by(id_user=id_user, date=date).first()
    if record:
        record.height = height or record.height
        record.weight = weight or record.weight
    else:
        if height is None or weight is None:
            last_record = BodyRecordModel.query.filter_by(id_user=id_user).order_by(BodyRecordModel.date.desc()).first()
            if last_record:
                height = height or last_record.height
                weight = weight or last_record.weight
        record = BodyRecordModel(id_user, date, height, weight)
        db.session.add(record)
    db.session.commit()

    return make_response("success", 200)


@bp.route("/water", methods=["POST"])
@login_required
def water_record():
    form = WaterRecordForm(ImmutableMultiDict(request.json))
    if not form.validate():
        return form.errors

    id_user = g.user
    drinking_time = form.drinking_time.data
    drinking_volume = form.drinking_volume.data

    if not drinking_time:
        drinking_time = datetime.datetime.now()

    record = WaterRecordModel(id_user, drinking_time, drinking_volume)
    db.session.add(record)
    db.session.commit()

    return make_response("success", 200)


@bp.route("/sleep", methods=["POST"])
@login_required
def sleep_record():
    form = SleepRecordForm(ImmutableMultiDict(request.json))
    if not form.validate():
        return form.errors

    id_user = g.user
    bed_time = form.bed_time.data
    wake_up_time = form.wake_up_time.data
    sleep_date = form.sleep_date.data

    record = SleepRecordModel.query.filter_by(id_user=id_user, sleep_date=sleep_date).first()
    if record:
        record.bed_time = bed_time or record.bed_time
        record.wake_up_time = wake_up_time or record.wake_up_time
    else:
        record = SleepRecordModel(id_user, bed_time, wake_up_time, sleep_date)
        db.session.add(record)
    db.session.commit()

    return make_response("success", 200)


@bp.route("/meal", methods=["POST"])
@login_required
def meal_record():
    form = MealRecordForm(ImmutableMultiDict(request.json))
    if not form.validate():
        return form.errors

    id_user = g.user
    meal_date = form.meal_time.data.date()
    meal_content = form.meal_content.data
    meal_time = form.meal_time.data.time()

    record = MealRecordModel.query.filter_by(id_user=id_user, meal_date=meal_date).first()
    if not record:
        record = MealRecordModel(id_user, meal_date)
        db.session.add(record)

    if meal_content == "breakfast":
        record.breakfast_time = meal_time
    elif meal_content == "lunch":
        record.lunch_time = meal_time
    elif meal_content == "dinner":
        record.dinner_time = meal_time

    db.session.commit()

    return make_response("success", 200)


@bp.route("/exercise", methods=["POST"])
@login_required
def exercise_record():
    form = ExerciseRecordForm(ImmutableMultiDict(request.json))
    if not form.validate():
        return form.errors

    id_user = g.user
    exercise_time = form.exercise_time.data
    exercise_type = form.exercise_type.data
    exercise_amount = form.exercise_amount.data

    record = ExerciseRecordModel(id_user, exercise_time, exercise_type, exercise_amount)
    db.session.add(record)
    db.session.commit()

    return make_response("success", 200)


@bp.route("/plan", methods=["POST"])
@login_required
def plan_record():
    try:
        request.json["exercise_amount"] = int(request.json["exercise_amount"])
        request.json["water"] = float(request.json["water"])
        request.json["weight"] = float(request.json["weight"])
        request.json["start_weight"] = float(request.json["start_weight"])
    except Exception:
        return "Please input correct value"

    form = PlanRecordForm(ImmutableMultiDict(request.json))
    if not form.validate():
        return form.errors

    id_user = g.user
    plan_date = form.plan_date.data
    weight = form.weight.data
    start_weight = form.start_weight.data
    breakfast_time = form.breakfast_time.data
    lunch_time = form.lunch_time.data
    dinner_time = form.dinner_time.data
    exercise_amount = form.exercise_amount.data
    water = form.water.data
    bed_time = form.bed_time.data
    wake_up_time = form.wake_up_time.data

    json = {}

    record = PlanRecordModel.query.filter_by(id_user=id_user, plan_date=plan_date).first()
    if record:
        record.weight = weight
        record.start_weight = start_weight
        record.breakfast_time = breakfast_time
        record.lunch_time = lunch_time
        record.dinner_time = dinner_time
        record.exercise_amount = exercise_amount
        record.water = water
        record.bed_time = bed_time
        record.wake_up_time = wake_up_time
    else:
        record = PlanRecordModel(id_user, plan_date, weight, start_weight, breakfast_time, lunch_time, dinner_time,
                                 exercise_amount, water, bed_time, wake_up_time)
        db.session.add(record)
    db.session.commit()

    return make_response("success", 200)


@bp.route("/mood", methods=["POST"])
@login_required
def mood_record():
    form = MoodRecordForm(ImmutableMultiDict(request.json))
    if not form.validate():
        return form.errors

    id_user = g.user
    event_date = form.event_date.data
    event = form.event.data
    level = form.level.data

    record = MoodRecordModel.query.filter_by(id_user=id_user, event_date=event_date).first()
    if record:
        record.event = event
        record.level = level
    else:
        record = MoodRecordModel(id_user, event_date, event, level)
        db.session.add(record)

    db.session.commit()

    return make_response("success", 200)
