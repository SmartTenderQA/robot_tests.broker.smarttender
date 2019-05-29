# -*- coding: utf-8 -*-


import re


def convert_page_values(field, value):
    global ret
    if 'locality' in field or 'postalCode' in field or 'streetAddress' in field:
        list = re.search(u'(?P<code>\d+), (?P<city>\D+,\s\D+), (?P<street>.+)', value)
        if 'locality' in field:
            ret = list.group('city')
            a = re.search(u'(?P<country>\D+), (?P<city>\D+)', ret)
            city = a.group('city')
            ret = city
        elif 'postalCode' in field:
            ret = list.group('code')
        elif 'streetAddress' in field:
            ret = list.group('street')
    elif 'unit' in field or 'quantity' in field:
        list = re.search(u'(?P<quantity>\d+) (?P<unit>.+)', value)
        if 'unit' in field:
            unit = list.group('unit')
            ret = convert_unit(unit)
        elif 'quantity' in field:
            ret = int(list.group('quantity'))
    elif 'amount' in field:
        ret = re.search(u'(?P<amount>[\d\s.?,]+).*', value).group('amount')
        ret = ret.replace(' ', '')
        ret = ret.replace(',', '.')
        ret = float(ret)
    elif 'agreementDuration' in field or 'Number' in field:
        ret = get_only_numbers(value)
    elif 'valueAddedTaxIncluded' in field:
        if 'з ПДВ' in value:
            ret = True
        else:
            ret = False
    else:
        ret = value
    return ret


def get_only_numbers(value):
    date = re.sub(r"\D", "", value)
    return date


def convert_unit(value):
    units_map = {
        u'Гектар': u'га',
        u'час': u'квар - час',
        u'Кубический дециметр': u'дм3',
        u'Кубический километр': u'км3',
        u'Погонный метр': u'п.м.',
        u'Квадратный километр': u'км2',
        u'Киловар - час': u'квар-час',
        u'Квадратный сантиметр': u'см2',
        u'Тысяча килограмм': u'тыс. кг',
        u'Декалитр': u'дал',
        u'Метр квадратный': u'м.кв.'
    }
    if value in units_map:
        result = units_map[value]
    else:
        result = value
    return result