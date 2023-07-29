import datetime


def get_week_start(date: datetime.date):
    return date - datetime.timedelta(days=date.weekday())


def get_second(t: datetime.time):
    return 3600 * t.hour + 60 * t.minute + t.second


def get_water_score(water_volume: int, expected_volume=2000):
    return min(water_volume, expected_volume) / expected_volume * 100


def get_exercise_score(exercise_amount: int, expected_amount=150):
    return min(exercise_amount, expected_amount) / expected_amount * 100


def get_sleep_score(sleep_time: dict, expected_time: dict):
    # print(sleep_time, expected_time)
    expected_diff = get_second(expected_time["wake_up_time"]) - get_second(expected_time["bed_time"])
    if expected_diff < 0:
        expected_diff += 3600 * 24

    wake_up_time = sleep_time["wake_up_time"] if sleep_time["wake_up_time"] else expected_time["wake_up_time"]
    bed_time = sleep_time["bed_time"] if sleep_time["bed_time"] else expected_time["bed_time"]
    diff = get_second(wake_up_time) - get_second(bed_time)
    if diff < 0:
        diff += 3600 * 24

    return min(diff, expected_diff) / expected_diff * 100


def get_meal_score(meal_time: dict, expected_time: dict):
    # print(meal_time, expected_time)
    score = 0
    for meal in meal_time:
        if meal_time[meal] is None:
            continue
        p = meal_time[meal].hour * 60 + meal_time[meal].minute
        q = expected_time[meal].hour * 60 + expected_time[meal].minute
        diff = abs(p - q)
        # at least 60 at diff 2 hours, score starts to decrease when diff = 30
        if diff < 30:
            score += 100
        elif diff > 120:
            score += 60
        else:
            score += 100 - (diff - 30) / 9 * 4
    return score / 3
