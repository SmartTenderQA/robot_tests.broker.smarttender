*** Settings ***
Library  Selenium2Screenshots
Library  String
Library  DateTime
Resource  webclient.robot
Library  smarttender_service.py


*** Variables ***
############LOADING#################
# IT
${loading 2016}						//*[contains(@id, 'LoadingPanel')]
${loading rmd}						//div[contains(@class,'loading-panel')]
${blocker}                          //*[@id="adorner"]
#${weclient start}                   //*[@class="spinner"]
${loading ITA}                      //img[contains(@class, "loadingImage")]
${blocker}                          //*[@class="loading-panel"]
${IT}                               ${loading 2016}|${loading rmd}|${blocker}|${loading ITA}|${blocker}

# SMARTTENDER
${loading}                          //div[@class='smt-load']
${circle loading}                   //*[@class='loading_container']//*[@class='sk-circle']
${skeleton loading}                 //*[contains(@class,'skeleton-wrapper')]
${sales spin}                       //*[@class='ivu-spin']
${docs spin}                        //div[contains(@style, "loading")]
${loading bar}                      //div[@class="ivu-loading-bar"]   # полоса вверху страницы http://joxi.ru/Dr8xjNeT47v7Dr
${sale web loading}                 //*[contains(@class,'disabled-block')]
${povidomlennya loading}            //*[@class="loading-bar"]
${SMART}                            ${loading}|${circle loading}|${skeleton loading}|${sales spin}|${docs spin}|${loading bar}|${sale web loading}|${povidomlennya loading}

${loadings}                         ${SMART}|${IT}
######################################

#############GET AUCTION HREF#########
${go to auction btn}                       //*[@data-qa="button-poptip-participate-view"]
${view auction btn}                        //*[@data-qa="button-poptip-view"]
${participate in auction link}             //*[@data-qa="link-participate"]
${view auction link}                       //*[@data-qa="link-view"]
######################################


*** Keywords ***
Підготувати клієнт для користувача
	[Arguments]   ${username}
	[Documentation]   Відкрити браузер, створити об’єкт api wrapper, тощо
	Open Browser  ${USERS.users['${username}'].homepage}  ${USERS.users['${username}'].browser}  alias=${username}
	maximize browser window
#	Set Window Position   @{USERS.users['${username}'].position}
#	Set Window Size       @{USERS.users['${username}'].size}
	run keyword if  'viewer' not in '${username.lower()}'  smarttender.Авторизуватися  ${username}


Підготувати дані для оголошення тендера
	[Arguments]   ${username}  ${tender_data}  ${role_name}
	[Documentation]   Адаптувати початкові дані для створення тендера.
	...  Наприклад, змінити дані про procuringEntity на дані про користувача tender_owner на майданчику.
	...  Перевіряючи значення аргументу role_name, можна адаптувати різні дані для різних ролей
	...  (наприклад, необхідно тільки для ролі tender_owner забрати з початкових даних поле mode: test, а для інших ролей не потрібно робити нічого).
	...  Це ключове слово викликається в циклі для кожної ролі, яка бере участь в поточному сценарії.
	...  З ключового слова потрібно повернути адаптовані дані tender_data.
	...  Різниця між початковими даними і кінцевими буде виведена в консоль під час запуску тесту.
	comment  Дані міняемо тільки за необхідністю. Можуть буті проблеми з одиницями виміру.
	${tender_data}  replace_delivery_address  ${tender_data}
	${tender_data}  run keyword if
	...  'tender_owner' in '${username.lower()}'  adapt_data  ${tender_data}
	...  ELSE  set variable  ${tender_data}
	[Return]  ${tender_data}


Створити тендер
	[Arguments]   ${username}  ${tender_data}
	[Documentation]   Створити тендер з початковими даними tender_data. Повернути uaid створеного тендера.
	${tender_data}  Get From Dictionary  ${tender_data}  data
	webclient.робочий стіл натиснути на елемент за назвою  Публічні закупівлі (тестові)
	webclient.header натиснути на елемент за назвою  OK
	webclient.header натиснути на елемент за назвою  Додати
	run keyword  Заповнити поля для ${mode}  ${tender_data}
	webclient.додати тендерну документацію
	webclient.header натиснути на елемент за назвою  Додати
	run keyword and ignore error  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword and ignore error  dialog box натиснути кнопку  Так
	dialog box заголовок повинен містити  Оголосити закупівлю?
	dialog box натиснути кнопку  Так
	webclient.screen заголовок повинен містити  Завантаження документації
	click element   ${screen_root_selector}//*[@alt="Close"]
	loading дочекатись закінчення загрузки сторінки
	${tender_uaid}  webclient.отримати номер тендера
	[Return]  ${tender_uaid}


Заповнити поля для belowThreshold		#Допорог
	[Arguments]  ${tender_data}
	# ОСНОВНІ ПОЛЯ
	${enquiryPeriod.startDate}  set variable  ${tender_data['enquiryPeriod']['startDate']}
	${tenderPeriod.startDate}  set variable  ${tender_data['tenderPeriod']['startDate']}
	${tenderPeriod.endDate}  set variable  ${tender_data['tenderPeriod']['endDate']}
	${value.amount}  set variable  ${tender_data['value']['amount']}
	${value.valueAddedTaxIncluded}  set variable  ${tender_data['value']['valueAddedTaxIncluded']}
	${minimalStep.amount}  set variable  ${tender_data['minimalStep']['amount']}
	${title}  set variable  ${tender_data['title']}
	${description}  set variable  ${tender_data['description']}
	${mainProcurementCategory}  set variable  ${tender_data['mainProcurementCategory']}
	:FOR  ${field}  in
	...  enquiryPeriod.startDate
	...  tenderPeriod.startDate
	...  tenderPeriod.endDate
	...  value.amount
	...  value.valueAddedTaxIncluded
	...  minimalStep.amount
	...  title
	...  description
	...  mainProcurementCategory
	\  run keyword  webclient.заповнити поле ${field}  ${${field}}

	# ЛОТИ
	${count_item}  set variable  1
	:FOR  ${item}  IN  @{tender_data['items']}
	\  run keyword if  '${count_item}' != '1'  webclient.додати item бланк
	\  Заповнити поля лоту  ${item}
	\  ${count_item}  evaluate  ${count_item} + 1

	# УМОВИ ОПЛАТИ
	${count_milestone}  set variable  1
	:FOR  ${milestone}  IN  @{tender_data['milestones']}
	\  run keyword if  '${count_milestone}' == '1'  webclient.активувати вкладку  Умови оплати
	\  Заповнити умови оплати  ${milestone}
	\  ${count_milestone}  evaluate  ${count_milestone} + 1



Заповнити поля лоту
  	[Arguments]  ${item}
	${description}  set variable  ${item['description']}
	${quantity}  set variable  ${item['quantity']}
	${unit.name}  set variable  ${item['unit']['name']}
	${classification.id}  set variable  ${item['classification']['id']}
	${additionalClassifications_status}  ${additionalClassifications.scheme}  run keyword and ignore error  set variable  ${item['additionalClassifications'][0]['scheme']}
	${additionalClassifications_status}  ${additionalClassifications.description}  run keyword and ignore error  set variable  ${item['additionalClassifications'][0]['description']}
	${deliveryAddress.postalCode}  set variable  ${item['deliveryAddress']['postalCode']}
	${deliveryAddress.streetAddress}  set variable  ${item['deliveryAddress']['streetAddress']}
	${deliveryAddress.locality}  set variable  ${item['deliveryAddress']['locality']}
	${deliveryDate.startDate}  set variable  ${item['deliveryDate']['startDate']}
	${deliveryDate.endDate}  set variable  ${item['deliveryDate']['endDate']}

	${field_list}  create list
	...  description
	...  quantity
	...  unit.name
	...  classification.id
	...  deliveryAddress.postalCode
	...  deliveryAddress.streetAddress
	...  deliveryAddress.locality
	...  deliveryDate.startDate
	...  deliveryDate.endDate

	run keyword if  '${additionalClassifications_status}' == 'PASS'  append to list  ${field_list}  additionalClassifications.scheme  additionalClassifications.description

	:FOR  ${field}  in  @{field_list}
	\  run keyword  webclient.заповнити поле для item ${field}  ${${field}}


Заповнити умови оплати
  	[Arguments]  ${milestone}
  	${code_dict}  		create dictionary
	...  prepayment=Аванс
	...  postpayment=Пiсляоплата
	${title_dict}  		create dictionary
	...  executionOfWorks=Виконання робіт
	...  deliveryOfGoods=Поставка товару
	...  submittingServices=Надання послуг
	...  signingTheContract=Підписання договору
	...  submissionDateOfApplications=Дата подання заявки
	...  dateOfInvoicing=Дата виставлення рахунку
	...  endDateOfTheReportingPeriod=Дата закінчення звітного періоду
	...  anotherEvent=Інша подія
	${type_dict}  		create dictionary
	...  calendar=Календарний
	...  working=Робочий
	...  banking=Банківський
	${code_cdb}  set variable  ${milestone['code']}
	${title_cdb}  set variable  ${milestone['title']}
	${duration.type_cdb}  set variable  ${milestone['duration']['type']}

	${code}  set variable  ${code_dict['${code_cdb}']}
	${title}  set variable  ${title_dict['${title_cdb}']}
	${duration.type}  set variable  ${type_dict['${duration.type_cdb}']}
	${duration.days}  set variable  ${milestone['duration']['days']}
	${percentage}  set variable  ${milestone['percentage']}
	${description_status}  ${description}  run keyword and ignore error  set variable  ${milestone['description']}

	${field_list}  create list
  	...  code
  	...  title
  	...  duration.type
  	...  duration.days
  	...  percentage

	run keyword if  '${description_status}' == 'PASS'  append to list  ${field_list}  description

  	додати item бланк  index=2
  	:FOR  ${field}  IN  @{field_list}
  	\  run keyword  заповнити поле для milestone ${field}  ${${field}}


Пошук тендера по ідентифікатору
	[Arguments]   ${username}  ${tender_uaid}
	[Documentation]   Знайти тендер з uaid рівним tender_uaid.
	smarttender.перейти до тестових торгів
	smarttender.сторінка_торгів ввести текст в поле пошуку  ${tender_uaid}
	smarttender.сторінка_торгів виконати пошук
	smarttender.сторінка_торгів перейти за першим результатом пошуку
	${taken_tender_uaid}  smarttender.сторінка_детальної_інформації отримати tender_uaid
	should be equal as strings  ${taken_tender_uaid}  ${tender_uaid}
	set global variable  ${tender_uaid}


Оновити сторінку з тендером
	[Arguments]   ${username}  ${tender_uaid}
    [Documentation]   Оновити сторінку з тендером для отримання потенційно оновлених даних.
    ##########################################################
    #todo  убрать вывод в консоль
    log to console                ${\n}
    log to console      zzzzzZZZZZZZZZZZZZZzzzzz
    log to console  Чекаємо пока пройде синхронізація
    log to console            .............
    ##########################################################
	Wait Until Keyword Succeeds  10m  5s  smarttender.Дочекатись синхронізації


###############################################
###############################################
Отримати інформацію із тендера
    [Arguments]  ${username}  ${tender_uaid}  ${field_name}
    [Documentation]  Отримати значення поля field_name для тендера tender_uaid.
    ${field_name_splited}  set variable  ${field_name.split('[')[0]}
    ${field_value}  run keyword  smarttender.сторінка_детальної_інформації отримати ${field_name_splited}  ${field_name}
    [Return]  ${field_value}


сторінка_детальної_інформації отримати tender_uaid
	[Arguments]  ${field_name}=None
	${selector}  set variable  //*[@data-qa='prozorro-number']//*[@href]
	${field_value}  get text  ${selector}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати title
    [Arguments]  ${field_name}=None
	${selector}  set variable  //*[@data-qa='title']
	${field_value}  get text  ${selector}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати description
    [Arguments]  ${field_name}=None
	${selector}  set variable  //*[@data-qa='description']
	${field_value}  get text  ${selector}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати status
    [Arguments]  ${field_name}=None
	${selector}  set variable  //*[@data-qa='status']
	${field_value}  get text  ${selector}
	${field_value}  convert_status  ${field_value}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати milestones
	[Arguments]  ${field_name}
	${reg}  evaluate  re.search(r'.*\\[(?P<number>\\d)\\]\\.(?P<field>.*)', '${field_name}')  re
	${number}  	evaluate  '${reg.group('number')}'
	${field}  	evaluate  '${reg.group('field')}'

	${item_selector}  set variable  xpath=(//*[@data-qa='paymentTerms-block']//*[@class="delimeter ivu-row"])[${number}+1]

	${milestones_all_values}  get text  ${item_selector}
	${text}  set variable  ${milestones_all_values.replace('\n', '|')}
	${reg}  evaluate  re.search(ur'(?P<title>.*)\\|(?P<duration_days>\\d*) (?P<duration_type>.*)\\|(?P<code>.*)\\: (?P<percentage>[\\d\\.\\,]*)', u'${text}')  re

	${title}  			evaluate  u'${reg.group('title')}'
	${days}  			evaluate  int(u'${reg.group('duration_days')}')
	${type}  			evaluate  u'${reg.group('duration_type')}'
	${code}  			evaluate  u'${reg.group('code')}'
	${percentage}  		evaluate  int(u'${reg.group('percentage')}')
	${is_anotherEvent}  run keyword and return status  should contain  ${title}  Інша подія  #чтобы тянуло без описания
	${title}  run keyword if  ${is_anotherEvent} == ${True}  fetch from right  ${title}  |
	...  ELSE  set variable  ${title}
	####################################
	#  WORK HERE

	${code_dict}  		create dictionary
	...  Аванс=prepayment
	...  Пiсляоплата=postpayment
	${title_dict}  		create dictionary
	...  Виконання робіт=executionOfWorks
	...  Поставка товару=deliveryOfGoods
	...  Надання послуг=submittingServices
	...  Підписання договору=signingTheContract
	...  Дата подання заявки=submissionDateOfApplications
	...  Дата виставлення рахунку=dateOfInvoicing
	...  Дата закінчення звітного періоду=endDateOfTheReportingPeriod
	...  Інша подія=anotherEvent
	${type_dict}  		create dictionary
	...  календарних днів=calendar
	...  робочих днів=working
	...  банківських днів=banking
	${list_of_dict}		create list  code  title  type
	####################################

	${milestones_field_name}  set variable  ${field_name.split('.')[-1]}
	${field_value}  run keyword if  '${milestones_field_name}' in ${list_of_dict}	Get From Dictionary  ${${milestones_field_name}_dict}  ${${milestones_field_name}}  ELSE  set variable  ${${milestones_field_name}}
	[Return]  ${field_value}
###############################################
###############################################


сторінка_детальної_інформації отримати mainProcurementCategory
    [Arguments]  ${field_name}=None
	${selector}  set variable  xpath=//*[@data-qa="main-procurement-category-title"]//*[@data-qa="value"]
	${field_value}  get text  ${selector}
	${field_value}  convert_mainProcurementCategory  ${field_value}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати value.amount
    [Arguments]  ${field_name}=None
	${selector}  set variable  xpath=//*[@data-qa="budget-amount"]
	${field_value}  get text  ${selector}
	${field_value}  convert_page_values  ${field_name}  ${field_value}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати value.currency
    [Arguments]  ${field_name}=None
	${selector}     set variable  xpath=//*[@data-qa="budget-currency"]
	${field_value}  get text  ${selector}
	${field_value}  evaluate  str('${field_value}'.replace(" ", "")).replace(".", "")
	${field_value}  evaluate  '${field_value}'.decode('utf-8')
    ${field_value}  convert_currency  ${field_value}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати value.valueAddedTaxIncluded
    [Arguments]  ${field_name}=None
	${selector}  set variable  xpath=//*[@data-qa="budget-vat-title"]
	${field_value}  get text  ${selector}
	${field_value}  convert_page_values  ${field_name}  '${field_value}'
	[Return]  ${field_value}


сторінка_детальної_інформації отримати tenderID
    [Arguments]  ${field_name}=None
	${selector}  set variable  //*[@data-qa="prozorro-number"]//a
	${field_value}  get text  ${selector}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати procuringEntity.name
    [Arguments]  ${field_name}=None
	${selector}  set variable  //*[@data-qa="organizer-block"]//*[@data-qa="name"]//*[@data-qa="value"]
	${field_value}  get text  ${selector}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати enquiryPeriod.startDate
    [Arguments]  ${field_name}=None
	${selector}  set variable  xpath=//*[@data-qa="enquiry-period"]//*[@data-qa="date-start"]
	${field_value}  get text  ${selector}
	${field_value}  convert date  ${field_value}  date_format=%d.%m.%Y %H:%M  result_format=%Y-%m-%dT%H:%M:%S+03:00
	[Return]  ${field_value}


сторінка_детальної_інформації отримати enquiryPeriod.endDate
    [Arguments]  ${field_name}=None
	${selector}  set variable  xpath=//*[@data-qa="enquiry-period"]//*[@data-qa="date-end"]
	${field_value}  get text  ${selector}
	${field_value}  convert date  ${field_value}  date_format=%d.%m.%Y %H:%M  result_format=%Y-%m-%dT%H:%M:%S+03:00
	[Return]  ${field_value}


сторінка_детальної_інформації отримати tenderPeriod.startDate
    [Arguments]  ${field_name}=None
	${selector}  set variable  xpath=//*[@data-qa="tendering-period"]//*[@data-qa="date-start"]
	${field_value}  get text  ${selector}
	${field_value}  convert date  ${field_value}  date_format=%d.%m.%Y %H:%M  result_format=%Y-%m-%dT%H:%M:%S+03:00
	[Return]  ${field_value}


сторінка_детальної_інформації отримати tenderPeriod.endDate
    [Arguments]  ${field_name}=None
	${selector}  set variable  xpath=//*[@data-qa="tendering-period"]//*[@data-qa="date-end"]
	${field_value}  get text  ${selector}
	${field_value}  convert date  ${field_value}  date_format=%d.%m.%Y %H:%M  result_format=%Y-%m-%dT%H:%M:%S+03:00
	[Return]  ${field_value}


сторінка_детальної_інформації отримати minimalStep.amount
    [Arguments]  ${field_name}=None
	${selector}  set variable  xpath=//*[@data-qa="budget-min-step"]//span[4]
	${field_value}  get text  ${selector}
	${field_value}  convert_page_values  ${field_name}  ${field_value}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати auctionPeriod.startDate
    [Arguments]  ${field_name}=None
	${selector}  set variable  xpath=//*[@data-qa="auction-start"]//*[@data-qa="value"]
	${field_value}  get text  ${selector}
	${field_value}  convert date  ${field_value}  date_format=%d.%m.%Y %H:%M  result_format=%Y-%m-%dT%H:%M:%S+03:00
	[Return]  ${field_value}


Внести зміни в тендер
    [Arguments]  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}
    [Documentation]  Змінити значення поля fieldname на fieldvalue для тендера tender_uaid.
	знайти тендер у webclient  ${tender_uaid}
	header натиснути на елемент за назвою  Змінити
	run keyword  webclient.заповнити поле ${fieldname}  ${fieldvalue}
	header натиснути на елемент за назвою  Зберегти
	run keyword and ignore error  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword and ignore error  dialog box натиснути кнопку  Так
	
	
Додати предмет закупівлі
    [Arguments]  ${username}  ${tender_uaid}  ${item}
    [Documentation]  Додати дані про предмет item до тендера tender_uaid.
	log to console  Додати предмет закупівлі
	debug


Отримати інформацію із предмету
    [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${field_name}
    [Documentation]  Отримати значення поля field_name з предмету з item_id в описі для тендера tender_uaid.
    ${item_block}        set variable  //*[@data-qa="nomenclature-title"][contains(text(),"${item_id}")]/ancestor::div[@class="ivu-row"][1]
	${item_field_value}  run keyword  smarttender.предмети_сторінка_детальної_інформації отримати ${field_name}  ${item_block}
    [Return]  ${item_field_value}


предмети_сторінка_детальної_інформації отримати description
    [Arguments]  ${item_block}
	${selector}  set variable  xpath=${item_block}//*[@data-qa="nomenclature-title"]
	${item_field_value}  get text  ${selector}
	[Return]  ${item_field_value}


предмети_сторінка_детальної_інформації отримати deliveryDate.startDate
    [Arguments]  ${item_block}
	${selector}  set variable  xpath=${item_block}//*[@data-qa="date-start"]
	${item_field_value}  get text  ${selector}
	${item_field_value}  convert date  ${item_field_value}  date_format=%d.%m.%Y  result_format=%Y-%m-%dT%H:%M:%S+03:00
	[Return]  ${item_field_value}


предмети_сторінка_детальної_інформації отримати deliveryDate.endDate
    [Arguments]  ${item_block}
	${selector}  set variable  xpath=${item_block}//*[@data-qa="date-end"]
	${item_field_value}  get text  ${selector}
	${item_field_value}  convert date  ${item_field_value}  date_format=%d.%m.%Y  result_format=%Y-%m-%dT%H:%M:%S+03:00
	[Return]  ${item_field_value}


предмети_сторінка_детальної_інформації отримати deliveryLocation.latitude
    [Arguments]  ${item_block}
	${selector}  set variable  xpath=${item_block}//a
	${item_field_value}  get element attribute  ${selector}@href
	${reg}  evaluate  re.search(u'(?P<lat>\\d+.\\d+),(?P<lon>\\d+.\\d+)', u"""${item_field_value}""")  re
	${lat}	evaluate  float(${reg.group('lat')})
	[Return]  ${lat}


предмети_сторінка_детальної_інформації отримати deliveryLocation.longitude
    [Arguments]  ${item_block}
    ${selector}  set variable  xpath=${item_block}//a
	${item_field_value}  get element attribute  ${selector}@href
	${reg}  evaluate  re.search(u'(?P<lat>\\d+.\\d+),(?P<lon>\\d+.\\d+)', u"""${item_field_value}""")  re
	${lon}	evaluate  float(${reg.group('lon')})
	[Return]  ${lon}


###########################################################################
###########################################################################
предмети_сторінка_детальної_інформації отримати deliveryAddress.countryName
    [Arguments]  ${item_block}
	${item_field_value}  smarttender.get_item_deliveryAddress_value  ${item_block}  countryName
	[Return]  ${item_field_value}


предмети_сторінка_детальної_інформації отримати deliveryAddress.postalCode
    [Arguments]  ${item_block}
    ${item_field_value}  smarttender.get_item_deliveryAddress_value  ${item_block}  postalCode
	[Return]  ${item_field_value}


предмети_сторінка_детальної_інформації отримати deliveryAddress.region
    [Arguments]  ${item_block}
	${item_field_value}  smarttender.get_item_deliveryAddress_value  ${item_block}  region
	[Return]  ${item_field_value}


предмети_сторінка_детальної_інформації отримати deliveryAddress.locality
    [Arguments]  ${item_block}
	${item_field_value}  smarttender.get_item_deliveryAddress_value  ${item_block}  locality
	[Return]  ${item_field_value}


предмети_сторінка_детальної_інформації отримати deliveryAddress.streetAddress
    [Arguments]  ${item_block}
	${item_field_value}  smarttender.get_item_deliveryAddress_value  ${item_block}  streetAddress
	[Return]  ${item_field_value}


#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^#
get_item_deliveryAddress_value
    [Arguments]  ${item_block}  ${group}
    ${selector}  set variable  xpath=${item_block}//*[@data-qa="nomenclature-delivery-address"]
	${item_field_value}  get text by JS  ${selector}
    ${reg}  evaluate  re.search(u'(?P<postalCode>\\d+),.{2}(?P<countryName>\\D+),.{2}(?P<region>\\D+.\\D+.),.{2}(?P<locality>\\D+),.{2}(?P<streetAddress>\\D+.+)', u"""${item_field_value}""")  re
	${group_value}	evaluate  u'${reg.group('${group}')}'
	[Return]  ${group_value}
###########################################################################


предмети_сторінка_детальної_інформації отримати classification.scheme
    [Arguments]  ${item_block}
	${selector}  set variable  xpath=${item_block}//*[@data-qa="nomenclature-main-classification-scheme"]
	${item_field_value}  get text  ${selector}
	${item_field_value}  evaluate  u'${item_field_value}'.replace(":", "")
	[Return]  ${item_field_value}


предмети_сторінка_детальної_інформації отримати classification.id
    [Arguments]  ${item_block}
	${selector}  set variable  xpath=${item_block}//*[@data-qa="nomenclature-main-classification-code"]
	${item_field_value}  get text  ${selector}
	[Return]  ${item_field_value}


предмети_сторінка_детальної_інформації отримати classification.description
    [Arguments]  ${item_block}
	${selector}  set variable  xpath=${item_block}//*[@data-qa="nomenclature-main-classification-title"]
	${item_field_value}  get text  ${selector}
	[Return]  ${item_field_value}


предмети_сторінка_детальної_інформації отримати unit.name
    [Arguments]  ${item_block}
	${selector}  set variable  xpath=${item_block}//*[@data-qa="nomenclature-count"]
	${item_field_value}  get text  ${selector}
	${item_field_value}  convert_page_values  unit.name  ${item_field_value}
	[Return]  ${item_field_value}


предмети_сторінка_детальної_інформації отримати unit.code
    [Arguments]  ${item_block}
    ${selector}  set variable  xpath=${item_block}//*[@data-qa="nomenclature-count"]
	${item_field_value}  get text  ${selector}
	${item_field_value}  convert_page_values  unit.code  ${item_field_value}
	[Return]  ${item_field_value}


предмети_сторінка_детальної_інформації отримати quantity
    [Arguments]  ${item_block}
	${selector}  set variable  xpath=${item_block}//*[@data-qa="nomenclature-count"]
	${item_field_value}  get text  ${selector}
	${item_field_value}  convert_page_values  quantity  ${item_field_value}
	[Return]  ${item_field_value}


Видалити предмет закупівлі
    [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${lot_id}=${Empty}
    [Documentation]  Видалити з тендера tender_uaid предмет з item_id в описі (предмет може бути прив'язаним до лоту з lot_id в описі, якщо lot_id != Empty).    
	log to console  Видалити предмет закупівлі
	debug
	
	
Створити лот
    [Arguments]  ${username}  ${tender_uaid}  ${lot}
    [Documentation]  Додати лот lot до тендера tender_uaid.   
	log to console  Створити лот
	debug
	
	
Створити лот із предметом закупівлі
    [Arguments]  ${username}  ${tender_uaid}  ${lot}  ${item}
    [Documentation]  Додати лот lot з предметом item до тендера tender_uaid.   
	log to console  Створити лот із предметом закупівлі
	debug
	
	
Отримати інформацію із лоту
    [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${field_name}
    [Documentation]  Отримати значення поля field_name з лоту з lot_id в описі для тендера tender_uaid.   
	log to console  Отримати інформацію із лоту
	debug
    [Return]  ${lot_field_value}
    
    
Змінити лот
    [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${fieldname}  ${fieldvalue}
    [Documentation]  Змінити значення поля fieldname лоту з lot_id в описі для тендера tender_uaid на fieldvalue   
	log to console  Змінити лот
	debug
	
	
Додати предмет закупівлі в лот
    [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${item}
    [Documentation]  Додати предмет item в лот з lot_id в описі для тендера tender_uaid.   
	log to console  Додати предмет закупівлі в лот
	debug
	
	
Завантажити документ в лот
    [Arguments]  ${username}  ${filepath}  ${tender_uaid}  ${lot_id}
    [Documentation]  Завантажити документ, який знаходиться по шляху filepath, до лоту з lot_id в описі для тендера tender_uaid   
	log to console  Завантажити документ в лот
	debug
	
	
Видалити лот
    [Arguments]  ${username}  ${tender_uaid}  ${lot_id}
    [Documentation]  Видалити лот з lot_id в описі для тендера tender_uaid.   
	log to console  Видалити лот
	debug
	

Отримати інформацію з документа до лоту
    [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${doc_id}  ${field}
    [Documentation]  Отримати значення поля field документа з doc_id в назві для тендера tender_uaid.   
	log to console  Отримати інформацію з документа до лоту
	debug

###################################################################
###################################################################
Отримати документ
    [Arguments]  ${username}  ${tender_uaid}  ${doc_id}
	${file_name}  get text  xpath=//*[@data-qa="file-name"][contains(text(),"${doc_id}")]
    smarttender.документи скачати файл на сторінці  ${file_name}
    [Return]  ${file_name}


#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^#
документи скачати файл на сторінці
    [Arguments]  ${file_name}
    ${link}  smarttender.документи отримати посилання на перегляд файлу  ${file_name}
    ${link}  run keyword if  "src=" in "${link}"
    ...  evaluate  re.search(u'src=(?P<href>.+)', u"""${link}""").group('href')  re
    ...  ELSE
    ...  evaluate  re.search(u'url=(?P<href>.+)', u"""${link}""").group('href')  re
    ${download_link}  Evaluate  urllib.unquote('${link}')  urllib
    download_file_to_my_path  ${download_link}  ${OUTPUTDIR}/${file_name}
    Sleep  3


документи отримати посилання на перегляд файлу
    [Arguments]  ${file_name}
    ${selector}  Set Variable  xpath=//*[@data-qa="file-name"][text()="${file_name}"]
    Wait Until Keyword Succeeds  20  .5  Run Keywords
    ...  Mouse Over  ${selector}/preceding-sibling::i  AND
    ...  Wait Until Element Is Visible  ${selector}/ancestor::div[@class="ivu-poptip"]//a[@data-qa="file-preview"]
    ${link}  Get Element Attribute  ${selector}/ancestor::div[@class="ivu-poptip"]//a[@data-qa="file-preview"]@href
    [Return]  ${link}


документи переглянути файл за іменем
    [Arguments]  ${file_name}
    ${link}  smarttender.документи отримати посилання на перегляд файлу  ${file_name}
    Go To  ${link}
###################################################################


Отримати документ до лоту
    [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${doc_id}
    [Documentation]  Завантажити файл doc_id до лоту з lot_id в описі для тендера tender_uaid в директорію ${OUTPUT_DIR} для перевірки вмісту цього файлу.   
	log to console  Отримати документ до лоту
	debug
    [Return]  ${filename}
    
    
Додати не ціновий показник на тендер
    [Arguments]  ${username}  ${tender_uaid}  ${feature}
    [Documentation]  Додати дані feature про не ціновий показник до тендера tender_uaid   
	log to console  Додати не ціновий показник на тендер
	debug
	
	
Додати не ціновий показник на предмет
    [Arguments]  ${username}  ${tender_uaid}  ${feature}  ${item_id}
    [Documentation]  Додати дані feature про неціновий показник до предмету з item_id в описі для тендера tender_uaid.   
	log to console  Додати не ціновий показник на предмет
	debug

Додати не ціновий показник на лот
    [Arguments]  ${username}  ${tender_uaid}  ${feature}  ${lot_id}
    [Documentation]  Додати дані feature про неціновий показник до лоту з lot_id в описі для тендера tender_uaid.   
	log to console  Додати не ціновий показник на лот
	debug
	
	
Отримати інформацію із нецінового показника
    [Arguments]  ${username}  ${tender_uaid}  ${feature_id}  ${field_name}
    [Documentation]  Отримати значення поля field_name з нецінового показника з feature_id в описі для тендера tender_uaid.   
	log to console  Отримати інформацію із нецінового показника
	debug
    [Return]  ${feature_field_name}
    
   
Видалити неціновий показник
    [Arguments]  ${username}  ${tender_uaid}  ${feature_id}  ${obj_id}=${Empty}
    [Documentation]  Видалити неціновий показник з feature_id в описі для тендера tender_uaid.   
	log to console  Видалити неціновий показник
	debug
	
	
Задати запитання на предмет
    [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${question}
    [Documentation]  Створити запитання з даними question до предмету з item_id в описі для тендера tender_uaid.   
	log to console  Задати запитання на предмет
	debug
	
	
Задати запитання на лот
    [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${question}
    [Documentation]  Створити запитання з даними question до лоту з lot_id в описі для тендера tender_uaid.   
	log to console  Задати запитання на лот
	debug
	
	
Задати запитання на тендер
    [Arguments]  ${username}  ${tender_uaid}  ${question}
    [Documentation]  Створити запитання з даними question для тендера tender_uaid.
	${tender_title}  smarttender.сторінка_детальної_інформації отримати title
	smarttender.сторінка_детальної_інформації активувати вкладку  Запитання
	smarttender.запитання_вибрати тип запитання      ${tender_title}
	smarttender.запитання_натиснути кнопку "Поставити запитання"
	smarttender.запитання_заповнити тему             ${question['data']['title']}
	smarttender.запитання_заповнити текст запитання  ${question['data']['description']}
	smarttender.запитання_натиснути кнопку "Подати"



Отримати інформацію із запитання
    [Arguments]  ${username}  ${tender_uaid}  ${question_id}  ${field_name}
    [Documentation]  Отримати значення поля field_name із запитання з question_id в описі для тендера tender_uaid.
	smarttender.сторінка_детальної_інформації активувати вкладку  Запитання
	${question_block}  set variable  //*[contains(text(),"${question_id}")]/ancestor::div[@class="ivu-card-body"][1]
	${question_field_name}  run keyword  smarttender.запитання_сторінка_детальної отримати ${field_name}  ${question_block}
    [Return]  ${question_field_name}
    

запитання_сторінка_детальної отримати title
    [Arguments]  ${question_block}
    ${selector}  set variable  xpath=${question_block}//*[@class="bold break-word"][1]
    ${question_field_name}  get text  ${selector}
    [Return]  ${question_field_name}


запитання_сторінка_детальної отримати description
    [Arguments]  ${question_block}
    ${selector}  set variable  xpath=${question_block}//*[@class="break-word"][1]
    ${question_field_name}  get text  ${selector}
    [Return]  ${question_field_name}


запитання_сторінка_детальної отримати answer
    [Arguments]  ${question_block}
    ${selector}  set variable  xpath=${question_block}//*[@class="break-word card-padding"][1]
    ${question_field_name}  get text  ${selector}
    [Return]  ${question_field_name}


Відповісти на запитання
    [Arguments]  ${username}  ${tender_uaid}  ${answer_data}  ${question_id}
    [Documentation]  Дати відповідь answer_data на запитання з question_id в описі для тендера tender_uaid.  
	log to console  Відповісти на запитання
	webclient.активувати вкладку  Обговорення закупівлі
	click element  //*[contains(text(), "${question_id}")]
	webclient.header натиснути на елемент за назвою  Змінити
	${answer field}  set variable  //*[@data-name="ANSWER"]//textarea
	заповнити simple input  ${answer field}  ${answer_data['data']['answer']}
	${save answer locator}  set variable  //*[@data-name="READYFL"]//input
	операція над чекбоксом  ${True}  ${save answer locator}
	webclient.header натиснути на елемент за назвою  Зберегти
	dialog box заголовок повинен містити  Надіслати відповідь на сервер ProZorro?
	dialog box натиснути кнопку  Так
	webclient.активувати вкладку  Тестові публічні закупівлі
	
	
Створити вимогу про виправлення умов закупівлі
    [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${document}=${None}
    [Documentation]  Створює вимогу claim про виправлення умов закупівлі у статусі claim для тендера tender_uaid. Можна створити вимогу як з документом, який знаходиться за шляхом document, так і без нього.
	log to console  Створити вимогу про виправлення умов закупівлі
	debug
    [Return]  ${complaintID}
    
    
Створити вимогу про виправлення умов лоту
    [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${lot_id}  ${document}=${None}
    [Documentation]  Створює вимогу claim про виправлення умов лоту у статусі claim для тендера tender_uaid. Можна створити вимогу як з документом, який знаходиться за шляхом document, так і без нього.  
	log to console  Створити вимогу про виправлення умов лоту
	debug
    [Return]  ${complaintID}
    
    
Створити вимогу про виправлення визначення переможця
    [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${award_index}  ${document}=${None}
    [Documentation]  Створює вимогу claim про виправлення визначення переможця під номером award_index в статусі claim для тендера tender_uaid. Можна створити вимогу як з документом, який знаходиться за шляхом document, так і без нього.  
	log to console  Створити вимогу про виправлення визначення переможця
	debug
    [Return]  ${complaintID}
    
    
Скасувати вимогу про виправлення умов закупівлі
    [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}
    [Documentation]  Перевести вимогу complaintID про виправлення умов закупівлі для тендера tender_uaid у статус cancelled, використовуючи при цьому дані cancellation_data.  
	log to console  Скасувати вимогу про виправлення умов закупівлі
	debug
    
    
Скасувати вимогу про виправлення умов лоту
    [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}
    [Documentation]  Перевести вимогу complaintID про виправлення умов лоту для тендера tender_uaid у статус cancelled, використовуючи при цьому дані cancellation_data.  
	log to console  Скасувати вимогу про виправлення умов лоту
	debug
	
    
Отримати інформацію із скарги
    [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${field_name}  ${award_index}=${None}
    [Documentation]  Отримати значення поля field_name скарги/вимоги complaintID  
	log to console  Отримати інформацію із скарги
	debug
    [Return]  ${complaint_field_value}
    
    
Відповісти на вимогу про виправлення умов закупівлі
    [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}
    [Documentation]  Відповісти на вимогу complaintID про виправлення умов закупівлі для тендера tender_uaid, використовуючи при цьому дані answer_data.  
	log to console  Відповісти на вимогу про виправлення умов закупівлі
	debug
	
	
Підтвердити вирішення вимоги про виправлення умов закупівлі
    [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}
    [Documentation]  Перевести вимогу complaintID про виправлення умов закупівлі для тендера tender_uaid у статус resolved, використовуючи при цьому дані confirmation_data.  
	log to console  Підтвердити вирішення вимоги про виправлення умов закупівлі
	debug
	

Скасувати вимогу про виправлення визначення переможця
    [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}  ${award_index}
    [Documentation]  Перевести вимогу complaintID про виправлення визначення переможця під номером award_index для тендера tender_uaid у статус cancelled, використовуючи при цьому дані confirmation_data.  
	log to console  Скасувати вимогу про виправлення визначення переможця
	debug


Відповісти на вимогу про виправлення визначення переможця
    [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}  ${award_index}
    [Documentation]  Відповісти на вимогу complaintID про виправлення визначення переможця під номером award_index для тендера tender_uaid, використовуючи при цьому дані answer_data.  
	log to console  Відповісти на вимогу про виправлення визначення переможця
	debug
	

Підтвердити вирішення вимоги про виправлення визначення переможця
    [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}  ${award_index}
    [Documentation]  Перевести вимогу complaintID про виправлення визначення переможця під номером award_index для тендера tender_uaid у статус resolved, використовуючи при цьому дані cancellation_data.  
	log to console  Підтвердити вирішення вимоги про виправлення визначення переможця
	debug


Завантажити документ
    [Arguments]  ${username}  ${filepath}  ${tender_uaid}
    [Documentation]  Завантажити документ, який знаходиться по шляху filepath, до тендера tender_uaid.
	знайти тендер у webclient  ${tender_uaid}
	webclient.header натиснути на елемент за назвою  Змінити
	webclient.активувати вкладку  Документы
	webclient.загрузити документ  ${filepath}
	webclient.header натиснути на елемент за назвою  Сохранить
	run keyword and ignore error  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword and ignore error  dialog box натиснути кнопку  Так
	webclient.screen заголовок повинен містити  Завантаження документації
	click element   ${screen_root_selector}//*[@alt="Close"]


Отримати інформацію із документа
    [Arguments]  ${username}  ${tender_uaid}  ${doc_id}  ${field}
    [Documentation]  Отримати значення поля field документа doc_id з тендера tender_uaid для перевірки правильності відображення цього поля.
	reload page
	${doc_block}  set variable  //*[@data-qa="file-name"][contains(text(),"${doc_id}")]/ancestor::div[contains(@class,"filename")]
	loading дочекатися відображення елемента на сторінці  ${doc_block}
    ${document_field}  run keyword  smarttender.документи_сторінка_детальної_інформації отримати ${field}  ${doc_block}
    [Return]  ${document_field}


документи_сторінка_детальної_інформації отримати title
    [Arguments]  ${doc_block}
    ${selector}  set variable  xpath=${doc_block}//*[@data-qa="file-name"]
    ${document_field}  get text  ${selector}
    [Return]  ${document_field}


Подати цінову пропозицію
    [Arguments]  ${username}  ${tender_uaid}  ${bid}  ${lots_ids}=${None}  ${features_ids}=${None}
    [Documentation]  Подати цінову пропозицію bid для тендера tender_uaid на лоти lots_ids (якщо lots_ids != None) з неціновими показниками features_ids (якщо features_ids != None).
    smarttender.пропозиція_перевірити кнопку подачі пропозиції
    smarttender.пропозиція_заповнити поле з ціною  1  1
    smarttender.пропозиція_відмітити чекбокси за необхідністю
    smarttender.пропозиція_подати пропозицію


Отримати інформацію із пропозиції
    [Arguments]  ${username}  ${tender_uaid}  ${field}
    [Documentation]  Отримати значення поля field пропозиції користувача username для тендера tender_uaid.
	${bid_field}  run keyword  smarttender.пропозиція_отримати інформацію по полю ${field}
    [Return]  ${bid_field}


пропозиція_отримати інформацію по полю value.amount
    ${selector}  set variable  //*[@id="lotAmount0"]//input
    ${bid_field}  get element attribute  ${selector}@value
    ${bid_field}  evaluate  float(str('${bid_field}'.replace(" ", "")))
    [Return]  ${bid_field}


Змінити цінову пропозицію
    [Arguments]  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}
    [Documentation]  Змінити поле fieldname на fieldvalue цінової пропозиції користувача username для тендера tender_uaid.
	${selector}  set variable if
	...  "${fieldname}" == "value.amount"    //*[@id="lotAmount0"]//input
	input text  ${selector}  "${fieldvalue}"
	smarttender.пропозиція_подати пропозицію


Завантажити документ в ставку
    [Arguments]  ${username}  ${path}  ${tender_uaid}  ${doc_type}=None     #=${documents}
    [Documentation]  Завантажити документ типу doc_type, який знаходиться за шляхом path, до цінової пропозиції користувача username для тендера tender_uaid.
	Choose File  xpath=(//input[@type="file"][1])[1]  ${path}
	smarttender.пропозиція_подати пропозицію


Змінити документ в ставці
    [Arguments]  ${username}  ${tender_uaid}  ${path}  ${docid}
    [Documentation]  Змінити документ з doc_id в описі в пропозиції користувача username для тендера tender_uaid на документ, який знаходиться по шляху path.
	smarttender.пропозиція_видалити файл  ${docid}
	Choose File  xpath=(//input[@type="file"][1])[1]  ${path}
	smarttender.пропозиція_подати пропозицію
    go back
    loading дочекатись закінчення загрузки сторінки


Змінити документацію в ставці
    [Arguments]  ${username}  ${tender_uaid}  ${doc_data}  ${doc_id}
    [Documentation]  Змінити тип документа з doc_id в заголовку в пропозиції користувача username для тендера tender_uaid. Дані про новий тип документа знаходяться в doc_data.  
	log to console  Змінити документацію в ставці
	debug


Скасувати цінову пропозицію
    [Arguments]  ${username}  ${tender_uaid}
    [Documentation]  Змінити статус цінової пропозиції для тендера tender_uaid користувача username на cancelled.  
	log to console  Скасувати цінову пропозицію
	debug


Завантажити документ у кваліфікацію
    [Arguments]  ${username}  ${document}  ${tender_uaid}  ${qualification_num}
    [Documentation]  Завантажити документ, який знаходиться по шляху document, до кваліфікації під номером qualification_num до тендера tender_uaid  
	log to console  Завантажити документ у кваліфікацію
	debug


Підтвердити кваліфікацію
    [Arguments]  ${username}  ${tender_uaid}  ${qualification_num}
    [Documentation]  Перевести кваліфікацію під номером qualification_num до тендера tender_uaid в статус active.  
	log to console  Підтвердити кваліфікацію
	debug


Відхилити кваліфікацію
    [Arguments]  ${username}  ${tender_uaid}  ${qualification_num}
    [Documentation]  Перевести кваліфікацію під номером qualification_num до тендера tender_uaid в статус unsuccessful.  
	log to console  Відхилити кваліфікацію
	debug


Скасувати кваліфікацію
    [Arguments]  ${username}  ${tender_uaid}  ${qualification_num}
    [Documentation]  Перевести кваліфікацію під номером qualification_num до тендера tender_uaid в статус cancelled.  
	log to console  Скасувати кваліфікацію
	debug


Затвердити остаточне рішення кваліфікації
    [Arguments]  ${username}  ${tender_uaid}
    [Documentation]  Перевести тендер tender_uaid в статус active.pre-qualification.stand-still.  
	log to console  Затвердити остаточне рішення кваліфікації
	debug
	

Отримати посилання на аукціон для глядача
    [Arguments]  ${username}  ${tender_uaid}  ${lot_id}=${Empty}
    [Documentation]  Отримати посилання на аукціон для тендера tender_uaid (або для лоту з lot_id в описі для тендера tender_uaid, якщо lot_id != Empty).
	${auctionUrl}  smarttender.отримати посилання на прегляд аукціону не учасником
    [Return]  ${auctionUrl}


Отримати посилання на аукціон для учасника
    [Arguments]  ${username}  ${tender_uaid}  ${lot_id}=${Empty}
    [Documentation]  Отримати посилання на участь в аукціоні для користувача username для тендера tender_uaid (або для лоту з lot_id в описі для тендера tender_uaid, якщо lot_id != Empty).  
	${participationUrl}  ${auction_href}  отримати посилання на участь та прегляд аукціону для учасника
    [Return]  ${participationUrl}


Завантажити документ рішення кваліфікаційної комісії
    [Arguments]  ${username}  ${document}  ${tender_uaid}  ${award_num}
    [Documentation]  Завантажити документ, який знаходиться по шляху document до постачальника під номером award_num для тендера tender_uaid.  
	log to console  Завантажити документ рішення кваліфікаційної комісії
	debug


Підтвердити постачальника
    [Arguments]  ${username}  ${tender_uaid}  ${award_num}
    [Documentation]  Перевести постачальника під номером award_num для тендера tender_uaid в статус active.  
	log to console  Підтвердити постачальника
	debug


Скасування рішення кваліфікаційної комісії
    [Arguments]  ${username}  ${tender_uaid}  ${award_num}
    [Documentation]  Перевести постачальника під номером award_num для тендера tender_uaid в статус cancelled.
	log to console  Скасування рішення кваліфікаційної комісії
	debug


Редагувати угоду
    [Arguments]  ${username}  ${tender_uaid}  ${contract_index}  ${fieldname}  ${fieldvalue}
    [Documentation]  Змінює поле fieldname угоди тендера tender_uaid на fieldvalue
	log to console  Редагувати угоду
	debug


Встановити дату підписання угоди
    [Arguments]  ${username}  ${tender_uaid}  ${contract_index}  ${fieldvalue}
    [Documentation]  Встановлює дату підписання угоди тендера tender_uaid на fieldvalue
	log to console  Встановити дату підписання угоди
	debug


Вказати період дії угоди
    [Arguments]  ${username}  ${tender_uaid}  ${contract_index}  ${startDate}  ${endDate}
    [Documentation]  Встановлює період дії угоди тендера tender_uaid на startDate і endDate
	log to console  Вказати період дії угоди
	debug


Завантажити документ в угоду
    [Arguments]  ${username}  ${path}  ${tender_uaid}  ${contract_index}  ${doc_type}
    [Documentation]  Завантажити документ, який знаходиться по шляху path, до контракту contract_index з вказанням типу doc_type
	log to console  Завантажити документ в угоду
	debug


Підтвердити підписання контракту
    [Arguments]  ${username}  ${tender_uaid}  ${contract_num}
    [Documentation]  Перевести договір під номером contract_num до тендера tender_uaid в статус active.
	log to console  Підтвердити підписання контракту
	debug


Перевести тендер на статус очікування обробки мостом
    [Arguments]  ${username}  ${tender_uaid}
    [Documentation]  Перевести тендер tender_uaid в статус active.stage2.waiting.
	log to console  Перевести тендер на статус очікування обробки мостом
	debug


Отримати тендер другого етапу та зберегти його
    [Arguments]  ${username}  ${tender_id}
    [Documentation]  Отримати доступ до тендера другого етапу по tender id.
	log to console  Отримати тендер другого етапу та зберегти його
	debug


Активувати другий етап
	[Arguments]  ${username}  ${tender_uaid}
    [Documentation]  Перевести тендер tender_uaid в статус active.tendering
	log to console  Активувати другий етап
	debug


Дискваліфікувати постачальника
    [Arguments]  ${username}  ${tender_uaid}  ${award_num}
    [Documentation]  Перевести постачальника під номером award_num для тендера tender_uaid в статус unsuccessful.
	log to console  Дискваліфікувати постачальника
	debug


Створити постачальника, додати документацію і підтвердити його
    [Arguments]  ${username}  ${tender_uaid}  ${supplier_data}  ${document}
    [Documentation]  Додати постачальника supplier_data для тендера tender_uaid, додати до нього документ, який знаходиться по шляху document та перевести в статус active.
	log to console  Створити постачальника, додати документацію і підтвердити його
	debug


Створити план
    [Arguments]  ${username}  ${tender_data}
    [Documentation]  Створити план з початковими даними tender_data. Повернути uaid створеного плану.
	log to console  Створити план
    [Return]  ${planID}


Пошук плану по ідентифікатору
    [Arguments]  ${username}  ${planID}
    [Documentation]  Знайти план з uaid рівним tender_uaid.
	smarttender.перейти до сторінки планів
	smarttender.сторінка_планів ввести текст в поле пошуку  ${planID}
    smarttender.сторінка_планів виконати пошук
	smarttender.сторінка_планів перейти за першим результатом пошуку
	${taken_planID}  smarttender.план_сторінка_детальної_інформації отримати planID  planID
	should be equal as strings  ${taken_planID}  ${planID}


перейти до сторінки планів
    go to  https://test.smarttender.biz/plans/


Отримати інформацію із плану
    [Arguments]  ${username}  ${plan_uaid}  ${field_name}
    [Documentation]  Отримати значення поля field_name для плану plan_uaid.
	${field_name_splited}  set variable  ${field_name.split('[')[0]}
    ${field_value}  run keyword  smarttender.план_сторінка_детальної_інформації отримати ${field_name_splited}  ${field_name}
    [Return]  ${field_value}



Видалити предмет закупівлі плану
    [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${lot_id}=${Empty}
    [Documentation]  Видалити з плану tender_uaid предмет з item_id в описі (предмет може бути прив'язаним до лоту з lot_id в описі, якщо lot_id != Empty).
	log to console  Видалити предмет закупівлі плану
	debug


Оновити сторінку з планом
    [Arguments]   ${username}  ${plan_uaid}
    [Documentation]   Оновити сторінку з тендером для отримання потенційно оновлених даних.
    ##########################################################
    #todo  убрать вывод в консоль
    log to console                ${\n}
    log to console      zzzzzZZZZZZZZZZZZZZzzzzz
    log to console  Чекаємо пока пройде синхронізація
    log to console            .............
    ##########################################################
    Wait Until Keyword Succeeds  10m  5s  smarttender.Дочекатись синхронізації
    log to console            PASS
    log to console            .............


########################################################################################################
########################################################################################################
сторінка_планів ввести текст в поле пошуку
    [Arguments]  ${text}
    input text  //*[@data-qa="search-phrase"]/input  ${text}


сторінка_планів виконати пошук
    click element  //*[@id="btnFind"]
    loading дочекатись закінчення загрузки сторінки


сторінка_планів перейти за першим результатом пошуку
	${plan_number}  set variable  1
	${link}  get element attribute  xpath=(//*[@id="plan"])[${plan_number}]//*[@data-qa="plan-title"]@href
	log  plan_link: ${link}  WARN
	go to  ${link}

план_сторінка_детальної_інформації отримати planID
    [Arguments]  ${field_name}
	${selector}  set variable  //*[@data-qa="plan-cdb-number-link"]
	${field_value}  get text  ${selector}
	[Return]  ${field_value}


план_сторінка_детальної_інформації отримати tender.procurementMethodType
    [Arguments]  ${field_name}
	${selector}  set variable  //*[@data-qa="plan-bidding-type-info"]//*[@data-qa="value"]
	${field_value}  get text  ${selector}
	${field value}  convert_procurementMethodType  ${field value}
	[Return]  ${field_value}


план_сторінка_детальної_інформації отримати budget.amount
    [Arguments]  ${field_name}
	${selector}  set variable  //*[@data-qa="plan-initialValue"]
	${field_value}  get text  ${selector}
	${field_value}  evaluate  float(${field_value.replace(" ", "")})
	[Return]  ${field_value}


план_сторінка_детальної_інформації отримати budget.description
    [Arguments]  ${field_name}
	${selector}  set variable  //*[@data-qa="plan-title"]
	${field_value}  get text  ${selector}
	[Return]  ${field_value}


план_сторінка_детальної_інформації отримати budget.currency
    [Arguments]  ${field_name}
	${selector}  set variable  //*[@data-qa="plan-currency-name"]
	${field_value}  get text  ${selector}
	${field_value}  set variable  ${field_value.replace(" ", "").replace(".", "")}
	${field_value}  convert_currency  ${field_value}
	[Return]  ${field_value}


план_сторінка_детальної_інформації отримати budget.id
    [Arguments]  ${field_name}
    log to console  Поле не отображается на странице
	[Return]  ${field_value}


план_сторінка_детальної_інформації отримати budget.project.id
    [Arguments]  ${field_name}
    log to console  Поле не отображается на странице
	[Return]  ${field_value}


план_сторінка_детальної_інформації отримати budget.project.name
    [Arguments]  ${field_name}
    log to console  Поле не отображается на странице
	[Return]  ${field_value}


план_сторінка_детальної_інформації отримати procuringEntity.name
    [Arguments]  ${field_name}
    log to console  Поле не отображается на странице
	[Return]  ${field_value}


план_сторінка_детальної_інформації отримати procuringEntity.identifier.scheme
    [Arguments]  ${field_name}
    log to console  Поле не отображается на странице
	[Return]  ${field_value}


план_сторінка_детальної_інформації отримати procuringEntity.identifier.id
    [Arguments]  ${field_name}
    ${selector}  set variable  //*[@data-qa="plan-usreou"]//*[@data-qa="value"]
	${field_value}  get text  ${selector}
	[Return]  ${field_value}


план_сторінка_детальної_інформації отримати procuringEntity.identifier.legalName
    [Arguments]  ${field_name}
    ${selector}  set variable  //*[@data-qa="plan-organizer"]//*[@data-qa="value"]
	${field_value}  get text  ${selector}
	[Return]  ${field_value}


план_сторінка_детальної_інформації отримати classification.description
    [Arguments]  ${field_name}
    ${selector}  set variable  //*[@data-qa="plan-main-classification"]//*[@data-qa="value"]
	${field_value}  get text  ${selector}
	${field_value}  Evaluate  re.search(r' (?P<description>\\D+)', u'${field_value}').group('description')  re
	[Return]  ${field_value}


план_сторінка_детальної_інформації отримати classification.scheme
    [Arguments]  ${field_name}
    ${selector}  set variable  //*[@data-qa="plan-main-classification"]//*[contains(@class, "key-value")]
	${field_value}  get text  ${selector}
	[Return]  ${field_value.split(" ")[1]}


план_сторінка_детальної_інформації отримати classification.id
    [Arguments]  ${field_name}
    ${selector}  set variable  //*[@data-qa="plan-main-classification"]//*[@data-qa="value"]
	${field_value}  get text  ${selector}
	[Return]  ${field_value.split(" ")[0]}


план_сторінка_детальної_інформації отримати tender.tenderPeriod.startDate
    [Arguments]  ${field_name}
    log to console  Поле не отображается на странице
	[Return]  ${field_value}


план_сторінка_детальної_інформації отримати items
	[Arguments]  ${field_name}
	${reg}  evaluate  re.search(r'.*\\[(?P<number>\\d)\\]\\.(?P<field>.*)', '${field_name}')  re
	${number}  	evaluate  '${reg.group('number')}'
	${field}  	evaluate  '${reg.group('field')}'
	${item_selector}  set variable  xpath=(//*[@data-qa="value-list"])[${number}+1]
    ${field_selector}      set variable if
    ...  '${field}' == 'description'                    //*[@data-qa="nomenclature-title"]
    ...  '${field}' == 'quantity'                       //*[@data-qa="nomenclature-count"]
    ...  '${field}' == 'unit.code'                      //*[@data-qa="nomenclature-count"]
    ...  '${field}' == 'unit.name'                      //*[@data-qa="nomenclature-count"]
    ...  '${field}' == 'deliveryDate.endDate'           //*[@data-qa="date-end"]
    ...  '${field}' == 'classification.description'     //*[@data-qa="nomenclature-main-classification-title"]
    ...  '${field}' == 'classification.scheme'          //*[@data-qa="nomenclature-main-classification-scheme"]
    ...  '${field}' == 'classification.id'              //*[@data-qa="nomenclature-main-classification-code"]
    ${field_value}  get text  ${item_selector}${field_selector}
    ${converted_field_value}  convert_plan_page_values  ${field}  ${field_value}
    ${converted_field_value}  run keyword if  '${field}' == 'deliveryDate.endDate'
    ...  date convertation  ${converted_field_value}
    ...  ELSE  return from keyword  ${converted_field_value}
    [Return]  ${converted_field_value}

date convertation
#   TODO нати способ не хардкодить часовой пояс
    [Arguments]  ${raw_date}
    ${converted_date}  convert date  ${raw_date}  date_format=%d.%m.%Y  result_format=%Y-%m-%dT%H:%M:%S+03:00
    [Return]  ${converted_date}
########################################################################################################
########################################################################################################
###########################################KEYWORDS#####################################################
########################################################################################################
########################################################################################################
Авторизуватися
	[Arguments]  ${username}
	log to console  Авторизуватися
	${login}  set variable  ${USERS.users['${username}']['login']}
	${password}  set variable  ${USERS.users['${username}']['password']}
	сторінка_стартова натиснути вхід
	ввести логін  ${login}
	ввести пароль  ${password}
	натиснути Увійти


сторінка_стартова натиснути вхід
	${selector}  set variable  //*[@data-qa="title-btn-modal-login"]
	loading дочекатися відображення елемента на сторінці  ${selector}
	click element  ${selector}


ввести логін
	[Arguments]  ${login}
	${login_field}  set variable  //*[@data-qa="form-login-login"]//input
	loading дочекатися відображення елемента на сторінці  ${login_field}
	input text  ${login_field}  ${login}


ввести пароль
	[Arguments]  ${password}
	${pass_field}  set variable  //*[@data-qa="form-login-password"]//input
	loading дочекатися відображення елемента на сторінці  ${pass_field}
	input text  ${pass_field}  ${password}


натиснути Увійти
	${login_btn}  set variable  //*[@data-qa="form-login-success"]
	loading дочекатися відображення елемента на сторінці  ${login_btn}
	click element  ${login_btn}
	loading дочекатися зникнення елемента зі сторінки  ${login_btn}  timeout=120

Open button
	[Documentation]   відкривае лінку з локатора у поточному вікні
	[Arguments]  ${selector}
	${href}=  Get Element Attribute  ${selector}@href
	Go To  ${href}

get text by JS
	[Arguments]    ${xpath}
	${xpath}  Set Variable  ${xpath.replace("'", '"')}
	${xpath}  Set Variable  ${xpath.replace('xpath=', '')}
	${text_is}  Execute JavaScript
	...  return document.evaluate('${xpath}', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.textContent
	[Return]  ${text_is}


#################################################
#################################################
дочекатися статусу тендера
    [Arguments]  ${tender status}  ${time}=20m
    [Documentation]  ${tender status} приймаемо у вигляді статусу як в ЦБД: active.tendering і т.д.
    Wait Until Keyword Succeeds  ${time}  30s  Run Keywords
    ...  Reload Page
    ...  AND  smarttender.cтатус тендера повинен бути  ${tender status}


cтатус тендера повинен бути
    [Arguments]  ${status should}
    ${status is}  smarttender.сторінка_детальної_інформації отримати status
    Should Be Equal  '${status should}'  '${status is}'
#################################################


перейти до тестових торгів
	go to  https://test.smarttender.biz/test-tenders/


сторінка_торгів ввести текст в поле пошуку
	[Arguments]  ${text}
	input text  //input[@name="filter"]  ${text}


сторінка_торгів виконати пошук
	click element  //div[text()='Пошук']/..
	loading дочекатись закінчення загрузки сторінки


сторінка_торгів перейти за першим результатом пошуку
	${tender_number}  set variable  1
	${link}  get element attribute  //*[@id="tenders"]//*[@class="head"][${tender_number}]//*[@href]@href
	log  tender_link: ${link}  WARN
	go to  ${link}


loading дочекатись закінчення загрузки сторінки
    [Arguments]  ${time_to_wait}=120
    ${current_locationa}  Get Location
	Run Keyword And Ignore Error  loading дочекатися відображення елемента на сторінці  ${loadings}  1
	loading дочекатися зникнення елемента зі сторінки  ${loadings}  ${time_to_wait}
	${is visible}  Run Keyword And Return Status  loading дочекатися відображення елемента на сторінці  ${loadings}  0.5
	Run Keyword If  ${is visible}  loading дочекатись закінчення загрузки сторінки


loading дочекатися відображення елемента на сторінці
	[Arguments]  ${locator}  ${timeout}=10s
	Log  Element Should Be Visible "${locator}" after ${timeout}
	Register Keyword To Run On Failure  No Operation
	Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  ${timeout}  .5  Element Should Be Visible  ${locator}
	Register Keyword To Run On Failure  Capture Page Screenshot
	[Teardown]  Run Keyword If  "${KEYWORD STATUS}" == "FAIL"
	...  Element Should Be Visible  ${locator}  Oops!${\n}Element "${locator}" is not visible after ${timeout} (s/m).


loading дочекатися зникнення елемента зі сторінки
	[Documentation]  timeout=...s/...m
	[Arguments]  ${locator}  ${timeout}=10s
	Log  Element Should Not Be Visible "${locator}" after ${timeout}
	Register Keyword To Run On Failure  No Operation
	Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  ${timeout}  .5  Element Should Not Be Visible  ${locator}
	Register Keyword To Run On Failure  Capture Page Screenshot
	[Teardown]  Run Keyword If  "${KEYWORD STATUS}" == "FAIL"
	...  Element Should Not Be Visible  ${locator}  Oops!${\n}Element "${locator}" is visible after ${timeout} (s/m).


Дочекатись синхронізації
	${url}  Set Variable  http://test.smarttender.biz/ws/webservice.asmx/Execute?calcId=_QA.GET.LAST.SYNCHRONIZATION&args={"SEGMENT":3}
	${response}  evaluate  requests.get('${url}').content  requests
	${a}  Replace String  ${response}   \n  ${Empty}
	${content}  Get Regexp Matches  ${a}  {(?P<content>.*)}  content
	${reg}  evaluate  re.search(r'"DateStart":"(?P<DateStart>.*)","DateEnd":"(?P<DateEnd>.*)","WorkStatus":"(?P<WorkStatus>.*)","Success":(?P<Success>.*)', '${content[0]}')  re

	${DateStart}  evaluate  "${reg.group('DateStart')}"
	${DateEnd}  evaluate  "${reg.group('DateEnd')}"
	${WorkStatus}  evaluate  "${reg.group('WorkStatus')}"
	${Success}  evaluate  "${reg.group('Success')}"

	${result}  Subtract Date From Date  ${DateStart}  ${TENDER['LAST_MODIFICATION_DATE']}  date1_format=%d.%m.%Y %H:%M:%S  date2_format=%Y-%m-%d %H:%M:%S.%f
	${status}  set variable if  ${result} > 0  ${True}
	${status}  Run Keyword if  ${status} and '${DateEnd}' != '${EMPTY}' and '${WorkStatus}' != 'working' and '${WorkStatus}' != 'fail' and '${Success}' == 'true'
	...  Set Variable  Pass
	Should Be Equal  ${status}  Pass
	reload page
	loading дочекатись закінчення загрузки сторінки



сторінка_детальної_інформації активувати вкладку
    [Arguments]  ${tab_name}
    ${tab_selector}  Set Variable  //*[@data-qa="tabs"]//*[text()="${tab_name}"]
    Wait Until Keyword Succeeds  10  2  Click Element  ${tab_selector}
    loading дочекатись закінчення загрузки сторінки
    ${status}  Run Keyword And Return Status
    ...  Element Should Be Visible  ${tab_selector}/ancestor::div[contains(@class,"tab-active")]
    Run Keyword If  '${status}' == 'False'  Click Element  ${tab_selector}


################################################################################
#                           ПОДАТИ ПРОПОЗИЦІЮ                                  #
################################################################################


пропозиція_перевірити кнопку подачі пропозиції
    ${button}  Set Variable  xpath=//*[@class='show-control button-lot']|//*[@data-qa="bid-button"]
    loading дочекатися відображення елемента на сторінці  ${button}
    smarttender.Open button  ${button}
    Location Should Contain  /edit/
    Wait Until Keyword Succeeds  5m  3  Run Keywords
    ...  Reload Page  AND
    ...  Element Should Not Be Visible  //*[@class='modal-dialog ']//h4


пропозиція_заповнити поле з ціною
    [Documentation]  takes lot number and coefficient
    ...  fill bid field with max available price
    [Arguments]  ${lot number}  ${coefficient}
    ${block}  set variable  //*[@class="ivu-card ivu-card-bordered"]
    ${block number}  Set Variable  ${lot number}+1
    ##############################################
    #   Визначаємо мінімальний крок з даних на сторінці
    ${a}  Get Text  xpath=(${block})\[${block number}]//div[@class="amount lead"][1]
    ${a}  evaluate  re.search(u'(?P<amount>[\\d].+\\d\\s)', "${a}").group("amount")  re
    ${a}  evaluate  float(str('${a}'.replace(" ", "")).replace(",", "."))
    ${amount}=  Evaluate  int(${a}*${coefficient})
    ##############################################
    #${amount}  Run Keyword If  ${amount} == 0  Set Variable  1  ELSE
    #...  Set Variable  ${amount}
    ${field number}=  Evaluate  ${lot number}-1
    Input Text  xpath=//*[@id="lotAmount${field number}"]/input[1]  ${amount}


пропозиція_відмітити чекбокси за необхідністю
    ${checkbox1}   set variable         //*[@id="SelfEligible"]//input
    ${checkbox2}   set variable         //*[@id="SelfQualified"]//input
    ${is visible}  run keyword and return status  element should be visible  ${checkbox1}
    run keyword if  ${is visible}  run keywords
    ...  Click Element  ${checkbox1}            AND
	...  Click Element  ${checkbox2}


пропозиція_подати пропозицію
	${message}  smarttender.натиснути надіслати пропозицію та вичитати відповідь
	smarttender.виконати дії відповідно повідомленню  ${message}


натиснути надіслати пропозицію та вичитати відповідь
    ${send offer button}   set variable  css=button#submitBidPlease
    ${validation message}  set variable  //*[@class="ivu-modal-content"]//*[@class="ivu-modal-confirm-body"]//div[text()]
    Click Element  ${send offer button}
	smarttender.закрити валідаційне вікно (Так/Ні)  Рекомендуємо Вам для файлів з ціновою пропозицією обрати тип  Ні
	loading дочекатись закінчення загрузки сторінки
	${status}  ${message}  Run Keyword And Ignore Error  Get Text  ${validation message}
	capture page screenshot  ${OUTPUTDIR}/my_screen{index}.png
	[Return]  ${message}


виконати дії відповідно повідомленню
    [Arguments]  ${message}
    ${succeed}       set variable                   Пропозицію прийнято
    ${succeed2}      set variable                   Не вдалося зчитати пропозицію з ЦБД!
    ${empty error}   set variable                   ValueError: Element locator
    ${error1}        set variable                   Не вдалося подати пропозицію
    ${error2}        set variable                   Виникла помилка при збереженні пропозиції.
    ${error3}        set variable                   Непередбачувана ситуація
    ${error4}        set variable                   В даний момент вже йде подача/зміна пропозиції по тендеру від Вашої організації!
    ${ok button}     set variable                   //div[@class="ivu-modal-body"]/div[@class="ivu-modal-confirm"]//button

	Run Keyword If  "${empty error}" in """${message}"""  smarttender.пропозиція_подати пропозицію
	...  ELSE IF  "${error1}" in """${message}"""  Ignore error
	...  ELSE IF  "${error2}" in """${message}"""  Ignore error
	...  ELSE IF  "${error3}" in """${message}"""  Ignore error
	...  ELSE IF  "${error4}" in """${message}"""  Ignore error
	...  ELSE IF  "${succeed}" in """${message}"""  Click Element  ${ok button}
	...  ELSE IF  "${succeed2}" in """${message}"""  Click Element  ${ok button}
	...  ELSE  Fail  Look to message above
	loading дочекатися зникнення елемента зі сторінки  ${ok button}


закрити валідаційне вікно (Так/Ні)
	[Arguments]  ${title}  ${action}
	${button1}  Set Variable  xpath=//div[contains(text(),'${title}')]/ancestor::div[@class="ivu-modal-confirm"]//button/span[text()="${action}"]
	${button2}  Set Variable  xpath=//div[contains(text(),'${title}')]/ancestor::div[@class="ivu-poptip-inner"]//button/span[text()="${action}"]
	${button}   Set Variable  ${button1}|${button2}
	${status}  Run Keyword And Return Status  Wait Until Page Contains Element  ${button}  3
	Run Keyword If  '${status}' == 'True'  Click Element  ${button}


пропозиція_видалити файл
    [Arguments]  ${doc_id}
	${doc_block}  set variable  xpath=//*[@data-qa="file-name"][contains(text(),"${doc_id}")]/ancestor::div[@class="file ivu-row"]
    click element  ${doc_block}//button[@outlined]
    smarttender.закрити валідаційне вікно (Так/Ні)  Видалити файл?  Так


################################################################################
#                               ЗАПИТАННЯ                                      #
################################################################################
запитання_вибрати тип запитання
    [Arguments]  ${type}
    ${dropdown_selector}  set variable  xpath=//*[@data-qa="questions"]//*[@class="ivu-select-selection"]
    ${type_selector}      set variable  xpath=//*[@class="ivu-select-dropdown-list"]/li[contains(text(),"${type}")]
    click element  ${dropdown_selector} /i[last()]
    loading дочекатися відображення елемента на сторінці  ${type_selector}
    click element  ${type_selector}
    sleep  2
    ${get}  get text by JS  ${dropdown_selector}
    should contain  ${get}  ${type}


запитання_натиснути кнопку "Поставити запитання"
    ${question button}    Set Variable  //*[@data-qa="questions"]//button[contains(@class,"question-button")]
    ${question send btn}  Set Variable  //*[@data-qa="questions"]//button[contains(@class,"btn-success")]
    loading дочекатися відображення елемента на сторінці  ${question button}
    #Scroll Page To Element XPATH   ${question button}
    Click Element                  ${question button}
    Wait Until Element Is Visible  ${question send btn}


запитання_заповнити тему
    [Arguments]  ${text}
    ${question theme}  Set Variable  //*[@data-qa="questions"]//label[text()="Тема"]/following-sibling::div//input
    loading дочекатися відображення елемента на сторінці  ${question theme}
    Input Text  ${question theme}  ${text}
    Sleep  .5
    ${get}  Get Element Attribute  ${question theme}@value
    Should Be Equal  ${get}  ${text}


запитання_заповнити текст запитання
    [Arguments]  ${text}
    ${question text}  Set Variable  //*[@data-qa="questions"]//label[text()="Запитання"]/following-sibling::div//textarea
    Input Text  ${question text}  ${text}
    Sleep  .5
    ${get}  Get Element Attribute  ${question text}@value
    Should Be Equal  ${get}  ${text}


запитання_натиснути кнопку "Подати"
    ${question send btn}  Set Variable  //*[@data-qa="questions"]//button[contains(@class,"btn-success")]
    Click Element  ${question send btn}
    Run Keyword And Ignore Error  Wait Until Element Is Not Visible  ${question send btn}  30


################################################################################
#                               GET AUCTION HREF                               #
################################################################################


отримати посилання на участь та прегляд аукціону для учасника
	Element Should Not Be Visible  ${view auction btn}   Ой! Що тут робить кнопка "Перегляд аукціону"
	Wait Until Element Is Visible  ${go to auction btn}  10
	Click Element                  ${go to auction btn}
	smarttender.дочекатись формування посилань на аукціон
	${auction_participate_href}    smarttender.отримати URL для участі в аукціоні
	${auction_href}                smarttender.отримати URL на перегляд
	[Return]                       ${auction_participate_href}  ${auction_href}


отримати посилання на прегляд аукціону не учасником
    Element Should Not Be Visible  ${go to auction btn}  Ой! Що тут робить кнопка "До аукціону"
	Wait Until Element Is Visible  ${view auction btn}   10
	Click Element                  ${view auction btn}
	smarttender.дочекатись формування посилань на аукціон
    ${auction_href}                smarttender.отримати URL на перегляд
    [Return]                       ${auction_href}


отримати URL для участі в аукціоні
	${auction_participate_href}  Get Element Attribute  ${participate in auction link}@href
	${status}  Run Keyword And Return Status  Page Should Contain Element  ${participate in auction link}\[@disabled="disabled"]
    Run Keyword If  ${status}  Fail  Ой! Не вдалося отримати посилання. Кнопка взяти участь в аукціоні не активна.
	Run Keyword If  '${auction_participate_href}' == 'None'  smarttender.отримати URL для участі в аукціоні
	[Return]  ${auction_participate_href}


отримати URL на перегляд
	${auction_href}  Get Element Attribute  ${view auction link}@href
	${status}  Run Keyword And Return Status  Page Should Contain Element  ${view auction link}\[@disabled="disabled"]
    Run Keyword If  ${status}  Fail  Ой! Не вдалося отримати посилання. Кнопка до перегляду аукціону не активна.
	Run Keyword If  '${auction_href}' == 'None'  smarttender.отримати URL на перегляд
	[Return]  ${auction_href}


дочекатись формування посилань на аукціон
	${auction loading}  Set Variable  xpath=(//*[@class="ivu-load-loop ivu-icon ivu-icon-load-c"])[1]
	Wait Until Page Does Not Contain Element  ${auction loading}  30
	Sleep  1
################################################################################
