*** Settings ***
Library  Selenium2Screenshots
Library  String
Library  DateTime
Resource  webclient.robot

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


*** Keywords ***
Підготувати клієнт для користувача
	[Arguments]   ${username}
	[Documentation]   Відкрити браузер, створити об’єкт api wrapper, тощо
	Open Browser  ${USERS.users['${username}'].homepage}  ${USERS.users['${username}'].browser}  alias=${username}
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
	no operation
	[Return]  ${tender_data}


Створити тендер
	[Arguments]   ${username}  ${tender_data}
	[Documentation]   Створити тендер з початковими даними tender_data. Повернути uaid створеного тендера.
	${tender_data}  Get From Dictionary  ${tender_data}  data
	webclient.робочий стіл натиснути на елемент за назвою  Публічні закупівлі (тестові)
	webclient.header натиснути на елемент за назвою  OK
	webclient.header натиснути на елемент за назвою  Додати
	run keyword  Створити тендер ${mode}  ${tender_data}
	[Return]  ${tender_uaid}


Створити тендер belowThreshold		#Допорог
	[Arguments]  ${tender_data}
	# JCYJDYS
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

	${count_item}  set variable  1
	:FOR  ${item}  IN  @{tender_data['items']}
	\  Заповнити поля лоту  ${item}
	\  run keyword if  '${count_item}' != '1'  webclient.додати item бланк

	${count_milestone}  set variable  1
	:FOR  ${milestone}  IN  @{tender_data['milestones']}
	\  run keyword if  '${count_milestone}' == '1'  webclient.активувати вкладку умови оплати
	\  Заповнити умови оплати  ${milestone}

	debug


Заповнити поля лоту
  	[Arguments]  ${item}
	${description}  set variable  ${item['description']}
	${quantity}  set variable  ${item['quantity']}
	${unit.name}  set variable  ${item['unit']['name']}
	${classification.id}  set variable  ${item['classification']['id']}
	# мені причудилось що іноді additionalClassifications не присутні в item
	${additionalClassifications.scheme}  set variable  ${item['additionalClassifications'][0]['scheme']}
	${additionalClassifications.description}  set variable  ${item['additionalClassifications'][0]['description']}
	${deliveryAddress.postalCode}  set variable  ${item['deliveryAddress']['postalCode']}
	${deliveryAddress.streetAddress}  set variable  ${item['deliveryAddress']['streetAddress']}
	${deliveryAddress.locality}  set variable  ${item['deliveryAddress']['locality']}
	${deliveryDate.startDate}  set variable  ${item['deliveryDate']['startDate']}
	${deliveryDate.endDate}  set variable  ${item['deliveryDate']['endDate']}
	:FOR  ${field}  in
	...  description
	...  quantity
	...  unit.name
	...  classification.id
	...  additionalClassifications.scheme
	...  additionalClassifications.description
	...  deliveryAddress.postalCode
	...  deliveryAddress.streetAddress
	...  deliveryAddress.locality
	...  deliveryDate.startDate
	...  deliveryDate.endDate
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

  	додати item бланк  index=2
  	:FOR  ${field}  IN
  	...  code
  	...  title
  	...  duration.type
  	...  duration.days
  	...  percentage
  	\  run keyword  заповнити поле для milestone ${field}  ${${field}}

Пошук тендера по ідентифікатору
	[Arguments]   ${username}  ${tender_uaid}
	[Documentation]   Знайти тендер з uaid рівним tender_uaid.
	smarttender.перейти до тестових торгів
	smarttender.сторінка_торгів ввести текст в поле пошуку  ${tender_uaid}
	smarttender.сторінка_торгів виконати пошук
	smarttender.сторінка_торгів перейти за першим результатом пошуку
	${taken_tender_uaid}  smarttender.сторінка_детальної_інформації отримати tender_uaid  tender_uaid
	should be equal as strings  ${taken_tender_uaid}  ${tender_uaid}


Оновити сторінку з тендером
	[Arguments]   ${username}  ${tender_uaid}
    [Documentation]   Оновити сторінку з тендером для отримання потенційно оновлених даних.
	Wait Until Keyword Succeeds  10m  5s  smarttender.Дочекатись синхронізації


###############################################
###############################################
Отримати інформацію із тендера
    [Arguments]  ${username}  ${tender_uaid}  ${field_name}
    [Documentation]  Отримати значення поля field_name для тендера tender_uaid.
    ${field_name_splited}  set variable  ${field_name.split('[')[0]}
#    log to console  Отримати інформацію із тендера
#    debug
    ${field_value}  run keyword  smarttender.сторінка_детальної_інформації отримати ${field_name_splited}  ${field_name}
    [Return]  ${field_value}


сторінка_детальної_інформації отримати tender_uaid
	[Arguments]  ${field_name}
	${selector}  set variable  //*[@data-qa='prozorro-number']//*[@href]
	${field_value}  get text  ${selector}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати title
	[Arguments]  ${field_name}
	${selector}  set variable  //*[@data-qa='title']
	${field_value}  get text  ${selector}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати description
	[Arguments]  ${field_name}
	${selector}  set variable  //*[@data-qa='description']
	${field_value}  get text  ${selector}
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


Внести зміни в тендер
    [Arguments]  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}
    [Documentation]  Змінити значення поля fieldname на fieldvalue для тендера tender_uaid.
	log to console  Внести зміни в тендер
	debug
	
	
Додати предмет закупівлі
    [Arguments]  ${username}  ${tender_uaid}  ${item}
    [Documentation]  Додати дані про предмет item до тендера tender_uaid.
	log to console  Додати предмет закупівлі
	debug


Отримати інформацію із предмету
    [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${field_name}
    [Documentation]  Отримати значення поля field_name з предмету з item_id в описі для тендера tender_uaid.    
	log to console  Отримати інформацію із предмету
	debug
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
	log to console  Задати запитання на тендер
	debug
	
	
Отримати інформацію із запитання
    [Arguments]  ${username}  ${tender_uaid}  ${question_id}  ${field_name}
    [Documentation]  Отримати значення поля field_name із запитання з question_id в описі для тендера tender_uaid.  
	log to console  Отримати інформацію із запитання
	debug
    [Return]  ${question_field_name}
    
    
Відповісти на запитання
    [Arguments]  ${username}  ${tender_uaid}  ${answer_data}  ${question_id}
    [Documentation]  Дати відповідь answer_data на запитання з question_id в описі для тендера tender_uaid.  
	log to console  Відповісти на запитання
	debug
	
	
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
	log to console  Завантажити документ
	debug


Отримати інформацію із документа
    [Arguments]  ${username}  ${tender_uaid}  ${doc_id}  ${field}
    [Documentation]  Отримати значення поля field документа doc_id з тендера tender_uaid для перевірки правильності відображення цього поля.  
	log to console  Отримати інформацію із документа
	debug
    [Return]  ${document_field}
    

Подати цінову пропозицію
    [Arguments]  ${username}  ${tender_uaid}  ${bid}  ${lots_ids}=${None}  ${features_ids}=${None}
    [Documentation]  Подати цінову пропозицію bid для тендера tender_uaid на лоти lots_ids (якщо lots_ids != None) з неціновими показниками features_ids (якщо features_ids != None).  
	log to console  Подати цінову пропозицію
	debug


Отримати інформацію із пропозиції
    [Arguments]  ${username}  ${tender_uaid}  ${field}
    [Documentation]  Отримати значення поля field пропозиції користувача username для тендера tender_uaid.  
	log to console  Отримати інформацію із пропозиції
	debug
    [Return]  ${bid_field}


Змінити цінову пропозицію
    [Arguments]  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}
    [Documentation]  Змінити поле fieldname на fieldvalue цінової пропозиції користувача username для тендера tender_uaid.  
	log to console  Змінити цінову пропозицію
	debug


Завантажити документ в ставку
    [Arguments]  ${username}  ${path}  ${tender_uaid}  ${doc_type}=${documents}
    [Documentation]  Завантажити документ типу doc_type, який знаходиться за шляхом path, до цінової пропозиції користувача username для тендера tender_uaid.  
	log to console  Завантажити документ в ставку
	debug


Змінити документ в ставці
    [Arguments]  ${username}  ${tender_uaid}  ${path}  ${docid}
    [Documentation]  Змінити документ з doc_id в описі в пропозиції користувача username для тендера tender_uaid на документ, який знаходиться по шляху path.  
	log to console  Змінити документ в ставці
	debug


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
	log to console  Отримати посилання на аукціон для глядача
	debug
    [Return]  ${auctionUrl}


Отримати посилання на аукціон для учасника
    [Arguments]  ${username}  ${tender_uaid}  ${lot_id}=${Empty}
    [Documentation]  Отримати посилання на участь в аукціоні для користувача username для тендера tender_uaid (або для лоту з lot_id в описі для тендера tender_uaid, якщо lot_id != Empty).  
	log to console  Отримати посилання на аукціон для учасника
	debug
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
	debug
    [Return]  ${planID}


Пошук плану по ідентифікатору
    [Arguments]  ${username}  ${tender_uaid}
    [Documentation]  Знайти план з uaid рівним tender_uaid.
	log to console  Пошук плану по ідентифікатору
	debug


Отримати інформацію із плану
    [Arguments]  ${username}  ${tender_uaid}  ${field_name}
    [Documentation]  Отримати значення поля field_name для плану tender_uaid.
	log to console  Отримати інформацію із плану
	debug
    [Return]  ${plan_field_name}


Додати предмет закупівлі в план
    [Arguments]  ${username}  ${tender_uaid}  ${item}
    [Documentation]  Додати дані про предмет item до плану tender_uaid.
	log to console  Додати предмет закупівлі в план
	debug


Видалити предмет закупівлі плану
    [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${lot_id}=${Empty}
    [Documentation]  Видалити з плану tender_uaid предмет з item_id в описі (предмет може бути прив'язаним до лоту з lot_id в описі, якщо lot_id != Empty).
	log to console  Видалити предмет закупівлі плану
	debug


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
	[Documentation]  timeout=...s/...m
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