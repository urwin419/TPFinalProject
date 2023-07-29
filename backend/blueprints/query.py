from flask import Blueprint, request, make_response, session, g, jsonify
from werkzeug.datastructures import ImmutableMultiDict

from models import *
from .statistic import *
from decorators import login_required
from blueprints.scoring import *
import datetime
from .forms import QARecordForm
from exts import r

bp = Blueprint("query", __name__, url_prefix="/query")


@bp.route("/user", methods=["GET"])
@login_required
def query_user():
    user = UserModel.query.get(g.user)
    return jsonify(user.to_dict())


@bp.route("/record", methods=["GET"])
@login_required
def query_record():
    record_type = request.args.get("record_type")
    latest = request.args.get("latest") == "True"
    if record_type not in record_dict:
        return "Record type should be in {list(record_dict.keys())}"
    id_user = g.user

    record_model, sorted_dimension = record_dict[record_type], time_dict[record_type]
    if latest:
        record = record_model.query.filter_by(id_user=id_user).order_by(sorted_dimension.desc()).first()
        json = {"record": record.to_dict(json=True)}
    else:
        if request.args.get("date"):
            date = datetime.date.fromisoformat(request.args.get("date"))
            records = record_model.query.filter_by(id_user=id_user). \
                filter(time_dict[record_type] >= date, time_dict[record_type] < date + datetime.timedelta(days=1)). \
                order_by(sorted_dimension.desc()).all()
        else:
            records = record_model.query.filter_by(id_user=id_user).order_by(sorted_dimension.desc()).all()
        json = {"records": [record.to_dict(json=True) for record in records]}

    return jsonify(json)


@bp.route("/daily_record", methods=["GET"])
@login_required
def query_daily_records():
    date = request.args.get("date")
    try:
        date = datetime.date.fromisoformat(date) if date else datetime.date.today()
    except Exception:
        return make_response("please input correct date", 200)
    id_user = g.user
    json = {}
    for record_type in record_dict:
        if record_type == "qa":
            continue
        record_model, sorted_column = record_dict[record_type], time_dict[record_type]
        records = record_model.query.filter_by(id_user=id_user). \
            filter(time_dict[record_type] >= date, time_dict[record_type] < date + datetime.timedelta(days=1)). \
            order_by(sorted_column.desc()).all()
        json[record_type] = [record.to_dict(json=True) for record in records]

    return jsonify(json)


@bp.route("/latest_record", methods=["GET"])
@login_required
def query_latest_records():
    id_user = g.user
    json = {}
    for record_type in record_dict:
        if record_type == "qa":
            continue
        record_model, sorted_column = record_dict[record_type], time_dict[record_type]
        record = record_model.query.filter_by(id_user=id_user).order_by(sorted_column.desc()).first()
        json[record_type] = record.to_dict(json=True) if record else None

    return jsonify(json)


@bp.route("/qa_history", methods=["GET"])
@login_required
def query_qa_history():
    n = request.args.get("num")
    if not n:
        n = 1
    with_context = request.args.get("with_context") == "True"
    print(with_context)
    id_user = g.user

    records = QARecordModel.query.filter_by(id_user=id_user, with_context=with_context). \
        order_by(QARecordModel.qa_time.desc()).limit(n).all()

    return jsonify({"history": [record.to_dict(json=True) for record in records]})


@bp.route("/daily_water", methods=["GET"])
@login_required
def query_daily_water():
    try:
        date = datetime.date.fromisoformat(request.args.get("date"))
    except Exception:
        return "Wrong date format"

    id_user = g.user

    result = {
        "date": request.args.get("date"),
        "daily_water": get_daily_water(id_user, date)
    }
    return jsonify(result)


@bp.route("/week_exercise", methods=["GET"])
@login_required
def query_week_exercise():
    try:
        date = datetime.date.fromisoformat(request.args.get("date"))
        week_start = get_week_start(date)
    except Exception:
        return "Wrong date format"

    id_user = g.user

    result = {
        "week_start": week_start.isoformat(),
        "week_exercise_amount": get_week_exercise(id_user, date)
    }
    return jsonify(result)


@bp.route("/health_scores", methods=["GET"])
@login_required
def query_health_scores():
    try:
        date = datetime.date.fromisoformat(request.args.get("date"))
    except Exception:
        return "Wrong date format"
    id_user = g.user

    user = UserModel.query.get(g.user)
    plan = PlanRecordModel.query.filter_by(id_user=id_user).order_by(PlanRecordModel.plan_date.desc()).first()
    if not plan or not user.prefer_personal:
        plan = default_plan

    health_scores = {}
    week = get_week_start(date)
    for _ in range(5):
        health_scores[week.isoformat()] = get_week_health_score(id_user, week, plan)
        week -= datetime.timedelta(weeks=1)

    return jsonify(health_scores)


@bp.route("/NLP_QA", methods=["POST"])
@login_required
def nlp_qa():
    form = QARecordForm(ImmutableMultiDict(request.json))
    if not form.validate():
        return form.errors

    id_user = g.user
    qa_time = form.qa_time.data
    question = form.question.data
    context = form.context.data
    with_context = len(context) > 0

    record = QARecordModel.query.filter_by(id_user=id_user).order_by(QARecordModel.qa_time.desc()).first()
    if record and record.answer is None:
        return make_response("please wait for the answer of previous question", 200)

    record = QARecordModel(id_user, qa_time, with_context, question, context, None)
    db.session.add(record)
    db.session.commit()

    r.lpush("question_queue", record.id)

    return make_response("success", 200)


@bp.route("/achievement", methods=["GET"])
@login_required
def query_achievement():
    try:
        date = datetime.date.fromisoformat(request.args.get("date"))
    except Exception:
        return "Wrong date format"
    id_user = g.user

    json = {"water achievement": {"Water droplets": 0, "Water flower": 0, "Undersea starry sky": 0},
            "exercise achievement": {"Initial entry": 0, "Heat crusher": 0, "Fitness expert": 0},
            "sleep achievement": {"Moonlight": 0, "Moon Bay": 0, "Accompanied by the moon": 0},
            "meal achievement": {"Regular diet": 0, "Healthy Dietitian": 0, "Master of Diet Manager": 0},
            "weight achievement": {"Good figure achievement": 0, "Self-discipline": 0,
                                   "Master of Figure Management": 0},
            "health score achievement": {"Bronze": 0, "Silver": 0, "Gold": 0, "Crown": 0, "Challenger": 0}}

    # health score achievement

    user = UserModel.query.get(g.user)
    plan = PlanRecordModel.query.filter_by(id_user=id_user).order_by(PlanRecordModel.plan_date.desc()).first()
    if not plan or not user.prefer_personal:
        plan = default_plan

    week = get_week_start(date)
    i = 0
    while i < 7:
        week -= datetime.timedelta(weeks=1)
        health_scores = get_week_health_score(id_user, week, plan)
        if health_scores["total_score"] < 80:
            break
        i += 1
    if i >= 6:
        json["health score achievement"]["Challenger"] = 1
    elif i >= 4:
        json["health score achievement"]["Crown"] = 1
    elif i >= 3:
        json["health score achievement"]["Gold"] = 1
    elif i >= 2:
        json["health score achievement"]["Silver"] = 1
    elif i >= 1:
        json["health score achievement"]["Bronze"] = 1

    # water achievement
    i = 0
    while i < 7:
        volume = get_daily_water(id_user, date - datetime.timedelta(days=i + 1))
        if volume < 1500:
            break
        i += 1
    if i >= 7:
        json["water achievement"]["Undersea starry sky"] = 1
    elif i >= 3:
        json["water achievement"]["Water flower"] = 1
    elif i >= 1:
        json["water achievement"]["Water droplets"] = 1

    # exercise achievement
    i = 0
    while i < 4:
        exercise_time = get_week_exercise(id_user, date - datetime.timedelta(weeks=i + 1))
        if exercise_time < 150:
            break
        i += 1
    if i >= 4:
        json["exercise achievement"]["Fitness expert"] = 1
    elif i >= 2:
        json["exercise achievement"]["Heat crusher"] = 1
    elif i >= 1:
        json["exercise achievement"]["Initial entry"] = 1

    # sleep achievement
    i = 0
    while i < 7:
        sleep_time = get_daily_sleep_amount(id_user, date - datetime.timedelta(days=i + 1))
        if sleep_time / 3600 < 7:
            break
        i += 1
    if i >= 7:
        json["sleep achievement"]["Accompanied by the moon"] = 1
    elif i >= 3:
        json["sleep achievement"]["Moon Bay"] = 1
    elif i >= 1:
        json["sleep achievement"]["Moonlight"] = 1

    # meal achievement
    i = 0
    while i < 7:
        if not get_is_regular_meal(id_user, date - datetime.timedelta(days=i + 1)):
            break
        i += 1
    if i >= 7:
        json["meal achievement"]["Master of Diet Management"] = 1
    elif i >= 3:
        json["meal achievement"]["Healthy Dietitian"] = 1
    elif i >= 1:
        json["meal achievement"]["Regular diet"] = 1

    # weight achievement
    i = 0
    while i < 7:
        if not get_achieved_target_weight(id_user, date - datetime.timedelta(days=i + 1)):
            break
        i += 1
    if i >= 7:
        json["weight achievement"]["Master of Figure Management"] = 1
    elif i >= 3:
        json["weight achievement"]["Self-discipline"] = 1
    elif i >= 1:
        json["weight achievement"]["Good figure achievement"] = 1

    return jsonify(json)
