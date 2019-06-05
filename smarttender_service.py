# -*- coding: utf-8 -*-


import re
import requests


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
        list = re.search(u'(?P<quantity>\d+.\d+) (?P<unit>.+)', value)
        unit = list.group('unit')
        if 'unit.code' in field:
            ret = convert_unit_code(unit)
        elif 'unit.name' in field:
            ret = convert_unit_name(unit)
        elif 'quantity' in field:
            ret = list.group('quantity')
            if '.' in ret:
                ret = float(ret)
            else:
                ret = int(ret)
    elif 'amount' in field:
        ret = re.search(u'(?P<amount>[\d\s.?,]+).*', value).group('amount')
        ret = ret.replace(' ', '')
        ret = ret.replace(',', '.')
        ret = float(ret)
    elif 'agreementDuration' in field or 'Number' in field:
        ret = get_only_numbers(value)
    elif 'currency' in field:
        ret = value.replace(' ', '').replace('.', '')
        ret = convert_currency(ret)
    elif 'valueAddedTaxIncluded' in field:
        if u'з ПДВ' in value:
            ret = True
        else:
            ret = False
    else:
        ret = value
    return ret


def convert_plan_page_values(field, value):
    global ret
    if 'unit' in field or 'quantity' in field:
        text = re.search(u'(?P<quantity>\d+.\d+) (?P<unit>.+)', value)
        if 'unit' in field:
            unit = text.group('unit')
            if 'unit.code' in field:
                ret = convert_unit_code(unit)
            elif 'unit.name' in field:
                ret = convert_unit_name(unit)
        elif 'quantity' in field:
            quantity = text.group('quantity')
            if "." in quantity:
                ret = float(text.group('quantity'))
            else:
                ret = int(text.group('quantity'))
    elif 'classification.scheme' in field:
        ret = re.search(u'(\W+\d+)', value).group(0)
    else:
        ret = value
    return ret


def get_only_numbers(value):
    date = re.sub(r"\D", "", value)
    return date


def convert_unit_code(value):
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
        u'Метр квадратный': u'м.кв.',
        u'Штука': u'H87',
        u'штука': u'H87',
        u'штуки': u'H87',
        u'Упаковка': u'PK',
        u'Флакон': u'VI',
        u'Набір(товару)': u'SET',
        u'набір': u'SET',
        u'лот': u'LO'
    }
    if value in units_map:
        result = units_map[value]
    else:
        result = value
    return result


def convert_unit_name(value):
    units_map = {
        u'Штука': u'штуки',
        u'Упаковка': u'упаковка',
        u'Флакон': u'Флакон',
        u'Набір(товару)': u'набір'
    }
    if value in units_map:
        result = units_map[value]
    else:
        result = value.lower()
    return result


def convert_procurementMethodType(value):
    method_types = {
        u'belowThreshold': u'Допорогові закупівлі',
        u'aboveThresholdUA': u'Відкриті торги',
        u'aboveThresholdEU': u'Відкриті торги з публікацією англійською мовою',
        u'reporting': u'Звіт про укладений договір',
        u'negotiation': u'Переговорна процедура',
        u'negotiation.quick': u'Переговорна процедура (скорочена)',
        u'aboveThresholdUA.defense': u'Переговорна процедура для потреб оборони',
        u'esco': u'Відкриті торги для закупівлі енергосервісу',
        u'belowThresholdRFP': u'Запит цінових пропозицій',
        u'aboveThresholdTS': u'Двохетапний тендер',
        u'competitiveDialogueUA.stage2': u'Конкурентний діалог 2-ий етап',
        u'competitiveDialogueEU.stage2': u'Конкурентний діалог з публікацією англійською мовою 2-ий етап',
        u'competitiveDialogueUA': u'Конкурентний діалог 1-ий етап',
        u'competitiveDialogueEU': u'Конкурентний діалог з публікацією англійською мовою 1-ий етап',
        u'closeFrameworkAgreementUA': u'Укладання рамкової угоди',
        u'closeFrameworkAgreementSelectionUA': u'Відбір для закупівлі за рамковою угодою',
    }
    if value in method_types.values():
        result = method_types.keys()[method_types.values().index(value)]
    else:
        result = value
    return result


def convert_currency(value):
    currency_types = {
        u'грн': u'UAH',
        u'руб': u'RUB',
        u'£': u'GBP',
        u'$': u'USD',
        u'€': u'EUR',
    }
    if value in currency_types:
        result = currency_types[value]
    else:
        result = value
    return result


def convert_mainProcurementCategory(value):
    map = {
        u'Товари': u'goods',
        u'Послуги': u'services',
        u'Роботи': u'works'
    }
    if value in map:
        result = map[value]
    else:
        result = value
    return result


def convert_contract_status(value):
    map = {
        u'Діє': u'active',
        u'Розірваний': u'terminated',
        u'Виконано': u'terminated'
    }
    if value in map:
        result = map[value]
    else:
        result = value
    return result


def convert_status(value):
    map = {
        u'Період уточнень': u'active.enquiries',
        u'Прийом пропозицій': u'active.tendering',
        u'Аукціон': u'active.auction',
        u'Прекваліфікація': u'active.pre-qualification',
        u'Кваліфікація': u'active.qualification',
        u'Пропозиції розглянуті': u'active.awarded',
        u'Завершено': u'complete'
    }
    if value in map:
        result = map[value]
    else:
        result = value
    return result


def download_file_to_my_path(url, path):
    r = requests.get(url)
    with open(path, 'wb') as f:
        f.write(r.content)


def adapt_data(tender_data):
    tender_data.data.procuringEntity = {
        "contactPoint": {
            "telephone": "044 585 90 77",
            "name": u"Иванов Иван Иванович",
            "email": "ppr.bv.owner@gmail.com"
        },
        "identifier": {
            "scheme": "UA-EDR",
            "id": "111111111111111",
            "legalName": u"Демо организатор (государственные торги)"
        },
        "name": u"Демо организатор (государственные торги)",
        "kind": "defense",
        "address": {
            "postalCode": "",
            "countryName": u"Україна",
            "streetAddress": "",
            "region": u"Київська обл.",
            "locality": u"Київ"
        }
    }
    return tender_data


def replace_delivery_address(tender_data):
    delivery_address_replace = {
        u'Переяслав-Хмельницький': {
            "region": u"Київська обл.",
            "locality": u"Переяслав-Хмельницький"
        },
        u'Київ': {
            "region": u"Київська обл.",
            "locality": u"Київ"
        },
        u'Синельникове': {
            "region": u"Дніпропетровська обл.",
            "locality": u"Синельникове"
        },
        u'Дніпро': {
            "region": u"Дніпропетровська обл.",
            "locality": u"Дніпропетровськ"
        },
        u'Кривий Ріг': {
            "region": u"Дніпропетровська обл.",
            "locality": u"Кривий Ріг"
        },
        u'Чернігів': {
            "region": u"Чернігівська обл.",
            "locality": u"Чернігів"
        },
        u'Одеса': {
            "region": u"Одеська обл.",
            "locality": u"Одеса"
        },
        u'Перещепине': {
            "region": u"Дніпропетровська обл.",
            "locality": u"Перещепине"
        },
        u'Миколаїв': {
            "region": u"Дніпропетровська обл.",
            "locality": u"Перещепине"
        },
        u'Нікополь': {
            "region": u"Дніпропетровська обл.",
            "locality": u"Нікополь"
        },
        u'Вишгород': {
            "region": u"Київська обл.",
            "locality": u"Вишгород"
        },
        u"Кам'янське": {
            "region": u"Київська обл.",
            "locality": u"Вишгород"
        },
        u'Здолбунів': {
            "region": u"Рівненська обл.",
            "locality": u"Здолбунів"
        },
        u'Херсон': {
            "region": u"Херсонська обл.",
            "locality": u"Херсон"
        },
        u'Доманівка': {
            "region": u"Миколаївська обл.",
            "locality": u"Доманівка"
        },
        u'Олександрія': {
            "region": u"Миколаївська обл.",
            "locality": u"Доманівка"
        },
        u'Новий Буг': {
            "region": u"Новий Буг",
            "locality": u"Миколаївська обл."
        },
        u'Трикратне': {
            "region": u"Миколаївська обл.",
            "locality": u"Трикратне"
        },
        u'Гостомель': {
            "region": u"Київська обл.",
            "locality": u"Гостомель"
        },
        u'Яготин': {
            "region": u"Київська обл.",
            "locality": u"Яготин"
        },
        u'Олешки': {
            "region": u"Харківська обл.",
            "locality": u"Олешки"
        }
    }

    list_of_keys = list(delivery_address_replace.keys())

    for item in tender_data['data']['items']:
        cdb_locality = item['deliveryAddress']['locality']
        if cdb_locality in list_of_keys:
            item['deliveryAddress']['locality'] = delivery_address_replace[cdb_locality]['locality']
            item['deliveryAddress']['region'] = delivery_address_replace[cdb_locality]['region']

    return tender_data