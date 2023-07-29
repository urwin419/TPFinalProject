import datetime

from models import *
from .scoring import *


def get_daily_water(id_user, date):
    records = WaterRecordModel.query.filter_by(id_user=id_user). \
        filter(WaterRecordModel.drinking_time >= date,
               WaterRecordModel.drinking_time < date + datetime.timedelta(days=1)).all()
    return sum([record.drinking_volume for record in records])


def get_week_exercise(id_user, date):
    week_start = get_week_start(date)
    records = ExerciseRecordModel.query.filter_by(id_user=id_user). \
        filter(ExerciseRecordModel.exercise_time >= week_start,
               ExerciseRecordModel.exercise_time < week_start + datetime.timedelta(weeks=1)).all()
    return sum([record.exercise_amount for record in records])


def get_daily_sleep_amount(id_user, date):
    record = SleepRecordModel.query.filter_by(id_user=id_user, sleep_date=date).first()
    if not record or not record.bed_time or not record.wake_up_time:
        return 0
    diff = get_second(record.wake_up_time.time()) - get_second(record.bed_time.time())
    if diff < 0:
        diff += 3600 * 24
    return diff


def get_is_regular_meal(id_user, date):
    record = MealRecordModel.query.filter_by(id_user=id_user, meal_date=date).first()
    if record is None or record.breakfast_time is None or record.lunch_time is None or record.dinner_time is None:
        return False
    if abs(get_second(record.breakfast_time) - 8 * 3600) > 3600 or \
            abs(get_second(record.lunch_time) - 12 * 3600) > 3600 or \
            abs(get_second(record.dinner_time) - 18.5 * 3600) > 3600:
        return False
    return True


def get_achieved_target_weight(id_user, date):
    record = BodyRecordModel.query.filter_by(id_user=id_user, date=date). \
        filter(BodyRecordModel.date <= date). \
        order_by(BodyRecordModel.date.desc()).first()
    target = PlanRecordModel.query.filter_by(id_user=id_user, plan_date=date). \
        filter(PlanRecordModel.plan_date <= date). \
        order_by(PlanRecordModel.plan_date.desc()).first()
    if not record or not target:
        return False

    return abs(record.weight - target.weight) < 1


def get_week_health_score(id_user, week, plan):
    health_scores = {"week_start": week, "water": 0.0, "exercise": 0.0, "sleep": 0.0, "meal": 0.0, "bmi": 0.0}
    next_week = week + datetime.timedelta(weeks=1)

    # bmi
    record = BodyRecordModel.query.filter_by(id_user=id_user). \
        filter(BodyRecordModel.date <= week).order_by(BodyRecordModel.date.desc()).first()
    if record:
        bmi = record.to_dict()["BMI"]
        if 18.5 <= bmi < 24:
            health_scores["bmi"] = 100
        elif bmi > 28:
            health_scores["bmi"] = 60
        else:
            health_scores["bmi"] = 80

    # water
    records = WaterRecordModel.query.filter_by(id_user=id_user). \
        filter(WaterRecordModel.drinking_time >= week, WaterRecordModel.drinking_time < next_week).all()

    water_volumes = {}
    for record in records:
        drinking_date = record.drinking_time.date().isoformat()
        if drinking_date not in water_volumes:
            water_volumes[drinking_date] = 0
        water_volumes[drinking_date] += record.drinking_volume

    for drinking_date in water_volumes:
        health_scores["water"] += get_water_score(water_volume=water_volumes[drinking_date], expected_volume=plan.water)
    health_scores["water"] /= 7

    # exercise
    records = ExerciseRecordModel.query.filter_by(id_user=id_user). \
        filter(ExerciseRecordModel.exercise_time >= week, ExerciseRecordModel.exercise_amount < next_week).all()
    health_scores["exercise"] += get_exercise_score(exercise_amount=sum([record.exercise_amount for record in records]),
                                                    expected_amount=plan.exercise_amount)

    # sleep
    records = SleepRecordModel.query.filter_by(id_user=id_user). \
        filter(SleepRecordModel.sleep_date >= week, SleepRecordModel.sleep_date < next_week).all()

    for record in records:
        health_scores["sleep"] += get_sleep_score(
            sleep_time={
                "bed_time": record.bed_time,
                "wake_up_time": record.wake_up_time
            },
            expected_time={
                "bed_time": plan.bed_time,
                "wake_up_time": plan.wake_up_time
            })
    health_scores["sleep"] /= 7

    # meal
    records = MealRecordModel.query.filter_by(id_user=id_user). \
        filter(MealRecordModel.meal_date >= week, MealRecordModel.meal_date < next_week).all()
    for record in records:
        health_scores["meal"] += get_meal_score(
            meal_time={
                "breakfast": record.breakfast_time,
                "lunch": record.lunch_time,
                "dinner": record.dinner_time
            },
            expected_time={
                "breakfast": plan.breakfast_time,
                "lunch": plan.lunch_time,
                "dinner": plan.dinner_time
            }
        )

    health_scores["meal"] /= 7

    score_ratio = {"water": 0.2, "exercise": 0.2, "sleep": 0.2, "meal": 0.2, "bmi": 0.2}
    health_scores["total_score"] = sum([score_ratio[key] * health_scores[key] for key in score_ratio])
    return health_scores
