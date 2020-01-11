# -*- coding: utf-8 -*-


import re
import requests
from dateutil.parser import parse
from dateutil.parser import parserinfo

unitname_dict_smartweb = {
    u'кілограми': u'кг',
    u'літр': u'л',
    u'пачок': u'пач.',
    u'метри': u'м',
    u'послуга': u'умов.',
    u'метри кубічні': u'м3',
    u'ящик': u'ящ',
    u'тони': u'т',
    u'кілометри': u'км',
    u'місяць': u'міс',
    u'пачка': u'пачка',
    u'гектар': u'га',
    u'Флакон': u'флак',
    u'штуки': u'Штука',
}


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
    u'Ворзель': {
        "region": u"Київська обл.",
        "locality": u"Ворзель"
    },
    u'Олешки': {
        "region": u"Харківська обл.",
        "locality": u"Олешки"
    }
}


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
    elif 'minimalStepPercentage' in field:
            ret = float(value)
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
    elif 'deliveryDate.endDate' == field:
        ret = convert_date_from_smart_format(value)
    else:
        ret = value
    return ret


def convert_date_from_smart_format(s):
    dt = parse(s, parserinfo(True, False))
    return dt.strftime('%Y-%m-%dT%H:%M:%S+02:00')


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
        u'лот': u'LO',
        u'кг': u'KGM'
    }
    if value in units_map:
        result = units_map[value]
    else:
        result = value
    return result


def convert_unit_name(value):
    units_map = {
        u'Флакон': u'Флакон',
        u'Набір(товару)': u'набір',
        u'кг': u'кілограми',
        u'Лот': u'лот'
    }
    if value in units_map:
        result = units_map[value]
    else:
        result = value.lower()
    return result


def convert_procurementMethodType(value):
    if value in method_types.values():
        result = method_types.keys()[method_types.values().index(value)]
    else:
        result = value
    return result


def get_en_procurement_method_type(value):
    return method_types[value]


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


def convert_award_status(value):
    map = {
        u'Переможець': u'active',
        u'Рішення скасовано': u'cancelled',
        u'Оцінка': u'pending',
        u'Дискваліфікований': u'cancelled'
    }
    if value in map:
        result = map[value]
    else:
        result = value
    return result


def conver_resolutionType(value):
    map = {
        u'resolved': u'Задоволено',
        u'invalid': u'Не задоволено',
        u'declined': u'Відхилено'
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
        u'Завершено': u'complete',
        u'Закупівля не відбулась': u'unsuccessful'
    }
    if value in map:
        result = map[value]
    else:
        result = value
    return result


def convert_plan_status(value):
    map = {
        u'Запланований': u'scheduled',
        u'Чернетка': u'draft',
        u'Оголошено тендер': u'complete',

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


def replace_procuringEntity(tender_data):
    tender_data.data.procuringEntity = {
        "contactPoint": {
            "telephone": "044 585 90 77",
            "name": u"Иванов Иван Иванович",
            "email": "ppr.bv.owner@gmail.com",
            "url": "ppr.bv.owner@gmail.com"
        },
        "identifier": {
            "scheme": "UA-EDR",
            "id": "111111111111112",
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


def replacee_procuringEntity(tender_data):
    try:
        tender_data.data.procuringEntity = tender_data.data.buyers[0]
        return tender_data
    except:
        print("popali v except")
        return tender_data


def replace_unit_name(tender_data):
    list_of_keys = list(unitname_dict_smartweb.keys())

    for item in tender_data['data']['items']:
        name = item['unit']['name']
        if name in list_of_keys:
            item['unit']['name'] = unitname_dict_smartweb[name]

    return tender_data


def replace_unit_name_dict(key):
    if key in unitname_dict_smartweb.keys():
        return unitname_dict_smartweb[key]
    else:
        return key


def replace_delivery_address(tender_data):
    list_of_keys = list(delivery_address_replace.keys())

    for item in tender_data['data'].get('items'):
        cdb_deliveryAddress = item.get('deliveryAddress')
        if cdb_deliveryAddress:
            cdb_locality = cdb_deliveryAddress.get('locality')
            if cdb_locality in list_of_keys:
                item['deliveryAddress']['region'] = delivery_address_replace[cdb_locality]['region']
                item['deliveryAddress']['locality'] = delivery_address_replace[cdb_locality]['locality']

    return tender_data


def replace_delivery_address_for_viewer(tender_data):
    for item in tender_data['data'].get('items'):
        cdb_deliveryAddress = item.get('deliveryAddress')
        if cdb_deliveryAddress:
            cdb_locality = cdb_deliveryAddress.get('locality')
            if cdb_locality == u"Київ":
                item['deliveryAddress']['region'] = u"Київська область"
            elif cdb_locality == u"Дніпро":
                item['deliveryAddress']['locality'] = u"Київ"
                item['deliveryAddress']['region'] = u"Київська область"


    return tender_data


def replace_minimalStepPercentage(tender_data):
    try:
        if "minimalStepPercentage" in tender_data.data.keys():
            tender_data.data.minimalStepPercentage = 0.026
            tender_data.data.lots[0].minimalStepPercentage = 0.026
        return tender_data
    except:
        print("popali v except")
        return tender_data


def replace_agreementDuration(tender_data):
    try:
        if "agreementDuration" in tender_data.data.keys():
            agreementDuration = tender_data.data.agreementDuration
            # Убираем часы, минуты и секунды с периода
            tender_data.data.agreementDuration = agreementDuration.split("T")[0]
        return tender_data
    except:
        print("popali v except")
        return tender_data


def sync_tender_by_cdb_id(cdb_id):
    url = "https://test.smarttender.biz/api/qa/synctender"
    payload = "{CdbId:'" + str(cdb_id) + "'}"
    headers = {
        'Content-Type': "application/json",
        'Authorization': "Basic cWEuYXBpLnNtdEBnbWFpbC5jb206UUF3ZXJ0eV8=",
        'Accept': 'text/plain',
        'Content-Encoding': 'utf-8'
        }

    response = requests.request("POST", url, data=payload, headers=headers)

    return response.status_code


def clear_additional_classifications(tender_data):
    try:
        if 'additionalClassifications' in tender_data['data'].keys():
            del tender_data['data']['additionalClassifications']
        for item in tender_data['data']['items']:
            if 'additionalClassifications' in item.keys():
                del item['additionalClassifications']
        return tender_data
    except:
        print("popali v except")
        return tender_data


def convert_float_to_string(number, s=2):
   result = number
   if (type(number) is float) and s == 2:
       return format(number, '.2f')
   elif (type(number) is float) and s == 3:
       return format(number, '.3f')
   else:
       return result


def convert_negotiation_cause_from_smart_format(cause):
    key_values_map = {
        u"п. 1, ч. 2, cт. 35. Закупівля творів мистецтва або закупівля, пов’язана із захистом прав інтелектуальної власності, або укладення договору про закупівлю з переможцем архітектурного чи мистецького конкурсу": "artContestIP",
        u"п. 2, ч. 2, cт. 35. Відсутність конкуренції (у тому числі з технічних причин) на відповідному ринку, внаслідок чого договір про закупівлю може бути укладено лише з одним постачальником, за відсутності при цьому альтернативи": "noCompetition",
        u"п. 3, ч. 2, cт. 35. Нагальна потреба у здійсненні закупівлі у зв’язку з виникненням особливих економічних чи соціальних обставин, яка унеможливлює дотримання замовниками строків для проведення тендеру, а саме пов’язаних з негайною ліквідацією наслідків надзвичайних ситуацій, а також наданням у встановленому порядку Україною гуманітарної допомоги іншим державам. Застосування переговорної процедури закупівлі в таких випадках здійснюється за рішенням замовника щодо кожної процедури": "quick",
        u"п. 4, ч. 2, cт. 35. Якщо замовником було двічі відмінено тендер через відсутність достатньої кількості учасників, при цьому предмет закупівлі, його технічні та якісні характеристики, а також вимоги до учасника не повинні відрізнятися від вимог, що були визначені замовником у тедерній документації": "twiceUnsuccessful",
        u"п. 5, ч. 2, cт. 35. Потреба здійснити додаткову закупівлю в того самого постачальника з метою уніфікації, стандартизації або забезпечення сумісності з наявними товарами, технологіями, роботами чи послугами, якщо заміна попереднього постачальника (виконавця робіт, надавача послуг) може призвести до несумісності або виникнення проблем технічного характеру, пов’язаних з експлуатацією та обслуговуванням": "additionalPurchase",
        u"п. 6, ч. 2, cт. 35. Необхідність проведення додаткових будівельних робіт, не зазначених у початковому проекті, але які стали через непередбачувані обставини необхідними для виконання проекту за сукупності таких умов: договір буде укладено з попереднім виконавцем цих робіт, такі роботи технічно чи економічно пов’язані з головним (первинним) договором; загальна вартість додаткових робіт не перевищує 50 відсотків вартості головного (первинного) договору": "additionalConstruction",
        u"п. 7, ч. 2, cт. 35. Закупівля юридичних послуг, пов’язаних із захистом прав та інтересів України, у тому числі з метою захисту національної безпеки і оборони, під час врегулювання спорів, розгляду в закордонних юрисдикційних органах справ за участю іноземного суб’єкта та України, на підставі рішення Кабінету Міністрів України або введених в дію відповідно до закону рішень Ради національної безпеки і оборони України": "stateLegalServices",
    }
    return key_values_map[cause]


def split_funder_adress(value):
    obj = re.search(u"(?P<postalCode>\d+), (?P<countryName>\S*), (?P<region>\S*), (?P<locality>[^,]*), (?P<streetAddress>.*)", value)
    postal_code = obj.group('postalCode')
    country_name = obj.group('countryName')
    region = obj.group('region')
    locality = obj.group('locality')
    street_address = obj.group('streetAddress')
    return postal_code, country_name, region, locality, street_address
