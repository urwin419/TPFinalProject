from exts import db
import datetime


class UserModel(db.Model):
    __tablename__ = 'user'
    id_user = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(100), unique=True, nullable=False)
    username = db.Column(db.String(20), nullable=False)
    password = db.Column(db.String(200), nullable=False)
    prefer_personal = db.Column(db.Boolean)

    def __init__(self, email, username, password):
        self.email = email
        self.username = username
        self.password = password
        self.prefer_personal = False

    def to_dict(self, json=False):
        return {
            "email": self.email,
            "username": self.username,
            "prefer_personal": self.prefer_personal
        }


class BodyRecordModel(db.Model):
    __tablename__ = 'bodyrecord'
    id = db.Column(db.Integer, primary_key=True)
    id_user = db.Column(db.Integer)
    date = db.Column(db.Date())
    height = db.Column(db.Float())
    weight = db.Column(db.Float())

    def __init__(self, id_user, date, height, weight):
        self.id_user = id_user
        self.date = date
        self.height = height
        self.weight = weight

    def to_dict(self, json=False):
        return {
            "date": str(self.date) if json else self.date,
            "height": self.height,
            "weight": self.weight,
            "BMI": round(self.weight / ((self.height / 100) ** 2), 1) if self.weight and self.height else 0
        }


class ExerciseRecordModel(db.Model):
    __tablename__ = 'exerciserecord'
    id = db.Column(db.Integer, primary_key=True)
    id_user = db.Column(db.Integer)
    exercise_time = db.Column(db.DateTime())
    exercise_type = db.Column(db.String(45))
    exercise_amount = db.Column(db.Integer)

    def __init__(self, id_user, exercise_time, exercise_type, exercise_amount):
        self.id_user = id_user
        self.exercise_time = exercise_time
        self.exercise_type = exercise_type
        self.exercise_amount = exercise_amount

    def to_dict(self, json=False):
        return {
            "exercise_time": str(self.exercise_time) if json else self.exercise_time,
            "exercise_type": self.exercise_type,
            "exercise_amount": self.exercise_amount
        }


class MealRecordModel(db.Model):
    __tablename__ = 'mealrecord'
    id = db.Column(db.Integer, primary_key=True)
    id_user = db.Column(db.Integer)
    meal_date = db.Column(db.Date())
    breakfast_time = db.Column(db.Time())
    lunch_time = db.Column(db.Time())
    dinner_time = db.Column(db.Time())

    def __init__(self, id_user, meal_date):
        self.id_user = id_user
        self.meal_date = meal_date

    def to_dict(self, json=False):
        return {
            "meal_date": str(self.meal_date) if json and self.meal_date else self.meal_date,
            "breakfast_time": str(self.breakfast_time) if json and self.breakfast_time else self.breakfast_time,
            "lunch_time": str(self.lunch_time) if json and self.lunch_time else self.lunch_time,
            "dinner_time": str(self.dinner_time) if json and self.dinner_time else self.dinner_time,
        }


class SleepRecordModel(db.Model):
    __tablename__ = 'sleeprecord'
    id = db.Column(db.Integer, primary_key=True)
    id_user = db.Column(db.Integer)
    sleep_date = db.Column(db.Date())
    bed_time = db.Column(db.DateTime())
    wake_up_time = db.Column(db.DateTime())

    def __init__(self, id_user, bed_time, wake_up_time, sleep_date):
        self.id_user = id_user
        self.bed_time = bed_time
        self.wake_up_time = wake_up_time
        self.sleep_date = sleep_date

    def to_dict(self, json=False):
        return {
            "sleep_date": str(self.sleep_date) if json and self.sleep_date else self.sleep_date,
            "bed_time": str(self.bed_time) if json and self.bed_time else self.bed_time,
            "wake_up_time": str(self.wake_up_time) if json and self.wake_up_time else self.wake_up_time
        }


class WaterRecordModel(db.Model):
    __tablename__ = 'waterrecord'
    id = db.Column(db.Integer, primary_key=True)
    id_user = db.Column(db.Integer)
    drinking_time = db.Column(db.DateTime())
    drinking_volume = db.Column(db.Integer())

    def __init__(self, id_user, drinking_time, drinking_volume):
        self.id_user = id_user
        self.drinking_time = drinking_time
        self.drinking_volume = drinking_volume

    def to_dict(self, json=False):
        return {
            "drinking_time": str(self.drinking_time) if json else self.drinking_time,
            "drinking_volume": self.drinking_volume
        }


class PlanRecordModel(db.Model):
    __tablename__ = 'planrecord'
    id = db.Column(db.Integer, primary_key=True)
    id_user = db.Column(db.Integer)
    plan_date = db.Column(db.Date())
    weight = db.Column(db.Float())
    start_weight = db.Column(db.Float())
    breakfast_time = db.Column(db.Time())
    lunch_time = db.Column(db.Time())
    dinner_time = db.Column(db.Time())
    exercise_amount = db.Column(db.Integer)
    water = db.Column(db.Float())
    bed_time = db.Column(db.Time())
    wake_up_time = db.Column(db.Time())

    def __init__(self, id_user, plan_date, weight, start_weight, breakfast_time, lunch_time, dinner_time,
                 exercise_amount, water, bed_time, wake_up_time):
        self.id_user = id_user
        self.plan_date = plan_date
        self.weight = weight
        self.start_weight = start_weight
        self.breakfast_time = breakfast_time
        self.lunch_time = lunch_time
        self.dinner_time = dinner_time
        self.exercise_amount = exercise_amount
        self.water = water
        self.bed_time = bed_time
        self.wake_up_time = wake_up_time

    def to_dict(self, json=False):
        return {
            "plan_date": str(self.plan_date) if json else self.plan_date,
            "weight": self.weight,
            "start_weight": self.start_weight,
            "breakfast_time": str(self.breakfast_time) if json else self.breakfast_time,
            "lunch_time": str(self.lunch_time) if json else self.lunch_time,
            "dinner_time": str(self.dinner_time) if json else self.dinner_time,
            "exercise_amount": self.exercise_amount,
            "water": self.water,
            "bed_time": str(self.bed_time) if json else self.bed_time,
            "wake_up_time": str(self.wake_up_time) if json else self.wake_up_time,
        }


class QARecordModel(db.Model):
    __tablename__ = 'qarecord'
    id = db.Column(db.Integer, primary_key=True)
    id_user = db.Column(db.Integer)
    qa_time = db.Column(db.DateTime())
    with_context = db.Column(db.Boolean)
    question = db.Column(db.String(500), nullable=False)
    context = db.Column(db.String(500))
    answer = db.Column(db.String(500))

    def __init__(self, id_user, qa_time, with_context, question, context, answer):
        self.id_user = id_user
        self.qa_time = qa_time
        self.with_context = with_context
        self.question = question
        self.context = context
        self.answer = answer

    def to_dict(self, json=False):
        return {
            "qa_time": str(self.qa_time) if json else self.qa_time,
            "with_context": self.with_context,
            "question": self.question,
            "context": self.context,
            "answer": self.answer
        }


class MoodRecordModel(db.Model):
    __tablename__ = 'moodrecord'
    id = db.Column(db.Integer, primary_key=True)
    id_user = db.Column(db.Integer)
    event_date = db.Column(db.DateTime(), nullable=False)
    event = db.Column(db.String(500), nullable=False)
    level = db.Column(db.Integer, nullable=False)

    def __init__(self, id_user, event_date, event, level):
        self.id_user = id_user
        self.event_date = event_date
        self.event = event
        self.level = level

    def to_dict(self, json=False):
        return {
            "event_date": str(self.event_date) if json else self.event_date,
            "event": self.event,
            "level": self.level
        }


record_dict = {
    "water": WaterRecordModel,
    "body": BodyRecordModel,
    "exercise": ExerciseRecordModel,
    "meal": MealRecordModel,
    "sleep": SleepRecordModel,
    "plan": PlanRecordModel,
    "qa": QARecordModel,
    "mood": MoodRecordModel
}

time_dict = {
    "water": WaterRecordModel.drinking_time,
    "body": BodyRecordModel.date,
    "exercise": ExerciseRecordModel.exercise_time,
    "meal": MealRecordModel.meal_date,
    "sleep": SleepRecordModel.sleep_date,
    "plan": PlanRecordModel.plan_date,
    "qa": QARecordModel.qa_time,
    "mood": MoodRecordModel.event_date
}

default_plan = PlanRecordModel(id_user=-1, plan_date="1990-01-01", weight=0, start_weight=0,
                               breakfast_time=datetime.time(hour=8), lunch_time=datetime.time(hour=12),
                               dinner_time=datetime.time(hour=18), exercise_amount=150, water=2000,
                               bed_time=datetime.time(hour=23), wake_up_time=datetime.time(hour=7))
