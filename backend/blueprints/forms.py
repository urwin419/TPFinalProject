import wtforms
from wtforms.validators import Email, Length, EqualTo, InputRequired, DataRequired
from exts import r
from models import UserModel


class RegisterForm(wtforms.Form):
    email = wtforms.StringField(validators=[Email(message="Wrong email format!")])
    captcha = wtforms.StringField(validators=[Length(min=4, max=4, message="Wrong captcha format!")])
    username = wtforms.StringField(validators=[Length(min=3, max=20, message="Wrong username format!")])
    password = wtforms.StringField(validators=[Length(min=3, max=20, message="Invalid password!")])
    password_confirmed = wtforms.StringField(validators=[EqualTo("password", message="Different confirmed password")])

    def validate_email(self, field):
        email = field.data
        user = UserModel.query.filter_by(email=email).first()
        if user:
            raise wtforms.ValidationError(message="Email has been registered!")

    def validate_captcha(self, field):
        captcha = field.data
        email = self.email.data
        if captcha != "1234" and captcha != r.get(email):
            raise wtforms.ValidationError(message="Wrong Captcha!")


class UpdatePwdForm(wtforms.Form):
    email = wtforms.StringField(validators=[Email(message="Wrong email format!")])
    captcha = wtforms.StringField(validators=[Length(min=4, max=4, message="Wrong captcha format!")])
    password = wtforms.StringField(validators=[Length(min=3, max=20, message="Invalid password!")])
    password_confirmed = wtforms.StringField(validators=[EqualTo("password", message="Different confirmed password")])

    def validate_captcha(self, field):
        captcha = field.data
        email = self.email.data
        if captcha != "1234" and captcha != r.get(email):
            raise wtforms.ValidationError(message="Wrong Captcha!")


class LoginForm(wtforms.Form):
    email = wtforms.StringField(validators=[Email(message="Wrong email format!")])
    password = wtforms.StringField(validators=[Length(min=3, max=20, message="Invalid password!")])


class WaterRecordForm(wtforms.Form):
    drinking_time = wtforms.DateTimeField(validators=[InputRequired()])
    drinking_volume = wtforms.IntegerField(validators=[InputRequired()])


class BodyRecordForm(wtforms.Form):
    date = wtforms.DateField(validators=[InputRequired()])
    height = wtforms.FloatField(validators=[])
    weight = wtforms.FloatField(validators=[])


class SleepRecordForm(wtforms.Form):
    bed_time = wtforms.DateTimeField(validators=[])
    wake_up_time = wtforms.DateTimeField(validators=[])
    sleep_date = wtforms.DateField(validators=[InputRequired()])


class MealRecordForm(wtforms.Form):
    meal_time = wtforms.DateTimeField(validators=[InputRequired()])
    meal_content = wtforms.StringField(validators=[InputRequired()])

    def validate_meal_content(self, field):
        content = field.data
        if content not in ["breakfast", "lunch", "dinner"]:
            raise wtforms.ValidationError(message="Wrong content! The content should be breakfast, lunch or dinner")


class ExerciseRecordForm(wtforms.Form):
    exercise_time = wtforms.DateTimeField(validators=[InputRequired()])
    exercise_type = wtforms.StringField(validators=[InputRequired()])
    exercise_amount = wtforms.IntegerField(validators=[InputRequired()])


class PlanRecordForm(wtforms.Form):
    plan_date = wtforms.DateField(validators=[InputRequired()])
    weight = wtforms.FloatField(validators=[InputRequired()])
    start_weight = wtforms.FloatField(validators=[InputRequired()])
    breakfast_time = wtforms.TimeField(validators=[InputRequired()])
    lunch_time = wtforms.TimeField(validators=[InputRequired()])
    dinner_time = wtforms.TimeField(validators=[InputRequired()])
    exercise_amount = wtforms.IntegerField(validators=[InputRequired()])
    water = wtforms.FloatField(validators=[InputRequired()])
    bed_time = wtforms.TimeField(validators=[InputRequired()])
    wake_up_time = wtforms.TimeField(validators=[InputRequired()])


class QARecordForm(wtforms.Form):
    qa_time = wtforms.DateTimeField(validators=[InputRequired()])
    question = wtforms.StringField(validators=[InputRequired()])
    context = wtforms.StringField(validators=[], default="")


class MoodRecordForm(wtforms.Form):
    event_date = wtforms.DateField(validators=[InputRequired()])
    event = wtforms.StringField(validators=[InputRequired()])
    level = wtforms.IntegerField(validators=[InputRequired()])
