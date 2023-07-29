import datetime

week_data = {
    "username": "user1",
    "weight": [80, 80, 79, 78, 78, 77, 77],  # 一周七天每日体重
    "breakfast_time": [datetime.time(hour=8), datetime.time(hour=7, minute=30), datetime.time(hour=8),
                       datetime.time(hour=8, minute=30), datetime.time(hour=8), datetime.time(hour=7, minute=30),
                       datetime.time(hour=8)],  # 一周七天的早餐时间
    "lunch_time": [datetime.time(hour=12), datetime.time(hour=12, minute=15), datetime.time(hour=12),
                   datetime.time(hour=11, minute=30), datetime.time(hour=12), datetime.time(hour=12, minute=30),
                   datetime.time(hour=12)],  # 一周七天的午餐时间
    "dinner_time": [datetime.time(hour=18), datetime.time(hour=18, minute=30), datetime.time(hour=18),
                    datetime.time(hour=17, minute=30), datetime.time(hour=18), datetime.time(hour=18, minute=50),
                    datetime.time(hour=17, minute=45)],  # 一周七天的晚餐时间
    "exercise_amount": 210,  # 一周运动总时长
    "water": [1600, 1800, 2200, 2000, 2500, 1900, 2100],  # 一周七天每日饮水
    "bed_time": [datetime.time(hour=23), datetime.time(hour=0, minute=30), datetime.time(hour=23, minute=45),
                 datetime.time(hour=0), datetime.time(hour=24), datetime.time(hour=0, minute=5),
                 datetime.time(hour=23, minute=55)],  # 一周七天的入睡时间
    "wake_up_time": [datetime.time(hour=7), datetime.time(hour=7, minute=30), datetime.time(hour=6, minute=45),
                     datetime.time(hour=7), datetime.time(hour=7), datetime.time(hour=9, minute=5),
                     datetime.time(hour=8, minute=55)]  # 一周七天的起床时间
}

week_plan = {
    "username": "user1",
    "weight": 70,  # 目标体重
    "breakfast_time": datetime.time(hour=8),  # 目标早餐时间
    "lunch_time": datetime.time(hour=12),  # 目标午餐时间
    "dinner_time": datetime.time(hour=18),  # 目标晚餐时间
    "exercise_amount": 150,  # 目标每周运动时长
    "water": 2000,  # 目标每日饮水
    "bed_time": datetime.time(hour=23),  # 目标入睡时间
    "wake_up_time": datetime.time(hour=7)  # 目标起床时间
}


def get_report(week_data, week_plan):
    """
    input:
    week_data: dict, the content and structure is shown above
    week_plan: dict, the content and structure is shown above

    output:
    report: str, generated report
    """
    report = ""

    # generate report below

    return report


if __name__ == '__main__':
    print(get_report(week_data, week_plan))
