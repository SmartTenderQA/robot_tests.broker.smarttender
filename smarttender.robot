*** Settings ***
Library  	Selenium2Screenshots
Library  	String
Library  	DateTime
Resource  	webclient.robot
Library  	smarttender_service.py
Variables	smarttender_service.py


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
${loading bar}                      //div[@class="ivu-loading-bar"]
${sale web loading}                 //*[contains(@class,'disabled-block')]
${povidomlennya loading}            //*[@class="loading-bar"]
${cpv}                              //*[@id="j2_loading"]
${SMART}                            ${loading}|${circle loading}|${skeleton loading}|${sales spin}|${docs spin}|${loading bar}|${sale web loading}|${povidomlennya loading}|${cpv}

${loadings}                         ${SMART}|${IT}
######################################

#############GET AUCTION HREF#########
${go to auction btn}                       //*[@data-qa="button-poptip-participate-view"]
${view auction btn}                        //*[@data-qa="button-poptip-view"]
${participate in auction link}             //*[@data-qa="link-participate"]
${view auction link}                       //*[@data-qa="link-view"]
######################################

#########  ELEMENTS  #################
${selectInputNew_input}           //div[@class="select-input-new"]//input
${selectOptions_item}             //*[@class="select-options-items"]
${number_input}                   //div[contains(@class,"number-input-new")]//input
${ivu_datePicker_input}                      //*[contains(@class, "ivu-input-wrapper")]//input
${ivu_datePicker_close}                      //*[contains(@class,"ivu-icon-ios-close")]
######################################


#########  PLAN EDIT PAGE  ###########
${tender_type_root}                 //*[@data-qa="plan-detail-BiddingTypeId"]
${year_root}                        //*[@data-qa="plan-detail-PurchaseYearFrom"]
${year_to_root}                     //*[@data-qa="plan-detail-PurchaseYearTo"]
${plan_desc_input}                  //*[@data-qa="plan-detail-Title"]//input
${amount_root}                      //*[@data-qa="plan-detail-Amount"]
${currency_root}                    //*[@data-qa="plan-detail-CurrencyId"]
${plan_start_root}                  //*[@data-qa="plan-detail-TenderStartDate"]
${bayer_root}                       //*[@data-qa="purchaser-PurchaserOrganizationId"]
${cpv_input}                        //*[@class="search-section"]//input
${breakdown_root}                   //*[@data-qa="financing-card-Title"]
${breakdownAmount_root}             //*[@data-qa="financing-card-Amount"]
${breakdownDecription_input}        //*[@data-qa="financing-card-Description"]//textarea
${plan_item_title_input}            //*[@data-qa="nomenclature-Title"]//input
${plan_item_quantity_root}          //*[@data-qa="nomenclature-Quantity"]
${plan_item_unit_name_root}         //*[@data-qa="nomenclature-UnitId"]
${deliveryDate_root}                //*[@data-qa="nomenclature-delivery-date-to"]
${agreement_cdb_number}
######################################
${time_zone}                        +02:00
${tender_cdb_id}                    ${None}

${hub}
${hub_url}                              http://autotest.it.ua:4445/wd/hub



*** Keywords ***
Підготувати клієнт для користувача
	[Arguments]   ${username}
	[Documentation]   Відкрити браузер, створити об’єкт api wrapper, тощо
	${capabilities}  evaluate  dict({'browserName': 'chrome', 'version': '', 'platform': 'ANY', 'goog:chromeOptions': {'extensions': [], 'args': ['--window-size=1920,1080']}, 'sessionTimeout': '120m', 'browserVersion': 'Last', 'name': '${MODE} - ${role} - ${SUITE NAME}'})
	# Для відкривання старта браузера локально або в ремоуті
	Run Keyword If  (${hub.__len__()} != 0) or ("Complaints" in "${suite name}") or ("framework" in "${mode}")
			...  Create Webdriver  Chrome  alias=${username}
	...  ELSE
			...  Create Webdriver  Remote  alias=${username}  command_executor=${hub_url}  desired_capabilities=${capabilities}
    smart go to  ${USERS.users['${username}'].homepage}
	maximize browser window
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
    ${tender_data}  run keyword if
    ...  ("${role_name}" == "tender_owner") and ("${MODE}" != "open_esco")  replace_unit_name  ${tender_data}
    ...  ELSE                                                               set variable       ${tender_data}
    ${tender_data}  run keyword if
    ...  "${role_name}" == "viewer"  replace_delivery_address_for_viewer  ${tender_data}
    ...  ELSE                        replace_delivery_address             ${tender_data}
    ${tender_data}  run keyword if
    ...  "${role_name}" == "tender_owner"  replace_procuringEntity  ${tender_data}
    ...  ELSE                              set variable             ${tender_data}
    ${tender_data}  run keyword if
    ...  "${role_name}" == "viewer"  replacee_procuringEntity  ${tender_data}
    ...  ELSE                        set variable              ${tender_data}
    ${tender_data}  run keyword if
    ...  "${MODE}" == "open_esco"  replace_minimalStepPercentage  ${tender_data}
    ...  ELSE                      set variable                   ${tender_data}
    ${tender_data}  run keyword if
    ...  "${MODE}" == "open_framework"  replace_agreementDuration  ${tender_data}
    ...  ELSE                           set variable                ${tender_data}
    ${tender_data}  run keyword if
    ...  "${role_name}" == "tender_owner"  replace_funders  ${tender_data}
    ...  ELSE                           set variable        ${tender_data}
	${tender_data}  clear_additional_classifications  ${tender_data}
	log  ${tender_data}
	log to console  ${tender_data}
	[Return]  ${tender_data}


Підготувати дані для оголошення не плану
	[Arguments]  ${tender_data}
	log to console  Підготувати дані для оголошення не плану
	${tender_data}  replace_delivery_address  ${tender_data}
	${tender_data}  run keyword if
	...  'tender_owner' in '${username.lower()}'  adapt_data  ${tender_data}
	...  ELSE  set variable  ${tender_data}
	[Return]  ${tender_data}


Підготувати дані для оголошення плану
  	[Arguments]  ${tender_data}
  	log to console  Підготувати дані для оголошення плану
	${tedner_data}  adapt_data  ${tender_data}
  	[Return]  ${tender_data}


Створити тендер
	[Arguments]   ${username}  ${tender_data}  ${plan_uaid}
	[Documentation]   Створити тендер з початковими даними tender_data. Повернути uaid створеного тендера.
	${tender_data}  get from dictionary  ${tender_data}  data
	set global variable  ${tender_data}
	${multilot}  set variable if  '${NUMBER_OF_LOTS}' != '0'  ${SPACE}multilot  ${EMPTY}
	run keyword  Оголосити закупівлю ${mode}${multilot}  ${tender_data}
	${tender_uaid}  webclient.отримати номер тендера
	[Return]  ${tender_uaid}
	[Teardown]  Run Keyword If  "${KEYWORD STATUS}" == "FAIL"  run keywords
	...  capture page screenshot        AND
	...  fatal error  Тендер на створено!!!


Створити тендер другого етапу
    [Arguments]  ${username}  ${tender_data}
	${tender_data}  get from dictionary  ${tender_data}  data
	set global variable  ${tender_data}
	${multilot}  set variable if  '${NUMBER_OF_LOTS}' != '0'  ${SPACE}multilot  ${EMPTY}
	run keyword  Оголосити закупівлю ${mode}${multilot}  ${tender_data}
	${tender_uaid}  webclient.отримати номер тендера
	set global variable  ${tender_detail_page}  https://test.smarttender.biz/publichni-zakupivli-prozorro/${tender_uaid}/
	[Return]  ${tender_uaid}
	[Teardown]  Run Keyword If  "${KEYWORD STATUS}" == "FAIL"  run keywords
	...  capture page screenshot        AND
	...  fatal error  Тендер на створено!!!


Отримати номер плану з артифакту
	${file_path}  Get Variable Value  ${ARTIFACT_FILE}  artifact_plan.yaml
	${ARTIFACT}  Load Data From  ${file_path}
	${plan_uaid}  set variable  ${ARTIFACT['tender_uaid']}
	[Return]  ${plan_uaid}


Отримати номер тендера з артифакту
	${file_path}  Get Variable Value  ${ARTIFACT_FILE}  artifact.yaml
	${ARTIFACT}  Load Data From  ${file_path}
	${tender_uaid}  set variable  ${ARTIFACT['tender_uaid']}
	[Return]  ${tender_uaid}


Оголосити закупівлю framework_selection multilot
    [Arguments]  ${tender_data}
    log to console  Оголосити закупівлю framework_selection multilot
    # ОСНОВНІ ПОЛЯ
    ${title}  set variable  ${tender_data['title']}
    ${title_en}  set variable  ${tender_data['title_en']}
    ${description}  set variable  ${tender_data['description']}
    ${description_en}  set variable  ${tender_data['description_en']}

    ${1st_agreement_tender_uaid}  Отримати номер тендера з артифакту
    smarttender.Оголосити відбір framework_selection  ${1st_agreement_tender_uaid}  ${title}  ${title_en}

    smart go to  http://test.smarttender.biz/webclient/?testmode=1&proj=it_uk&tz=3
	webclient.робочий стіл натиснути на елемент за назвою  Рамкові угоди 2 етап(тестові)
	webclient.header натиснути на елемент за назвою  Очистити
	webclient.header натиснути на елемент за назвою  OK
    webclient.пошук тендера по title  ${title}


Оголосити відбір framework_selection
    [Arguments]  ${1st_agreement_tender_uaid}  ${title}  ${title_en}
    log to console  Оголосити відбір framework_selection
    smarttender.Пошук угоди по ідентифікатору  owner  ${1st_agreement_tender_uaid}-a1
    button type=button click by text  Коригувати угоду
    button type=button click by text  Опублікувати запрошення на 2 етап

    ${title_input}     set variable  xpath=//*[@data-qa="purchase-tab"]/div[2]//textarea
    ${title_en_input}  set variable  xpath=//*[@data-qa="purchase-tab"]/div[3]//textarea
    ${checkbox}        set variable  xpath=//*[@data-qa="purchase-tab"]/div[6]//*[@class="smt-checkbox-item"]
    ${success_msg}     set variable  xpath=//*[.="Оголошення відправлено."]
    заповнити simple input  ${title_input}     ${title}
    заповнити simple input  ${title_en_input}  ${title_en}
    click element  ${checkbox}
    loading дочекатись закінчення загрузки сторінки
    button type=button click by text  Підтвердити запрошення
    loading дочекатися відображення елемента на сторінці  ${success_msg}


Оголосити закупівлю belowThreshold		#Допорог
	[Arguments]  ${tender_data}
	${plan_uaid}  Отримати номер плану з артифакту
    знайти план у webclient  ${plan_uaid}
   	webclient.header натиснути на елемент за назвою             Розрахунок
    dialog box вибрати строку зі списка  Сформировать закупку из планов  delta=2
	screen заголовок повинен містити     Сформувати однолотову чи багатолотову закупівлю?
	screen натиснути кнопку  однолотову
	screen заголовок повинен містити     Додавання. Тендери
    webclient.видалити всі лоти та предмети
    webclient.додати бланк  GRID_ITEMS
	# ОСНОВНІ ПОЛЯ
	${enquiryPeriod.endDate}  set variable  ${tender_data['enquiryPeriod']['endDate']}
	${tenderPeriod.startDate}  set variable  ${tender_data['tenderPeriod']['startDate']}
	${tenderPeriod.endDate}  set variable  ${tender_data['tenderPeriod']['endDate']}
	${value.amount}  set variable  ${tender_data['value']['amount']}
	${value.valueAddedTaxIncluded}  set variable  ${tender_data['value']['valueAddedTaxIncluded']}
	${minimalStep.amount}  set variable  ${tender_data['minimalStep']['amount']}
	${title}  set variable  ${tender_data['title']}
	${description}  set variable  ${tender_data['description']}
	${mainProcurementCategory}  set variable  ${tender_data['mainProcurementCategory']}

	:FOR  ${field}  in
	...  enquiryPeriod.endDate
	...  tenderPeriod.startDate
	...  tenderPeriod.endDate
	...  value.amount
	...  value.valueAddedTaxIncluded
	...  minimalStep.amount
	...  title
	...  description
	...  mainProcurementCategory
	\  run keyword  webclient.заповнити поле ${field}  ${${field}}

    # ДОНОРИ
	${is_funders}  ${funders}  run keyword and ignore error  set variable  ${tender_data['funders']}
	run keyword if  '${is_funders}' == 'PASS'  smarttender.вибрати донора  ${funders}

	# ПРЕДМЕТИ
	${count_item}  set variable  1
	:FOR  ${item}  IN  @{tender_data['items']}
	\  run keyword if  '${count_item}' != '1'  webclient.додати бланк  GRID_ITEMS_HIERARCHY
	\  Заповнити поля предмету  ${item}
	\  ${count_item}  evaluate  ${count_item} + 1

    # ЯКІСНІ ПОКАЗНИКИ
    ${is_features}  ${features}  run keyword and ignore error  set variable  ${tender_data['features']}
	run keyword if  '${is_features}' == 'PASS'  smarttender.додати якісні показники  ${features}

	# УМОВИ ОПЛАТИ
	${is_milestones}  ${milestones}  run keyword and ignore error  set variable  ${tender_data['milestones']}
	run keyword if  '${is_milestones}' == 'PASS'  smarttender.додати умови оплати  ${milestones}
	...  ELSE                                     smarttender.додати умови оплати fake

	webclient.додати тендерну документацію
	webclient.header натиснути на елемент за назвою  Додати
	${status}  ${ret}  run keyword and ignore error
	...  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  '${status}' == 'PASS'  run keyword and ignore error
	...  dialog box натиснути кнопку  Так

	dialog box заголовок повинен містити  Оголосити закупівлю?
	dialog box натиснути кнопку  Так
	webclient.screen заголовок повинен містити  Завантаження документації
	click element   ${screen_root_selector}//*[@alt="Close"]
	loading дочекатись закінчення загрузки сторінки
	webclient.пошук тендера по title  ${tender_data['title']}


Оголосити закупівлю belowThreshold multilot		#Допорог мультилот
	[Arguments]  ${tender_data}
	${plan_uaid}  Отримати номер плану з артифакту
    знайти план у webclient  ${plan_uaid}
   	webclient.header натиснути на елемент за назвою             Розрахунок
    dialog box вибрати строку зі списка  Сформировать закупку из планов  delta=2
	screen заголовок повинен містити     Сформувати однолотову чи багатолотову закупівлю?
	screen натиснути кнопку  мультилотову
	screen заголовок повинен містити     Додавання. Тендери
    webclient.видалити всі лоти та предмети
    webclient.додати бланк  GRID_ITEMS_HIERARCHY
	# ОСНОВНІ ПОЛЯ
	${enquiryPeriod.endDate}  set variable  ${tender_data['enquiryPeriod']['endDate']}
	${tenderPeriod.startDate}  set variable  ${tender_data['tenderPeriod']['startDate']}
	${tenderPeriod.endDate}  set variable  ${tender_data['tenderPeriod']['endDate']}
	${title}  set variable  ${tender_data['title']}
	${description}  set variable  ${tender_data['description']}
	${mainProcurementCategory}  set variable  ${tender_data['mainProcurementCategory']}

	:FOR  ${field}  in
	...  enquiryPeriod.endDate
	...  tenderPeriod.startDate
	...  tenderPeriod.endDate
	...  title
	...  description
	...  mainProcurementCategory
	\  run keyword  webclient.заповнити поле ${field}  ${${field}}

    # ДОНОРИ
	${is_funders}  ${funders}  run keyword and ignore error  set variable  ${tender_data['funders']}
	run keyword if  '${is_funders}' == 'PASS'  smarttender.вибрати донора  ${funders}

    # ЛОТИ
	:FOR  ${lot}  IN  @{tender_data['lots']}
	\  Заповнити поля лоту  ${lot}

	# ПРЕДМЕТИ
	:FOR  ${item}  IN  @{tender_data['items']}
	\  webclient.додати бланк  GRID_ITEMS_HIERARCHY
	\  Заповнити поля предмету  ${item}

    # ЯКІСНІ ПОКАЗНИКИ
    ${is_features}  ${features}  run keyword and ignore error  set variable  ${tender_data['features']}
	run keyword if  '${is_features}' == 'PASS'  smarttender.додати якісні показники  ${features}

	# УМОВИ ОПЛАТИ
	${is_milestones}  ${milestones}  run keyword and ignore error  set variable  ${tender_data['milestones']}
	run keyword if  '${is_milestones}' == 'PASS'  smarttender.додати умови оплати  ${milestones}
	...  ELSE  debug                                 #   smarttender.додати умови оплати fake  multilot=${True}

    webclient.додати тендерну документацію
	webclient.header натиснути на елемент за назвою  Додати
    ${status}  ${ret}  run keyword and ignore error
	...  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  '${status}' == 'PASS'  run keyword and ignore error
	...  dialog box натиснути кнопку  Так
	dialog box заголовок повинен містити  Оголосити закупівлю?
	dialog box натиснути кнопку  Так
    webclient.screen заголовок повинен містити  Завантаження документації
    click element   ${screen_root_selector}//*[@alt="Close"]
    loading дочекатись закінчення загрузки сторінки
	webclient.пошук тендера по title  ${tender_data['title']}


Оголосити закупівлю openeu		#Відкриті торги з публікацією англійською мовою
	[Arguments]  ${tender_data}
	${plan_uaid}  Отримати номер плану з артифакту
    знайти план у webclient  ${plan_uaid}
   	webclient.header натиснути на елемент за назвою             Розрахунок
    dialog box вибрати строку зі списка  Сформировать закупку из планов  delta=2
	screen заголовок повинен містити     Сформувати однолотову чи багатолотову закупівлю?
	screen натиснути кнопку  однолотову
	screen заголовок повинен містити     Додавання. Тендери
    webclient.видалити всі лоти та предмети
    webclient.додати бланк  GRID_ITEMS_HIERARCHY
	# ОСНОВНІ ПОЛЯ
	${tenderPeriod.endDate}  set variable  ${tender_data['tenderPeriod']['endDate']}
	${value.amount}  set variable  ${tender_data['value']['amount']}
	${value.valueAddedTaxIncluded}  set variable  ${tender_data['value']['valueAddedTaxIncluded']}
	${minimalStep.amount}  set variable  ${tender_data['minimalStep']['amount']}
	${title}  set variable  ${tender_data['title']}
	${description}  set variable  ${tender_data['description']}
	${title_en}  set variable  ${tender_data['title_en']}
	${description_en}  set variable  ${tender_data['description_en']}
	${mainProcurementCategory}  set variable  ${tender_data['mainProcurementCategory']}

	:FOR  ${field}  in
	...  tenderPeriod.endDate
	...  value.amount
	...  value.valueAddedTaxIncluded
	...  minimalStep.amount
	...  title
	...  description
	...  title_en
	...  description_en
	...  mainProcurementCategory
	\  run keyword  webclient.заповнити поле ${field}  ${${field}}

    # ДОНОРИ
	${is_funders}  ${funders}  run keyword and ignore error  set variable  ${tender_data['funders']}
	run keyword if  '${is_funders}' == 'PASS'  smarttender.вибрати донора  ${funders}

	# ПРЕДМЕТИ
	${count_item}  set variable  1
	:FOR  ${item}  IN  @{tender_data['items']}
	\  run keyword if  '${count_item}' != '1'  webclient.додати бланк  GRID_ITEMS_HIERARCHY
	\  Заповнити поля предмету  ${item}
	\  ${count_item}  evaluate  ${count_item} + 1

    # ЯКІСНІ ПОКАЗНИКИ
    ${is_features}  ${features}  run keyword and ignore error  set variable  ${tender_data['features']}
	run keyword if  '${is_features}' == 'PASS'  smarttender.додати якісні показники  ${features}

	# УМОВИ ОПЛАТИ
	${is_milestones}  ${milestones}  run keyword and ignore error  set variable  ${tender_data['milestones']}
	run keyword if  '${is_milestones}' == 'PASS'  smarttender.додати умови оплати  ${milestones}

	webclient.додати тендерну документацію
	webclient.header натиснути на елемент за назвою  Додати
	${status}  ${ret}  run keyword and ignore error
	...  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  '${status}' == 'PASS'  run keyword and ignore error
	...  dialog box натиснути кнопку  Так
	dialog box заголовок повинен містити  Оголосити закупівлю?
	dialog box натиснути кнопку  Так
	webclient.screen заголовок повинен містити  Завантаження документації
	click element   ${screen_root_selector}//*[@alt="Close"]
	loading дочекатись закінчення загрузки сторінки
	dialog box заголовок повинен містити  Накласти ЕЦП/КЕП на тендер?
	dialog box натиснути кнопку  Ні
	webclient.пошук тендера по title  ${tender_data['title']}


Оголосити закупівлю openeu multilot
	[Arguments]  ${tender_data}
	${plan_uaid}  Отримати номер плану з артифакту
    знайти план у webclient  ${plan_uaid}
   	webclient.header натиснути на елемент за назвою             Розрахунок
    dialog box вибрати строку зі списка  Сформировать закупку из планов  delta=2
	screen заголовок повинен містити     Сформувати однолотову чи багатолотову закупівлю?
	screen натиснути кнопку  мультилотову
	screen заголовок повинен містити     Додавання. Тендери
    webclient.видалити всі лоти та предмети
    webclient.додати бланк  GRID_ITEMS_HIERARCHY

    # ОСНОВНІ ПОЛЯ
	${tenderPeriod.endDate}  set variable  ${tender_data['tenderPeriod']['endDate']}
	${title}  set variable  ${tender_data['title']}
	${description}  set variable  ${tender_data['description']}
	${title_en}  set variable  ${tender_data['title_en']}
	${description_en}  set variable  ${tender_data['description_en']}
	${mainProcurementCategory}  set variable  ${tender_data['mainProcurementCategory']}
	:FOR  ${field}  in
	...  tenderPeriod.endDate
	...  title
	...  description
	...  title_en
	...  description_en
	...  mainProcurementCategory
	\  run keyword  webclient.заповнити поле ${field}  ${${field}}

    # ДОНОРИ
	${is_funders}  ${funders}  run keyword and ignore error  set variable  ${tender_data['funders']}
	run keyword if  '${is_funders}' == 'PASS'  smarttender.вибрати донора  ${funders}

    # ЛОТИ
	:FOR  ${lot}  IN  @{tender_data['lots']}
	\  Заповнити поля лоту  ${lot}

	# ПРЕДМЕТИ
	:FOR  ${item}  IN  @{tender_data['items']}
	\  webclient.додати бланк  GRID_ITEMS_HIERARCHY
	\  Заповнити поля предмету  ${item}

    # ЯКІСНІ ПОКАЗНИКИ
    ${is_features}  ${features}  run keyword and ignore error  set variable  ${tender_data['features']}
	run keyword if  '${is_features}' == 'PASS'  smarttender.додати якісні показники  ${features}

	# УМОВИ ОПЛАТИ
	${is_milestones}  ${milestones}  run keyword and ignore error  set variable  ${tender_data['milestones']}
	run keyword if  '${is_milestones}' == 'PASS'  smarttender.додати умови оплати  ${milestones}

    webclient.додати тендерну документацію
	webclient.header натиснути на елемент за назвою  Додати
    ${status}  ${ret}  run keyword and ignore error
	...  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  '${status}' == 'PASS'  run keyword and ignore error
	...  dialog box натиснути кнопку  Так
	dialog box заголовок повинен містити  Оголосити закупівлю?
	dialog box натиснути кнопку  Так
    webclient.screen заголовок повинен містити  Завантаження документації
    click element   ${screen_root_selector}//*[@alt="Close"]
    loading дочекатись закінчення загрузки сторінки
    wait until keyword succeeds  10  1  dialog box заголовок повинен містити  Накласти ЕЦП/КЕП на тендер?
	dialog box натиснути кнопку  Ні
	webclient.пошук тендера по title  ${tender_data['title']}


Оголосити закупівлю openua multilot
	[Arguments]  ${tender_data}
	${plan_uaid}  Отримати номер плану з артифакту
    знайти план у webclient  ${plan_uaid}
   	webclient.header натиснути на елемент за назвою             Розрахунок
    dialog box вибрати строку зі списка  Сформировать закупку из планов  delta=2
	screen заголовок повинен містити     Сформувати однолотову чи багатолотову закупівлю?
	screen натиснути кнопку  мультилотову
	screen заголовок повинен містити     Додавання. Тендери
    webclient.видалити всі лоти та предмети
    webclient.додати бланк  GRID_ITEMS_HIERARCHY
    # ОСНОВНІ ПОЛЯ
	${tenderPeriod.endDate}  set variable  ${tender_data['tenderPeriod']['endDate']}
	${title}  set variable  ${tender_data['title']}
	${description}  set variable  ${tender_data['description']}
	${mainProcurementCategory}  set variable  ${tender_data['mainProcurementCategory']}
	:FOR  ${field}  in
	...  tenderPeriod.endDate
	...  title
	...  description
	...  mainProcurementCategory
	\  run keyword  webclient.заповнити поле ${field}  ${${field}}

    # ДОНОРИ
	${is_funders}  ${funders}  run keyword and ignore error  set variable  ${tender_data['funders']}
	run keyword if  '${is_funders}' == 'PASS'  smarttender.вибрати донора  ${funders}

    # ЛОТИ
	:FOR  ${lot}  IN  @{tender_data['lots']}
	\  Заповнити поля лоту  ${lot}

	# ПРЕДМЕТИ
	:FOR  ${item}  IN  @{tender_data['items']}
	\  webclient.додати бланк  GRID_ITEMS_HIERARCHY
	\  Заповнити поля предмету  ${item}

    # ЯКІСНІ ПОКАЗНИКИ
    ${is_features}  ${features}  run keyword and ignore error  set variable  ${tender_data['features']}
	run keyword if  '${is_features}' == 'PASS'  smarttender.додати якісні показники  ${features}

	# УМОВИ ОПЛАТИ
	${is_milestones}  ${milestones}  run keyword and ignore error  set variable  ${tender_data['milestones']}
	run keyword if  '${is_milestones}' == 'PASS'  smarttender.додати умови оплати  ${milestones}

    webclient.додати тендерну документацію
	webclient.header натиснути на елемент за назвою  Додати
    ${status}  ${ret}  run keyword and ignore error
	...  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  '${status}' == 'PASS'  run keyword and ignore error
	...  dialog box натиснути кнопку  Так
	dialog box заголовок повинен містити  Оголосити закупівлю?
	dialog box натиснути кнопку  Так
	${status}  ${ret}  run keyword and ignore error
	...  dialog box заголовок повинен містити  Увага! Бюджет перевищує
	run keyword if  '${status}' == 'PASS'  run keyword and ignore error
	...  dialog box натиснути кнопку  Так
    webclient.screen заголовок повинен містити  Завантаження документації
    click element   ${screen_root_selector}//*[@alt="Close"]
    loading дочекатись закінчення загрузки сторінки
    wait until keyword succeeds  10  1  dialog box заголовок повинен містити  Накласти ЕЦП/КЕП на тендер?
	dialog box натиснути кнопку  Ні
	webclient.пошук тендера по title  ${tender_data['title']}


Оголосити закупівлю openua_defense multilot
	[Arguments]  ${tender_data}
	${plan_uaid}  Отримати номер плану з артифакту
    знайти план у webclient  ${plan_uaid}
   	webclient.header натиснути на елемент за назвою             Розрахунок
    dialog box вибрати строку зі списка  Сформировать закупку из планов  delta=2
	screen заголовок повинен містити     Сформувати однолотову чи багатолотову закупівлю?
	screen натиснути кнопку  мультилотову
	screen заголовок повинен містити     Додавання. Тендери
    webclient.видалити всі лоти та предмети
    webclient.додати бланк  GRID_ITEMS_HIERARCHY
    # ОСНОВНІ ПОЛЯ
	${tenderPeriod.endDate}  set variable  ${tender_data['tenderPeriod']['endDate']}
	${title}  set variable  ${tender_data['title']}
	${description}  set variable  ${tender_data['description']}
	${mainProcurementCategory}  set variable  ${tender_data['mainProcurementCategory']}

	:FOR  ${field}  in
	...  tenderPeriod.endDate
	...  title
	...  description
	...  mainProcurementCategory
	\  run keyword  webclient.заповнити поле ${field}  ${${field}}

    # ЛОТИ
	:FOR  ${lot}  IN  @{tender_data['lots']}
	\  Заповнити поля лоту  ${lot}

	# ПРЕДМЕТИ
	:FOR  ${item}  IN  @{tender_data['items']}
	\  webclient.додати бланк  GRID_ITEMS_HIERARCHY
	\  Заповнити поля предмету  ${item}

    # ЯКІСНІ ПОКАЗНИКИ
    ${is_features}  ${features}  run keyword and ignore error  set variable  ${tender_data['features']}
	run keyword if  '${is_features}' == 'PASS'  smarttender.додати якісні показники  ${features}

	# УМОВИ ОПЛАТИ
	${is_milestones}  ${milestones}  run keyword and ignore error  set variable  ${tender_data['milestones']}
	run keyword if  '${is_milestones}' == 'PASS'  smarttender.додати умови оплати  ${milestones}

    webclient.додати тендерну документацію
	webclient.header натиснути на елемент за назвою  Додати

	${status}  ${ret}  run keyword and ignore error
	...  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  '${status}' == 'PASS'  run keyword and ignore error
	...  dialog box натиснути кнопку  Так
	dialog box заголовок повинен містити  Оголосити закупівлю?
	dialog box натиснути кнопку  Так

	${status}  ${ret}  run keyword and ignore error
	...  dialog box заголовок повинен містити  Увага! Бюджет перевищує
	run keyword if  '${status}' == 'PASS'  run keyword and ignore //*[@data-qa="tabs"]//*[text()="error
	...  dialog box натиснути кнопку  Так

    webclient.screen заголовок повинен містити  Завантаження документації
    click element   ${screen_root_selector}//*[@alt="Close"]
    loading дочекатись закінчення загрузки сторінки

    wait until keyword succeeds  10  1  dialog box заголовок повинен містити  Накласти ЕЦП/КЕП на тендер?
	dialog box натиснути кнопку  Ні


Оголосити закупівлю reporting  #Договір
	[Arguments]  ${tender_data}
    ${plan_uaid}  Отримати номер плану з артифакту
    знайти план у webclient  ${plan_uaid}
   	webclient.header натиснути на елемент за назвою             Розрахунок
    dialog box вибрати строку зі списка  Сформировать закупку из планов  delta=2
	screen заголовок повинен містити     Додавання. Тендери
    webclient.видалити всі лоти та предмети  screen=GRID_ITEMS
    webclient.додати бланк  GRID_ITEMS
    #  Костыль, потому что не удаляется последняя номеклатура
    grid вибрати рядок за номером  1
    webclient.видалити всі лоти та предмети  screen=GRID_ITEMS
    ##########################################################
	# ОСНОВНІ ПОЛЯ
	${mainProcurementCategory}  set variable  ${tender_data['mainProcurementCategory']}
	${value.amount}  set variable  ${tender_data['value']['amount']}
	${value.valueAddedTaxIncluded}  set variable  ${tender_data['value']['valueAddedTaxIncluded']}
	${title}  set variable  ${tender_data['title']}
	${description}  set variable  ${tender_data['description']}
	:FOR  ${field}  in
	...  mainProcurementCategory
	...  value.amount
	...  value.valueAddedTaxIncluded
	...  title
	...  description
	\  run keyword  webclient.заповнити поле ${field}  ${${field}}

	# ПРЕДМЕТИ
	${count_item}  set variable  1
	:FOR  ${item}  IN  @{tender_data['items']}
	\  run keyword if  '${count_item}' != '1'  webclient.додати бланк  GRID_ITEMS
	\  Заповнити поля предмету  ${item}
	\  ${count_item}  evaluate  ${count_item} + 1

	# УМОВИ ОПЛАТИ
	${is_milestones}  ${milestones}  run keyword and ignore error  set variable  ${tender_data['milestones']}
	run keyword if  '${is_milestones}' == 'PASS'  smarttender.додати умови оплати  ${milestones}

	webclient.додати тендерну документацію
	webclient.header натиснути на елемент за назвою  Додати

	${status}  ${ret}  run keyword and ignore error
	...  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  '${status}' == 'PASS'  run keyword and ignore error
	...  dialog box натиснути кнопку  Так
	dialog box заголовок повинен містити  Оголосити закупівлю?
	dialog box натиснути кнопку  Так
	webclient.screen заголовок повинен містити  Завантаження документації
	click element   ${screen_root_selector}//*[@alt="Close"]
	loading дочекатись закінчення загрузки сторінки
	dialog box заголовок повинен містити  Накласти ЕЦП/КЕП на тендер?
	dialog box натиснути кнопку  Ні


Оголосити закупівлю negotiation multilot
	[Arguments]  ${tender_data}
    ${plan_uaid}  Отримати номер плану з артифакту
    знайти план у webclient  ${plan_uaid}
   	webclient.header натиснути на елемент за назвою             Розрахунок
    dialog box вибрати строку зі списка  Сформировать закупку из планов  delta=2
	screen заголовок повинен містити     Сформувати однолотову чи багатолотову закупівлю?
	screen натиснути кнопку  мультилотову
    ${status}  ${ret}  run keyword and ignore error
	...  dialog box заголовок повинен містити  Увага
	run keyword if  '${status}' == 'PASS'
	...  dialog box натиснути кнопку  ОК  # <--- здесь ОК на кирилице
	screen заголовок повинен містити     Додавання. Тендери
    webclient.видалити всі лоти та предмети
    webclient.додати бланк  GRID_ITEMS_HIERARCHY
    #  Костыль, потому что не удаляется последняя номеклатура
    grid вибрати рядок за номером  1
    webclient.видалити всі лоти та предмети  screen=GRID_ITEMS
    ##########################################################

	# ОСНОВНІ ПОЛЯ
	${mainProcurementCategory}  set variable  ${tender_data['mainProcurementCategory']}
	${title}  set variable  ${tender_data['title']}
	${description}  set variable  ${tender_data['description']}
	${cause}  set variable  ${tender_data['cause']}
	${cause_description}  set variable  ${tender_data['causeDescription']}

	:FOR  ${field}  in
	...  mainProcurementCategory
	...  title
	...  description
	...  cause
	...  cause_description
	\  run keyword  webclient.заповнити поле ${field}  ${${field}}

	# ЛОТИ
	${lot_index}  set variable  1
	:FOR  ${lot}  IN  @{tender_data['lots']}
	\  run keyword if  '${lot_index}' != '1'  run keywords
	\  ...  webclient.додати бланк  GRID_ITEMS_HIERARCHY  AND
	\  ...  Змінити номенклатуру на лот
	\  Заповнити поля лоту  ${lot}
	\  ${lot_id}  set variable  ${lot['id']}
	\  Заповнити поля для items по lot_id  ${lot_id}  @{tender_data['items']}
	\  ${lot_index}  evaluate  ${lot_index}+1

	${is_milestones}  ${milestones}  run keyword and ignore error  set variable  ${tender_data['milestones']}
	run keyword if  '${is_milestones}' == 'PASS'  smarttender.додати умови оплати  ${milestones}

    webclient.додати тендерну документацію
	webclient.header натиснути на елемент за назвою  Додати
	${status}  ${ret}  run keyword and ignore error
	...  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  '${status}' == 'PASS'  run keyword and ignore error
	...  dialog box натиснути кнопку  Так
	dialog box заголовок повинен містити  Оголосити закупівлю?
	dialog box натиснути кнопку  Так
	webclient.screen заголовок повинен містити  Завантаження документації
    click element   ${screen_root_selector}//*[@alt="Close"]
    loading дочекатись закінчення загрузки сторінки
    wait until keyword succeeds  10  1  dialog box заголовок повинен містити  Накласти ЕЦП/КЕП на тендер?
	dialog box натиснути кнопку  Ні


Оголосити закупівлю negotiation
	[Arguments]  ${tender_data}
    ${plan_uaid}  Отримати номер плану з артифакту
    знайти план у webclient  ${plan_uaid}
   	webclient.header натиснути на елемент за назвою             Розрахунок
    dialog box вибрати строку зі списка  Сформировать закупку из планов  delta=2
	screen заголовок повинен містити     Сформувати однолотову чи багатолотову закупівлю?
	screen натиснути кнопку  однолотову
	${status}  ${ret}  run keyword and ignore error
	...  dialog box заголовок повинен містити  Увага
	run keyword if  '${status}' == 'PASS'
	...  dialog box натиснути кнопку  ОК  # <--- здесь ОК на кирилице
	screen заголовок повинен містити     Додавання. Тендери
    webclient.видалити всі лоти та предмети  screen=GRID_ITEMS
    webclient.додати бланк  GRID_ITEMS
    #  Костыль, потому что не удаляется последняя номеклатура
    grid вибрати рядок за номером  1
    webclient.видалити всі лоти та предмети  screen=GRID_ITEMS
    ##########################################################

	# ОСНОВНІ ПОЛЯ
	${amount}  set variable  ${tender_data['value']['amount']}
	${mainProcurementCategory}  set variable  ${tender_data['mainProcurementCategory']}
	${title}  set variable  ${tender_data['title']}
	${description}  set variable  ${tender_data['description']}
	${cause}  set variable  ${tender_data['cause']}
	${cause_description}  set variable  ${tender_data['causeDescription']}

    заповнити поле value.amount  ${amount}

	:FOR  ${field}  in
	...  mainProcurementCategory
	...  title
	...  description
	...  cause
	...  cause_description
	\  run keyword  webclient.заповнити поле ${field}  ${${field}}

	# ПРЕДМЕТИ
	${count_item}  set variable  1
	:FOR  ${item}  IN  @{tender_data['items']}
	\  run keyword if  '${count_item}' != '1'  webclient.додати бланк  GRID_ITEMS
	\  Заповнити поля предмету  ${item}
	\  ${count_item}  evaluate  ${count_item} + 1

	${is_milestones}  ${milestones}  run keyword and ignore error  set variable  ${tender_data['milestones']}
	run keyword if  '${is_milestones}' == 'PASS'  smarttender.додати умови оплати  ${milestones}

    webclient.додати тендерну документацію
	webclient.header натиснути на елемент за назвою  Додати
	${status}  ${ret}  run keyword and ignore error
	...  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  '${status}' == 'PASS'  run keyword and ignore error
	...  dialog box натиснути кнопку  Так
	dialog box заголовок повинен містити  Оголосити закупівлю?
	dialog box натиснути кнопку  Так
	webclient.screen заголовок повинен містити  Завантаження документації
    click element   ${screen_root_selector}//*[@alt="Close"]
    loading дочекатись закінчення загрузки сторінки
    wait until keyword succeeds  10  1  dialog box заголовок повинен містити  Накласти ЕЦП/КЕП на тендер?
	dialog box натиснути кнопку  Ні



Оголосити закупівлю open_competitive_dialogue multilot
	[Arguments]  ${tender_data}
	${plan_uaid}  Отримати номер плану з артифакту
    знайти план у webclient  ${plan_uaid}
   	webclient.header натиснути на елемент за назвою             Розрахунок
    dialog box вибрати строку зі списка  Сформировать закупку из планов  delta=2
	screen заголовок повинен містити     Сформувати однолотову чи багатолотову закупівлю?
	screen натиснути кнопку  мультилотову
	screen заголовок повинен містити     Додавання. Тендери
    webclient.видалити всі лоти та предмети
    webclient.додати бланк  GRID_ITEMS_HIERARCHY

	# ОСНОВНІ ПОЛЯ
	${tenderPeriod.endDate}  set variable  ${tender_data['tenderPeriod']['endDate']}
	${title}  set variable  ${tender_data['title']}
	${description}  set variable  ${tender_data['description']}
	${mainProcurementCategory}  set variable  ${tender_data['mainProcurementCategory']}
	${title_en}  set variable  ${tender_data['title_en']}
	${description_en}  set variable  ${tender_data['description_en']}

	${list_of_fields}  create list
	...  tenderPeriod.endDate
	...  title
	...  description
	...  mainProcurementCategory

	run keyword if  "${tender_data['procurementMethodType']}" == "competitiveDialogueEU"
	...  append to list  ${list_of_fields}
	...  title_en
	...  description_en

	:FOR  ${field}  in  @{list_of_fields}
	\  run keyword  webclient.заповнити поле ${field}  ${${field}}

	# ЛОТИ
	${lot_index}  set variable  1
	:FOR  ${lot}  IN  @{tender_data['lots']}
	\  run keyword if  '${lot_index}' != '1'  run keywords
	\  ...  webclient.додати бланк  GRID_ITEMS_HIERARCHY  AND
	\  ...  Змінити номенклатуру на лот
	\  Заповнити поля лоту  ${lot}
	\  ${lot_id}  set variable  ${lot['id']}
	\  Заповнити поля для items по lot_id  ${lot_id}  @{tender_data['items']}
	\  ${lot_index}  evaluate  ${lot_index}+1

	# УМОВИ ОПЛАТИ
	${is_milestones}  ${milestones}  run keyword and ignore error  set variable  ${tender_data['milestones']}
	run keyword if  '${is_milestones}' == 'PASS'  smarttender.додати умови оплати  ${milestones}

	webclient.header натиснути на елемент за назвою  Додати
    ${status}  ${ret}  run keyword and ignore error
	...  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  '${status}' == 'PASS'  run keyword and ignore error
	...  dialog box натиснути кнопку  Так
	dialog box заголовок повинен містити  Оголосити закупівлю?
	dialog box натиснути кнопку  Так
	${status}  ${ret}  run keyword and ignore error
	...  dialog box заголовок повинен містити  Увага! Бюджет перевищує 133 000 євро. Вам потрібно обрати тип процедури «Відкриті торги з публікаціє...
	run keyword if  '${status}' == 'PASS'  run keyword and ignore error
	...  dialog box натиснути кнопку  Так
	run keyword and ignore error  dialog box заголовок повинен містити  Накласти ЕЦП/КЕП на тендер?
	run keyword and ignore error  dialog box натиснути кнопку  Ні


Оголосити закупівлю open_esco multilot
	[Arguments]  ${tender_data}
	${plan_uaid}  Отримати номер плану з артифакту
    знайти план у webclient  ${plan_uaid}
   	webclient.header натиснути на елемент за назвою             Розрахунок
    dialog box вибрати строку зі списка  Сформировать закупку из планов  delta=2
	screen заголовок повинен містити     Сформувати однолотову чи багатолотову закупівлю?
	screen натиснути кнопку  мультилотову
	screen заголовок повинен містити     Додавання. Тендери
    webclient.видалити всі лоти та предмети
    webclient.додати бланк  GRID_ITEMS_HIERARCHY

	${tenderPeriod.endDate}  set variable  ${tender_data['tenderPeriod']['endDate']}
	${title}  set variable  ${tender_data['title']}
	${description}  set variable  ${tender_data['description']}
	${title_en}  set variable  ${tender_data['title_en']}
	${description_en}  set variable  ${tender_data['description_en']}
	${mainProcurementCategory}  set variable  ${tender_data['mainProcurementCategory']}
	${NBUdiscountRate}  set variable  ${tender_data['NBUdiscountRate']}
	${fundingKind}  set variable  ${tender_data['fundingKind']}

	:FOR  ${field}  in
	...  tenderPeriod.endDate
	...  title
	...  description
	...  title_en
	...  description_en
	...  mainProcurementCategory
	...  NBUdiscountRate
	...  fundingKind
	\  run keyword  webclient.заповнити поле ${field}  ${${field}}

	# ЛОТИ
	${lot_index}  set variable  1
	:FOR  ${lot}  IN  @{tender_data['lots']}
	\  run keyword if  '${lot_index}' != '1'  run keywords
	\  ...  webclient.додати бланк  GRID_ITEMS_HIERARCHY  AND
	\  ...  Змінити номенклатуру на лот
	\  Заповнити поля лоту  ${lot}
	\  ${lot_id}  set variable  ${lot['id']}
	\  Заповнити поля для items по lot_id  ${lot_id}  @{tender_data['items']}
	\  ${lot_index}  evaluate  ${lot_index}+1


    # ЯКІСНІ ПОКАЗНИКИ
    ${is_features}  ${features}  run keyword and ignore error  set variable  ${tender_data['features']}
	run keyword if  '${is_features}' == 'PASS'  smarttender.додати якісні показники  ${features}

	# УМОВИ ОПЛАТИ
	${is_milestones}  ${milestones}  run keyword and ignore error  set variable  ${tender_data['milestones']}
	run keyword if  '${is_milestones}' == 'PASS'  smarttender.додати умови оплати  ${milestones}

    webclient.додати тендерну документацію
	webclient.header натиснути на елемент за назвою  Додати
    ${status}  ${ret}  run keyword and ignore error
	...  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  '${status}' == 'PASS'  run keyword and ignore error
	...  dialog box натиснути кнопку  Так
	dialog box заголовок повинен містити  Оголосити закупівлю?
	dialog box натиснути кнопку  Так
    webclient.screen заголовок повинен містити  Завантаження документації
    click element   ${screen_root_selector}//*[@alt="Close"]
    loading дочекатись закінчення загрузки сторінки
    # Тут опционально появляется вопрос о ЕЦП
    ${status}  ${ret}  run keyword and ignore error
    ...  dialog box заголовок повинен містити  Накласти ЕЦП/КЕП на тендер?
    run keyword if  '${status}' == 'PASS'  run keyword and ignore error
	...  dialog box натиснути кнопку  Ні
	webclient.пошук тендера по title  ${tender_data['title']}


Оголосити закупівлю open_framework multilot
	[Arguments]  ${tender_data}
	${plan_uaid}  Отримати номер плану з артифакту
    знайти план у webclient  ${plan_uaid}
   	webclient.header натиснути на елемент за назвою             Розрахунок
    dialog box вибрати строку зі списка  Сформировать закупку из планов  delta=2
	screen заголовок повинен містити     Сформувати однолотову чи багатолотову закупівлю?
	screen натиснути кнопку  мультилотову
	screen заголовок повинен містити     Додавання. Тендери
    webclient.видалити всі лоти та предмети
    webclient.додати бланк  GRID_ITEMS_HIERARCHY

	${tenderPeriod.endDate}  set variable  ${tender_data['tenderPeriod']['endDate']}
	${title}  set variable  ${tender_data['title']}
	${description}  set variable  ${tender_data['description']}
	${title_en}  set variable  ${tender_data['title_en']}
	${description_en}  set variable  ${tender_data['description_en']}
	${mainProcurementCategory}  set variable  ${tender_data['mainProcurementCategory']}
	${maxAwardsCount}  set variable  ${tender_data['maxAwardsCount']}
	${agreementDuration}  set variable  ${tender_data['agreementDuration']}

	:FOR  ${field}  in
	...  tenderPeriod.endDate
	...  title
	...  description
	...  title_en
	...  description_en
	...  mainProcurementCategory
	...  maxAwardsCount
	...  agreementDuration
	\  run keyword  webclient.заповнити поле ${field}  ${${field}}

	# ЛОТИ
	${lot_index}  set variable  1
	:FOR  ${lot}  IN  @{tender_data['lots']}
	\  run keyword if  '${lot_index}' != '1'  run keywords
	\  ...  webclient.додати бланк  GRID_ITEMS_HIERARCHY  AND
	\  ...  Змінити номенклатуру на лот
	\  Заповнити поля лоту  ${lot}
	\  ${lot_id}  set variable  ${lot['id']}
	\  Заповнити поля для items по lot_id  ${lot_id}  @{tender_data['items']}
	\  ${lot_index}  evaluate  ${lot_index}+1

    # ЯКІСНІ ПОКАЗНИКИ
    ${is_features}  ${features}  run keyword and ignore error  set variable  ${tender_data['features']}
	run keyword if  '${is_features}' == 'PASS'  smarttender.додати якісні показники  ${features}

    # УМОВИ ОПЛАТИ
	${is_milestones}  ${milestones}  run keyword and ignore error  set variable  ${tender_data['milestones']}
	run keyword if  '${is_milestones}' == 'PASS'  smarttender.додати умови оплати  ${milestones}

	webclient.додати тендерну документацію
	webclient.header натиснути на елемент за назвою  Додати
    ${status}  ${ret}  run keyword and ignore error
	...  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  '${status}' == 'PASS'  run keyword and ignore error
	...  dialog box натиснути кнопку  Так
	dialog box заголовок повинен містити  Оголосити закупівлю?
	dialog box натиснути кнопку  Так
    webclient.screen заголовок повинен містити  Завантаження документації
    click element   ${screen_root_selector}//*[@alt="Close"]
    loading дочекатись закінчення загрузки сторінки
    ${status}  ${ret}  run keyword and ignore error
    ...  dialog box заголовок повинен містити  Накласти ЕЦП/КЕП на тендер?
    run keyword if  '${status}' == 'PASS'  run keyword and ignore error
	...  dialog box натиснути кнопку  Ні
	webclient.пошук тендера по title  ${tender_data['title']}



вибрати донора
    [Arguments]  ${funders}
    :FOR  ${funder}  IN  @{funders}
	\  операція над чекбоксом  ${True}  //*[@data-name="FUNDERS_CB"]//input
	\  webclient.заповнити autocomplete field  //*[@data-name="FUNDERID"]//input  ${funder['identifier']['legalName']}  check=${False}


Заповнити поля для items по lot_id
	[Arguments]  ${lot_id}  @{items}
	:FOR  ${item}  IN  @{items}
	\  run keyword if  '${lot_id}' == '${item['relatedLot']}'  run keywords
	\  ...  webclient.додати бланк  GRID_ITEMS_HIERARCHY  AND
	\  ...  Заповнити поля предмету  ${item}


Заповнити поля лоту
    [Arguments]  ${lot}
    ${title}  set variable  ${lot['title']}
	${description}  set variable  ${lot['description']}
	${title_en_status}  ${title_en}              run keyword and ignore error  set variable  ${lot['title_en']}
	${description_en_status}  ${description_en}  run keyword and ignore error  set variable  ${lot['description_en']}
    ${value_status}  ${value.amount}    run keyword and ignore error  set variable  ${lot['value']['amount']}
	${value_status}  ${value.valueAddedTaxIncluded}    run keyword and ignore error  set variable  ${lot['value']['valueAddedTaxIncluded']}
	${minimalStep_status}  ${minimalStep.amount}  run keyword and ignore error  set variable  ${lot['minimalStep']['amount']}
	${minimalStepPercentage_status}  ${minimalStepPercentage}  run keyword and ignore error  set variable  ${lot['minimalStepPercentage']}
	${yearlyPaymentsPercentageRange_status}  ${yearlyPaymentsPercentageRange}  run keyword and ignore error  set variable  ${lot['yearlyPaymentsPercentageRange']}

    ${en_add}  set variable if
	...  'below' in '${mode}'                           ${False}
	...  'reporting' in '${mode}'                       ${False}
	...  'openua' in '${mode}'                          ${False}
	...  'negotiation' in '${mode}'                     ${False}
	...  "${tender_data['procurementMethodType']}" == "competitiveDialogueUA"  ${False}
	...                                     ${True}

	${field_list}  create list
	...  title
	...  description
	run keyword if  ('${title_en_status}' == 'PASS') and (${en_add} == ${True})
	...  append to list  ${field_list}  title_en
	run keyword if  ('${description_en_status}' == 'PASS') and (${en_add} == ${True})
	...  append to list  ${field_list}  description_en
	run keyword if  '${value_status}' == 'PASS'
	...  append to list  ${field_list}  value.valueAddedTaxIncluded  value.amount
	run keyword if  '${minimalStep_status}' == 'PASS'
	...  append to list  ${field_list}  minimalStep.amount
	run keyword if  '${minimalStepPercentage_status}' == 'PASS'
	...  append to list  ${field_list}  minimalStepPercentage
	run keyword if  '${yearlyPaymentsPercentageRange_status}' == 'PASS'
	...  append to list  ${field_list}  yearlyPaymentsPercentageRange

    :FOR  ${field}  in  @{field_list}
	\  run keyword  webclient.заповнити поле для lot ${field}  ${${field}}


Заповнити поля предмету
  	[Arguments]  ${item}
	${description}  set variable  ${item['description']}
	${description_en_status}  ${description_en}  run keyword and ignore error  set variable  ${item['description_en']}
	${quantity}  set variable  ${item['quantity']}
	${unit.name_status}  ${unit.name}  run keyword and ignore error  replace_unit_name_dict  ${item['unit']['name']}
	${classification.id}  set variable  ${item['classification']['id']}
	${additionalClassifications_status}  ${additionalClassifications.scheme}  run keyword and ignore error  set variable  ${item['additionalClassifications'][0]['scheme']}
	${additionalClassifications_status}  ${additionalClassifications.description}  run keyword and ignore error  set variable  ${item['additionalClassifications'][0]['description']}
	${deliveryAddress.postalCode}  set variable  ${item['deliveryAddress']['postalCode']}
	${deliveryAddress.streetAddress}  set variable  ${item['deliveryAddress']['streetAddress']}
	${deliveryAddress.locality}  set variable  ${item['deliveryAddress']['locality']}
	${deliveryDate.startDate_status}  ${deliveryDate.startDate}  run keyword and ignore error  set variable  ${item['deliveryDate']['startDate']}
	${deliveryDate.endDate_status}  ${deliveryDate.endDate}  run keyword and ignore error  set variable  ${item['deliveryDate']['endDate']}

	${field_list}  create list

	append to list  ${field_list}
	...  description

    ${en_add}  set variable if
	...  'below' in '${mode}'                           ${False}
	...  'reporting' in '${mode}'                       ${False}
	...  'openua' in '${mode}'                          ${False}
	...  'negotiation' in '${mode}'                     ${False}
	...  "${tender_data['procurementMethodType']}" == "competitiveDialogueUA"  ${False}
	...                                                 ${True}

	run keyword if  ("${description_en_status}" == "PASS") and (${en_add} == ${True})
	...  append to list  ${field_list}  description_en

	run keyword if  '${mode}' != 'open_esco'
	...  append to list  ${field_list}  quantity
	run keyword if  '${unit.name_status}' == 'PASS'
	...  append to list  ${field_list}  unit.name

	append to list  ${field_list}
	...  classification.id

	run keyword if  '${additionalClassifications_status}' == 'PASS'
	...  append to list  ${field_list}  additionalClassifications.scheme  additionalClassifications.description
	run keyword if  '${deliveryDate.startDate_status}' == 'PASS'
	...  append to list  ${field_list}  deliveryDate.startDate  deliveryDate.endDate

	append to list  ${field_list}
	...  deliveryAddress.postalCode
	...  deliveryAddress.streetAddress
	...  deliveryAddress.locality

	:FOR  ${field}  in  @{field_list}
	\  run keyword  webclient.заповнити поле для item ${field}  ${${field}}
	capture page screenshot


додати якісні показники
    [Arguments]  ${features}
    webclient.операція над чекбоксом  True  //*[@data-name="ISCRITERIA"]//input
    ${count_features}  set variable  1
	:FOR  ${feature}  IN  @{features}
	\  run keyword if  '${count_features}' == '1'  webclient.активувати вкладку  Якісні показники
	\  run keyword if  '${count_features}' == '1' and '${mode}' == 'open_esco'  видалити всі лоти та предмети(виправленний)  GRID_CRITERIA
	\  Заповнити якісні показники  ${feature}
	\  ${count_features}  evaluate  ${count_features} + 1


Заповнити якісні показники
    [Arguments]  ${feature}  ${relatedItem_id}=None
    ${title}        set variable  ${feature["title"]}
    ${description}  set variable  ${feature["description"]}
    ${featureOf_cdb}    set variable  ${feature["featureOf"]}
    ${relatedItem_status}  ${relatedItem}  run keyword and ignore error  set variable  ${feature["relatedItem"]}
    ${enums}  set variable  ${feature["enum"]}

    ${featureOf_dict}  create dictionary
    ...  lot=Лот
    ...  tenderer=Учасник тендеру
    ...  item=Номеклатура
    ${featureOf}    set variable  ${featureOf_dict["${featureOf_cdb}"]}

    ${field_list}  create list
  	...  title
  	...  description

  	webclient.додати бланк  GRID_CRITERIA
  	вибрати рівень прив'язки для feature  ${featureOf}
	run keyword if  '${relatedItem_status}' == 'PASS'
	...  вибрати предка для feature  ${featureOf_cdb}  ${relatedItem}

  	:FOR  ${field}  IN  @{field_list}
  	\  run keyword  заповнити поле для feature ${field}  ${${field}}

    :FOR  ${enum}  IN  @{enums}
    \  додати бланк  GRID_CRITERIONVALUES
    \  заповнити поле для feature enum title  ${enum['title']}
    \  заповнити поле для feature enum value  ${enum['value']}


вибрати предка для feature
    [Arguments]  ${featureOf_cdb}  ${relatedItem}
    оновити дані тендера з ЦБД
    ${relatedItem_name}  run keyword  отримати найменування предка для ${featureOf_cdb}  ${relatedItem}
    webclient.вибрати значення з випадаючого списку  //*[@data-name="CRITERIONBINDING"]  ${relatedItem_name}


отримати найменування предка для lot
    [Arguments]  ${relatedItem}
    :FOR  ${lot}  IN  @{tender_data['lots']}
    \  ${lot_id}    set variable  ${lot['id']}
    \  ${is_equal}  run keyword and return status  should be true  "${lot_id}" == "${relatedItem}"
    \  ${lot_title}  set variable if  ${is_equal}  ${lot['title']}
    \  exit for loop if  ${is_equal}
    [Return]  ${lot_title}


отримати найменування предка для item
    [Arguments]  ${relatedItem}
    :FOR  ${item}  IN  @{tender_data['items']}
    \  ${item_id}   set variable  ${item['id']}
    \  ${is_equal}  run keyword and return status  should be true  "${item_id}" == "${relatedItem}"
    \  ${item_description}  set variable if  ${is_equal}  ${item['description']}
    \  exit for loop if  ${is_equal}
    [Return]  ${item_description}


отримати дані тендеру з cdb по id
    [Arguments]  ${id}
	${data}  evaluate  requests.get("https://lb-api-staging.prozorro.gov.ua/api/2.4/tenders/${id}")   requests
	${data}  Set Variable  ${data.json()}
	${cdb_data}  Set Variable  ${data['data']}
	[Return]  ${cdb_data}


додати умови оплати fake
    [Arguments]  ${multilot}=False
    webclient.активувати вкладку  Умови оплати
	run keyword if  ${multilot}  Заповнити умови оплати multilot fake
	...  ELSE                    Заповнити умови оплати fake


Заповнити умови оплати multilot fake
    ${lots_amount}  Get Matching Xpath Count  ${lot_row}
  	:FOR  ${lot_number}  IN RANGE  1  ${lots_amount}+1
  	\  click element  xpath=(${lot_row})[${lot_number}]
  	\  loading дочекатись закінчення загрузки сторінки
  	\  Заповнити умови оплати fake


Заповнити умови оплати fake
	${code}  set variable            Аванс
	${title}  set variable           Виконання робіт
	${duration.type}  set variable   Робочий
	${duration.days}  evaluate       random.randint(2, 20)  random
	${percentage}  set variable      100

	${field_list}  create list
  	...  code
  	...  title
  	...  duration.type
  	...  duration.days
  	...  percentage

  	webclient.додати бланк  GRID_PAYMENT_TERMS
  	:FOR  ${field}  IN  @{field_list}
  	\  run keyword  заповнити поле для milestone ${field}  ${${field}}


додати умови оплати
    [Arguments]  ${milestones}
	${count_milestone}  set variable  1
	:FOR  ${milestone}  IN  @{milestones}
	\  run keyword if  '${count_milestone}' == '1'  webclient.активувати вкладку  Умови оплати
	\  Заповнити умови оплати  ${milestone}
	\  ${count_milestone}  evaluate  ${count_milestone} + 1


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

  	webclient.додати бланк  GRID_PAYMENT_TERMS
  	:FOR  ${field}  IN  @{field_list}
  	\  run keyword  заповнити поле для milestone ${field}  ${${field}}


Пошук тендера по ідентифікатору
	[Arguments]   ${username}  ${tender_uaid}  ${second_stage_data}=${Empty}
	[Documentation]   Знайти тендер з uaid рівним tender_uaid.
	${tender_detail_page_exist}  run keyword and return status  variable should exist  ${tender_detail_page}
	return from keyword if  ${tender_detail_page_exist} and "${second_stage_data}" == "${EMPTY}"
	smarttender.перейти до тестових торгів
	smarttender.сторінка_торгів ввести текст в поле пошуку  ${tender_uaid}
	smarttender.сторінка_торгів виконати пошук
	${status}  run keyword and return status  smarttender.сторінка_торгів перейти за першим результатом пошуку
	run keyword if  not ${status}  smarttender.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}  ${second_stage_data}
	${taken_tender_uaid}  smarttender.сторінка_детальної_інформації отримати tender_uaid
	should be equal as strings  ${taken_tender_uaid}  ${tender_uaid}
	set global variable  ${tender_uaid}


Пошук угоди по ідентифікатору
	[Arguments]  ${username}  ${agreement_uaid}
	${agreement_detail_page_exist}  run keyword and return status  variable should exist  ${agreement_detail_page}
	return from keyword if  ${agreement_detail_page_exist}
	smarttender.перейти до тестових рамок
	smarttender.сторінка_торгів ввести текст в поле пошуку  ${agreement_uaid}
	smarttender.сторінка_торгів виконати пошук
	smarttender.сторінка_рамок перейти за першим результатом пошуку
	set global variable  ${agreement_uaid}


Оновити сторінку з тендером
	[Arguments]   ${username}  ${tender_uaid}
    [Documentation]   Оновити сторінку з тендером для отримання потенційно оновлених даних.
    ${test_list}  create list
    ...  Можливість створення лоту із прив’язаним предметом закупівлі
    ...  Можливість внести зміни у тендер після запитання
    ...  Можливість внести зміни у лот після запитання
    ...  Відображення статусу першої пропозиції кваліфікації
    ...  Відображення статусу другої пропозиції кваліфікації
    run keyword if  "${TEST_NAME}" not in @{test_list}
	...  smarttender.Синхронізувати тендер
	...  ELSE  run keywords
	...  reload page        AND
	...  loading дочекатись закінчення загрузки сторінки


###############################################
###############################################
Отримати інформацію із угоди
	[Arguments]  ${username}  ${agreement_uaid}  ${field_name}
	reload page
	loading дочекатись закінчення загрузки сторінки
	${field_value}  run keyword  smarttender.сторінка_детальної_інформації_угоди отримати ${field_name}
	[Return]  ${field_value}


сторінка_детальної_інформації_угоди отримати changes[${agreement_index}].rationaleType
	no operation
	# как получить это значение в статусе "pending"?

сторінка_детальної_інформації_угоди отримати changes[${agreement_index}].rationale
	no operation
	# как получить это значение в статусе "pending"?

сторінка_детальної_інформації_угоди отримати changes[${agreement_index}].modifications[${modifications_index}].itemId
	no operation
	# как получить это значение в статусе "pending"?

сторінка_детальної_інформації_угоди отримати changes[${agreement_index}].modifications[${modifications_index}].addend
	no operation
	# как получить это значение в статусе "pending"?

сторінка_детальної_інформації_угоди отримати changes[${agreement_index}].status
	# changes в статусе cancelled отображаются только у организатора
	# У тест кейсов "Відображення статусу cancelled зміни itemPriceVariation" и "Відображення статусу cancelled зміни partyWithdrawal"
	# нет уникального тега для исключения, для yих сделан такой return
	return from keyword if  "Відображення статусу cancelled" in "${TEST_NAME}"  cancelled
	# Сверху всегда отображается последние changes
	${selector}  set variable  xpath=(//*[@data-qa="changes-block"])[1]//*[@data-qa="change-status-title"]
	${field_value_in_smart_format}  get text  ${selector}
	${field_value}  set variable if
		...  "${field_value_in_smart_format}" == "Непідтверджена зміна"  pending
		...  "${field_value_in_smart_format}" == "Скасована зміна"  cancelled
		...  "${field_value_in_smart_format}" == "Підтверджена зміна"  active
	[Return]  ${field_value}


сторінка_детальної_інформації_угоди отримати changes[${agreement_index}].modifications[${modifications_index}].factor
	no operation
	# как получить єто значение в статусе "pending"?



###############################################
###############################################
Отримати інформацію із тендера
    [Arguments]  ${username}  ${tender_uaid}  ${field_name}
    [Documentation]  Отримати значення поля field_name для тендера tender_uaid.
    comment  Перевіряємо чи в tender_uaid часом не прилетів ід плану, якщо так - тянемо інфу х плану і виходимо з кейворда
    ${plan_id_status}  set variable if  "UA-P" in "${tender_uaid}"  ${True}
    ${field_value}  run keyword if  ${plan_id_status}  smarttender.Отримати інформацію із плану  ${username}  ${tender_uaid}  ${field_name}
    return from keyword if  ${plan_id_status}  ${field_value}
    comment  Повертаємося на сторінку детальної інформації по тендеру якщо ми не на ній
    ${current_location}  get location
    run keyword if  "${tender_detail_page}" != "${current_location}"  smart go to  ${tender_detail_page}
    #####################################
    smarttender.сторінка_детальної_інформації активувати вкладку  Тендер
    ${field_name_splited}  set variable  ${field_name.split('[')[0]}
    ${field_value}  run keyword  smarttender.сторінка_детальної_інформації отримати ${field_name_splited}  ${field_name}
    log location
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


сторінка_детальної_інформації отримати title_en
    [Arguments]  ${field_name}=None
    [Documentation]  Отримати заголовок звіту про укладений договір англійською мовою
    debug
    log to console  Поля немає на сторінці
    [Return]  ${field_value}


сторінка_детальної_інформації отримати title_ru
    [Arguments]  ${field_name}=None
    [Documentation]  Отримати заголовок звіту про укладений договір російською мовою
    log to console  Поля немає на сторінці
    debug
    [Return]  ${field_value}


сторінка_детальної_інформації отримати description
    [Arguments]  ${field_name}=None
	${selector}  set variable  //*[@data-qa='description']
	${field_value}  get text  ${selector}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати description_en
    [Arguments]  ${field_name}=None
    [Documentation]  Отримати опису звіту про укладений договір англійською мовою
    debug
    log to console  Поля немає на сторінці
    [Return]  ${field_value}


сторінка_детальної_інформації отримати description_ru
    [Arguments]  ${field_name}=None
    [Documentation]  Отримати опису звіту про укладений договір російською мовою
    debug
    log to console  Поля немає на сторінці
    [Return]  ${field_value}


сторінка_детальної_інформації отримати status
    [Arguments]  ${field_name}=None
    comment  Повертаємося на сторінку детальної інформації по тендеру якщо ми не на ній
    ${current_location}  get location
    run keyword if  "${tender_detail_page}" != "${current_location}"  run keywords
    ...  go to  ${tender_detail_page}  AND  loading дочекатись закінчення загрузки сторінки
    ##################################################
    comment  Цей кейворд використовується квінтою при очікуванні статусу тендера. Потрібна перезагрузка сторінки для оновлення інформації.
    reload page
	loading дочекатись закінчення загрузки сторінки
	##################################################
	${selector}  set variable  //*[@data-qa='status']
	${field_value}  get text  ${selector}
	${field_value}  convert_status  ${field_value}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати documents
    [Arguments]  ${field_name}
    ${reg}  evaluate  re.search(r'.*\\[(?P<number>\\d)\\]\\.(?P<field>.*)', '${field_name}')  re
    ${number}  	evaluate  int(${reg.group('number')})
	${field}  	evaluate  '${reg.group('field')}'
	${selector}  set variable  (//*[@data-qa="file-name"]/ancestor::div[contains(@class,"filename")])[${number}+1]
	${field_value}  run keyword if
	...  '${field}' == 'title'  smarttender.документи_сторінка_детальної_інформації отримати ${field}  ${selector}
    [Return]  ${field_value}


сторінка_детальної_інформації отримати milestones
	[Arguments]  ${field_name}
	${field_value}  run keyword  сторінка_детальної_інформації отримати milestones ${field_name}
	[Return]  ${field_value}
###############################################
###############################################
сторінка_детальної_інформації отримати milestones milestones[${milestone_index}].code
    ${locator}  set variable  xpath=(//*[@data-qa='paymentTerms-block']//*[@class="delimeter ivu-row"])[${milestone_index}+1]/div[last()]
	${text}  get text  ${locator}
	${field_value_in_smart_format}  evaluate  re.search("(?P<code>.*): (?P<percentage>[0-9]+)%", "${text}").group("code")  re
	${field_value}  set variable if
		...  "${field_value_in_smart_format}" == "Аванс"  prepayment
		...  "${field_value_in_smart_format}" == "Пiсляоплата"  postpayment
		...  Error!
	[Return]  ${field_value}


сторінка_детальної_інформації отримати milestones milestones[${milestone_index}].percentage
    ${locator}  set variable  xpath=(//*[@data-qa='paymentTerms-block']//*[@class="delimeter ivu-row"])[${milestone_index}+1]/div[last()]
	${text}  get text  ${locator}
	${field_value}  evaluate  re.search("(?P<code>.*): (?P<percentage>[0-9]+)%", "${text}").group("percentage")  re
	${field_value}  evaluate  int(${field_value})
	[Return]  ${field_value}


сторінка_детальної_інформації отримати milestones milestones[${milestone_index}].title
	${title_dict}  		create dictionary
	...  Виконання робіт=executionOfWorks
	...  Поставка товару=deliveryOfGoods
	...  Надання послуг=submittingServices
	...  Підписання договору=signingTheContract
	...  Дата подання заявки=submissionDateOfApplications
	...  Дата виставлення рахунку=dateOfInvoicing
	...  Дата закінчення звітного періоду=endDateOfTheReportingPeriod
	...  Інша подія=anotherEvent
    ${locator}  set variable  xpath=(//*[@data-qa='paymentTerms-block']//*[@class="delimeter ivu-row"])[${milestone_index}+1]/div/div
	${text}  get text  ${locator}
	${field_value}  get from dictionary  ${title_dict}  ${text}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати milestones milestones[${milestone_index}].duration.days
    ${locator}  set variable  xpath=(//*[@data-qa='paymentTerms-block']//*[@class="delimeter ivu-row"])[${milestone_index}+1]/div[@class="ivu-col ivu-col-span-sm-6"]
	${text}  get text  ${locator}
	${field_value}  evaluate  re.search("(?P<days>[0-9]+) (?P<type>.+)", "${text}").group("days")  re
	${field_value}  evaluate  int(${field_value})
	[Return]  ${field_value}


сторінка_детальної_інформації отримати milestones milestones[${milestone_index}].duration.type
    ${locator}  set variable  xpath=(//*[@data-qa='paymentTerms-block']//*[@class="delimeter ivu-row"])[${milestone_index}+1]/div[@class="ivu-col ivu-col-span-sm-6"]
	${text}  get text  ${locator}
	${field_value_in_smart_format}  evaluate  re.search("(?P<days>[0-9]+) (?P<type>.+)", "${text}").group("type")  re
	${field_value}  set variable if
		...  "${field_value_in_smart_format}" == "календарних днів"  calendar
		...  "${field_value_in_smart_format}" == "робочих днів"  working
		...  "${field_value_in_smart_format}" == "банківських днів"  banking
		...  Error!
	[Return]  ${field_value}


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


сторінка_детальної_інформації отримати procuringEntity.address.countryName
    [Arguments]  ${field_name}=None
    [Documentation]  Отримати назву країни замовника звіту про укладений договір
    ${selector}  set variable  //*[@data-qa="address"]//*[@data-qa="value"]
    ${field_value}  get text  ${selector}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати procuringEntity.address.locality
    [Arguments]  ${field_name}=None
    [Documentation]  Отримати назву населеного пункту замовника звіту про укладений договір
    log to console  Поля немає на сторінці (non-critical)
	[Return]  ${empty}


сторінка_детальної_інформації отримати procuringEntity.address.postalCode
    [Arguments]  ${field_name}=None
    [Documentation]  Отримати поштовий код замовника звіту про укладений договір
    log to console  Поля немає на сторінці (non-critical)
	[Return]  ${empty}


сторінка_детальної_інформації отримати procuringEntity.address.region
    [Arguments]  ${field_name}=None
    [Documentation]  Отримати область замовника звіту про укладений договір
    log to console  Поля немає на сторінці (non-critical)
	[Return]  ${empty}


сторінка_детальної_інформації отримати procuringEntity.address.streetAddress
    [Arguments]  ${field_name}=None
    [Documentation]  Отримати назву вулиці замовника звіту про укладений договір
    log to console  Поля немає на сторінці (non-critical)
	[Return]  ${empty}


сторінка_детальної_інформації отримати procuringEntity.contactPoint.name
    [Arguments]  ${field_name}=None
    ${selector}  set variable  //*[@data-qa="contactPerson-block"]//*[@data-qa="name"]//*[@data-qa="value"]
    ${field_value}  get text  ${selector}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати procuringEntity.contactPoint.telephone
    [Arguments]  ${field_name}=None
    ${selector}  set variable  //*[@data-qa="contactPerson-block"]//*[@data-qa="phone"]//a
    ${field_value}  get text  ${selector}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати procuringEntity.contactPoint.url
    [Arguments]  ${field_name}=None
    ${selector}  set variable  //*[@data-qa="url"]//a
    ${field_value}  get text  ${selector}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати procuringEntity.identifier.legalName
    [Arguments]  ${field_name}=None
    ${selector}  set variable  //*[@data-qa="organizer-block"]//*[@data-qa="name"]//*[@data-qa="value"]
    ${field_value}  get text  ${selector}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати procuringEntity.identifier.scheme
    [Arguments]  ${field_name}=None
    [Documentation]  Отримати схему ідентифікації замовника звіту про укладений договір
    ${selector}  set variable  xpath=//*[@data-qa="usreou"]//*[@data-qa="key"]
	${field_value_in_smart_format}  get text  ${selector}
	${field_value}  set variable if  "${field_value_in_smart_format}" == "Код ЄДРПОУ"  UA-EDR  ERROR!
	[Return]  ${field_value}


сторінка_детальної_інформації отримати procuringEntity.identifier.id
    [Arguments]  ${field_name}=None
    ${selector}  set variable  //*[@data-qa="organizer-block"]//*[@data-qa="usreou"]//*[@data-qa="value"]
    ${field_value}  get text  ${selector}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати procurementMethodType
    [Arguments]  ${field_name}
	${selector}  set variable  //*[@data-qa="procedure-type"]//div[contains(@class, "second")]
	${field_value}  get text  ${selector}
	${field value}  convert_procurementMethodType  ${field value}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати enquiryPeriod.startDate
    [Arguments]  ${field_name}=None
	${selector}  set variable  xpath=//*[@data-qa="enquiry-period"]//*[@data-qa="date-start"]
	${field_value}  get text  ${selector}
	${field_value}  convert date  ${field_value}  date_format=%d.%m.%Y %H:%M  result_format=%Y-%m-%dT%H:%M:%S${time_zone}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати enquiryPeriod.endDate
    [Arguments]  ${field_name}=None
	${selector}  set variable  xpath=//*[@data-qa="enquiry-period"]//*[@data-qa="date-end"]
	${field_value}  get text  ${selector}
	${field_value}  convert date  ${field_value}  date_format=%d.%m.%Y %H:%M  result_format=%Y-%m-%dT%H:%M:%S${time_zone}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати tenderPeriod.startDate
    [Arguments]  ${field_name}=None
	${selector}  set variable  xpath=//*[@data-qa="tendering-period"]//*[@data-qa="date-start"]
	${field_value}  get text  ${selector}
	${field_value}  convert date  ${field_value}  date_format=%d.%m.%Y %H:%M  result_format=%Y-%m-%dT%H:%M:%S${time_zone}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати tenderPeriod.endDate
    [Arguments]  ${field_name}=None
	${selector}  set variable  xpath=//*[@data-qa="tendering-period"]//*[@data-qa="date-end"]
	${field_value}  get text  ${selector}
	${field_value}  convert date  ${field_value}  date_format=%d.%m.%Y %H:%M  result_format=%Y-%m-%dT%H:%M:%S${time_zone}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати minimalStep.amount
    [Arguments]  ${field_name}=None
    comment  Бюджет для второго єтапа рамок появляется не сразу, выводится текст "Інформація поки що відсутня"
    ...  когда появляется никто не знает.
    ${field_value}  wait until keyword succeeds  10m  1s
    ...  сторінка_детальної_інформації отримати minimalStep.amount try  ${field_name}
    [Return]  ${field_value}


сторінка_детальної_інформації отримати minimalStep.amount try
    [Arguments]  ${field_name}
    reload page
	${selector}  set variable  xpath=//*[@data-qa="budget-min-step"]//span[4]
	loading дочекатися відображення елемента на сторінці  ${selector}
	${field_value}  get text  ${selector}
	${field_value}  convert_page_values  ${field_name}  ${field_value}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати minimalStep.currency
    [Arguments]  ${field_name}=None
	${selector}  set variable  xpath=//*[@data-qa="budget-min-step"]//span[5]
	${field_value}  get text  ${selector}
	${field_value}  convert_page_values  ${field_name}  ${field_value}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати qualificationPeriod.endDate
    [Arguments]  ${field_name}=None
    smarttender.Синхронізувати тендер
	${selector}  set variable  xpath=//*[@data-qa="prequalification"]//*[@data-qa="date-end"]
	loading дочекатися відображення елемента на сторінці  ${selector}
	${field_value}  get text  ${selector}
	${field_value}  convert date  ${field_value}  date_format=%d.%m.%Y %H:%M  result_format=%Y-%m-%dT%H:%M:%S${time_zone}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати auctionPeriod.endDate
    [Arguments]  ${field_name}=None
    smarttender.Синхронізувати тендер
	${selector}  set variable  xpath=//*[@data-qa="auction-period"]//*[@data-qa="date-end"]
	${field_value}  get text  ${selector}
	${field_value}  convert date  ${field_value}  date_format=%d.%m.%Y %H:%M  result_format=%Y-%m-%dT%H:%M:%S${time_zone}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати causeDescription
    [Arguments]  ${field_name}=None
	${selector}  set variable  xpath=//*[@data-qa="negotiation-cause-description"]//*[@data-qa="value"]
	${field_value}  get text  ${selector}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати cause
    [Arguments]  ${field_name}=None
	${selector}  set variable  xpath=//*[@data-qa="negotiation-cause"]//*[@data-qa="value"]
	${field_value_in_smart_format}  get text  ${selector}
	${field_value}  convert_negotiation_cause_from_smart_format  ${field_value_in_smart_format}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати funders
    [Arguments]  ${field_name}
	${field_value}  run keyword  сторінка_детальної_інформації отримати funders ${field_name}
    [Return]  ${field_value}


сторінка_детальної_інформації отримати funders funders[${funder_index}].name
    ${translation_funder_dict}  create dictionary
    ...  Міжнародний банк реконструкції та розвитку (МБРР)=Світовий Банк
    ...  Глобальний Фонд для боротьби зі СНІДом, туберкульозом і малярією=Глобальний фонд
	${funder_block_locator}  set variable  (//*[@data-qa="donor"])[${funder_index}+1]
	${locator}  set variable  xpath=${funder_block_locator}//*[contains(@class, "ivu-poptip-rel")]
	${field_value}  get text  ${locator}
	${ret}  run keyword if  "${ROLE}" != "tender_owner"
	...  get from dictionary  ${translation_funder_dict}  ${field_value}  ELSE
	...  set variable  ${field_value}
	[Return]  ${ret}


сторінка_детальної_інформації отримати funders funders[${funder_index}].address.countryName
    ${translation_funder_dict}  create dictionary
    ...  США=USA
    ...  Швейцарія=Switzerland
	${postal_code}  ${country_name}  ${region}  ${locality}  ${street_address}  _отримати дані адреси донора
	${ret}  get from dictionary  ${translation_funder_dict}  ${country_name}
	[Return]  ${ret}


сторінка_детальної_інформації отримати funders funders[${funder_index}].address.locality
    ${translation_funder_dict}  create dictionary
    ...  м. Женева=Geneva
    ...  Вашингтон=Washington
	${postal_code}  ${country_name}  ${region}  ${locality}  ${street_address}  _отримати дані адреси донора
	${ret}  get from dictionary  ${translation_funder_dict}  ${locality}
	[Return]  ${ret}



сторінка_детальної_інформації отримати funders funders[${funder_index}].address.postalCode
	${postal_code}  ${country_name}  ${region}  ${locality}  ${street_address}  _отримати дані адреси донора
	[Return]  ${postal_code}


сторінка_детальної_інформації отримати funders funders[${funder_index}].address.region
    ${postal_code}  ${country_name}  ${region}  ${locality}  ${street_address}  _отримати дані адреси донора
	[Return]  ${region}


сторінка_детальної_інформації отримати funders funders[${funder_index}].address.streetAddress
    ${postal_code}  ${country_name}  ${region}  ${locality}  ${street_address}  _отримати дані адреси донора
	[Return]  ${streetAddress}


сторінка_детальної_інформації отримати funders funders[${funder_index}].contactPoint.url
	${funder_block_locator}  set variable  (//*[@data-qa="donor"])[${funder_index}+1]
	${locator}  set variable  xpath=${funder_block_locator}//*[@class="ivu-poptip-body-content"]//b[text()="Веб-сайт:"]/following-sibling::*
	${field_value}  get element attribute  ${locator}@innerText
	[Return]  ${field_value}


сторінка_детальної_інформації отримати funders funders[${funder_index}].identifier.id
	${funder_block_locator}  set variable  (//*[@data-qa="donor"])[${funder_index}+1]
	${locator}  set variable  xpath=${funder_block_locator}//*[@class="ivu-poptip-body-content"]//b[text()="Код ЄДРПОУ:"]/following-sibling::*
	${field_value}  get element attribute  ${locator}@innerText
	[Return]  ${field_value}


сторінка_детальної_інформації отримати funders funders[${funder_index}].identifier.scheme
	${funder_block_locator}  set variable  (//*[@data-qa="donor"])[${funder_index}+1]
	${locator}  set variable  xpath=${funder_block_locator}//*[@class="ivu-poptip-body-content"]//b[text()="Код ЄДРПОУ:"]
	${field_value_in_smart_format}  get element attribute  ${locator}@innerText
	${field_value}  set variable if  "${field_value_in_smart_format}" == "Код ЄДРПОУ:"  XM-DAC  ERROR!
	[Return]  ${field_value}


сторінка_детальної_інформації отримати funders funders[${funder_index}].identifier.legalName
	${funder_block_locator}  set variable  (//*[@data-qa="donor"])[${funder_index}+1]
	${locator}  set variable  xpath=${funder_block_locator}//*[contains(@class, "ivu-poptip-rel")]
	${field_value}  get text  ${locator}
	[Return]  ${field_value}


_отримати дані адреси донора
    ${funder_block_locator}  set variable  (//*[@data-qa="donor"])[0+1]
	${locator}  set variable  xpath=${funder_block_locator}//*[@class="ivu-poptip-body-content"]//b[text()="Адреса:"]/following-sibling::*
	${field_value}  get element attribute  ${locator}@innerText
	${postal_code}  ${country_name}  ${region}  ${locality}  ${street_address}  split_funder_adress  ${field_value}
	[Return]  ${postal_code}  ${country_name}  ${region}  ${locality}  ${street_address}


сторінка_детальної_інформації отримати auctionPeriod.startDate
    [Arguments]  ${field_name}=None
	${selector}  set variable  xpath=//*[@data-qa="auction-start"]//*[@data-qa="value"]
	${field_value}  get text  ${selector}
	${field_value}  convert date  ${field_value}  date_format=%d.%m.%Y %H:%M  result_format=%Y-%m-%dT%H:%M:%S${time_zone}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати complaintPeriod.startDate
    [Arguments]  ${field_name}=None
	${selector}  set variable  xpath=//*[@data-qa="period"]/*[contains(@class,"period")]
	${status}  run keyword and return status  element should be visible  ${selector}
	run keyword if  ${status} == ${False}  smarttender.сторінка_детальної_інформації активувати вкладку  Вимоги/скарги на умови закупівлі
	${text}  get text  ${selector}
	${reg}  evaluate  re.search(r"(?<= з )(?P<from>.*)(?= по)\\sпо\\s(?P<till>.*)", "${text}")  re
	${date}  evaluate  '${reg.group('from')}'
	${field_value}  convert date  ${date}  date_format=%d.%m.%Y %H:%M  result_format=%Y-%m-%dT%H:%M:%S${time_zone}
	reload page
	loading дочекатись закінчення загрузки сторінки
	[Return]  ${field_value}


сторінка_детальної_інформації отримати complaintPeriod.endDate
    [Arguments]  ${field_name}=None
	${selector}  set variable  xpath=//*[@data-qa="period"]/*[contains(@class,"period")]
	${status}  run keyword and return status  element should be visible  ${selector}
	run keyword if  ${status} == ${False}  smarttender.сторінка_детальної_інформації активувати вкладку  Вимоги/скарги на умови закупівлі
	${text}  get text  ${selector}
	${reg}  evaluate  re.search(r"(?<= з )(?P<from>.*)(?= по)\\sпо\\s(?P<till>.*)", "${text}")  re
#	${reg}  evaluate  re.search(r"(?<= з )(?P<from>.*)(?= по)\\sпо\\s(?P<till>.*)(?=\\s\\()", "${text}")  re
	${date}  evaluate  '${reg.group('till')}'
	${field_value}  convert date  ${date}  date_format=%d.%m.%Y %H:%M  result_format=%Y-%m-%dT%H:%M:%S${time_zone}
	reload page
	loading дочекатись закінчення загрузки сторінки
	[Return]  ${field_value}

сторінка_детальної_інформації отримати fundingKind
    [Arguments]  ${field_name}=None
	${selector}  set variable  xpath=//*[@data-qa="title" and contains(., "Джерело фінансування")]//*[@data-qa="value"]
	${field_value_in_smart_format}  get text  ${selector}
    ${field_value}  set variable if
        ...  "${field_value_in_smart_format}" == "Співфінансування з бюджетних коштів"  budget
        ...  "${field_value_in_smart_format}" == "Фінансування виключно за рахунок Учасника"  other
        ...  Error!
	[Return]  ${field_value}


сторінка_детальної_інформації отримати NBUdiscountRate
    [Arguments]  ${field_name}=None
	${selector}  set variable  xpath=//*[@data-qa="nbu-discount-rate"]//*[@data-qa="value"]
	${value_in_smart_format}  get text  ${selector}
    ${field_value}  evaluate  float("${value_in_smart_format}".strip("%").replace(",", ".")) / 100
	[Return]  ${field_value}


сторінка_детальної_інформації отримати yearlyPaymentsPercentageRange
    [Arguments]  ${field_name}=None
	${selector}  set variable  xpath=//*[@data-qa="cost-reduction-percent"]//*[@data-qa="value"]
	${field_value_in_smart_format}  get text  ${selector}
    ${field_value}  evaluate  float(${field_value_in_smart_format.split(" - ")[-1].replace("%", "").replace(",", ".")}) / 100
	[Return]  ${field_value}


сторінка_детальної_інформації отримати minimalStepPercentage
	[Arguments]  ${field_name}=None
	${selector}  set variable  xpath=//*[@data-qa="budget-min-step"]//span
	${field_value_in_smart_format}  get text  ${selector}
    ${field_value}  evaluate  float(${field_value_in_smart_format}) / 100
    ${field_value}  evaluate  '%.3f' % ${field_value}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати items
	[Arguments]  ${field_name}
	${reg}  evaluate  re.search(r'.*\\[(?P<number>\\d)\\]\\.(?P<field>.*)', '${field_name}')  re
	${number}  	evaluate  '${reg.group('number')}'
	${field}  	evaluate  '${reg.group('field')}'
    перейти до сторінки детальної інформаціїї за необхідністю
    log to console  отримати items
	run keyword and ignore error  smarttender._перейти до лоту якщо це потрібно
    ${item_block}   set variable  (//*[@data-qa="nomenclature-title"]/ancestor::div[@class="ivu-row"][1])[${number}+1]
	${field_value}  run keyword  smarttender.предмети_сторінка_детальної_інформації отримати ${field}  ${item_block}
    [Return]  ${field_value}


_перейти до лоту якщо це потрібно
    ${relatedItem}  set variable  ${tender_data['items'][${number}]['relatedLot']}
    ${lot_title}  smarttender.отримати найменування предка для lot  ${relatedItem}
    smarttender.перейти до лоту за необхідністю  lot_id=${lot_title}


сторінка_детальної_інформації отримати lots
	[Arguments]  ${field_name}
	${reg}  evaluate  re.search(r'.*\\[(?P<number>\\d)\\]\\.(?P<field>.*)', '${field_name}')  re
	${number}  	evaluate  '${reg.group('number')}'
	${field}  	evaluate  '${reg.group('field')}'
    перейти до сторінки детальної інформаціїї за необхідністю
    перейти до лоту за необхідністю  index=${number}+1
    ${field_value}  run keyword  smarttender.сторінка_детальної_інформації отримати ${field}
    ${converted_field_value}  convert_page_values  ${field}  ${field_value}
    [Return]  ${converted_field_value}


сторінка_детальної_інформації отримати features
	[Arguments]  ${field_name}
	${reg}  evaluate  re.search(r'.*\\[(?P<number>\\d)\\]\\.(?P<field>.*)', '${field_name}')  re
	${number}  	evaluate  '${reg.group('number')}'
	${field}  	evaluate  '${reg.group('field')}'
	перейти до сторінки детальної інформаціїї за необхідністю
    ${feature_block}  set variable  (//*[contains(@data-qa,"feature-list")])[${number}+1]
	smarttender.розгорнути всі експандери
    ${feature_field_name}  run keyword  smarttender.нецінові_сторінка_детальної отримати ${field}  ${feature_block}
    [Return]  ${feature_field_name}


Внести зміни в тендер
    [Arguments]  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}
    [Documentation]  Змінити значення поля fieldname на fieldvalue для тендера tender_uaid.
	знайти тендер у webclient  ${tender_uaid}
	header натиснути на елемент за назвою  Змінити
	run keyword and ignore error  header натиснути на елемент за назвою  Коригувати
	run keyword  webclient.заповнити поле ${fieldname}  ${fieldvalue}
	header натиснути на елемент за назвою  Зберегти
    ${is_visible}  run keyword and return status  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  ${is_visible}  dialog box натиснути кнопку  Так
	run keyword if  'below' not in '${mode}'  run keywords
    ...  dialog box заголовок повинен містити  Накласти ЕЦП/КЕП на тендер?  AND
	...  dialog box натиснути кнопку  Ні

	
Додати предмет закупівлі
    [Arguments]  ${username}  ${tender_uaid}  ${item}
    [Documentation]  Додати дані про предмет item до тендера tender_uaid.
	log to console  Додати предмет закупівлі
	debug


Отримати інформацію із предмету
    [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${field_name}
    [Documentation]  Отримати значення поля field_name з предмету з item_id в описі для тендера tender_uaid.
    перейти до сторінки детальної інформаціїї за необхідністю
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
	${item_field_value}  convert date  ${item_field_value}  date_format=%d.%m.%Y  result_format=%Y-%m-%dT%H:%M:%S${time_zone}
	[Return]  ${item_field_value}


предмети_сторінка_детальної_інформації отримати deliveryDate.endDate
    [Arguments]  ${item_block}
	${selector}  set variable  xpath=${item_block}//*[@data-qa="date-end"]
	${item_field_value}  get text  ${selector}
	${item_field_value}  convert date  ${item_field_value}  date_format=%d.%m.%Y  result_format=%Y-%m-%dT%H:%M:%S${time_zone}
	[Return]  ${item_field_value}


предмети_сторінка_детальної_інформації отримати deliveryLocation.latitude
    [Arguments]  ${item_block}
	${selector}  set variable  xpath=${item_block}//a[@data-qa="nomenclature-maplink"]
	${item_field_value}  get element attribute  ${selector}@href
	${reg}  evaluate  re.search(u'(?P<lat>\\d+.\\d+),(?P<lon>\\d+.\\d+)', u"""${item_field_value}""")  re
	${lat}	evaluate  float(${reg.group('lat')})
	[Return]  ${lat}


предмети_сторінка_детальної_інформації отримати deliveryLocation.longitude
    [Arguments]  ${item_block}
    ${selector}  set variable  xpath=${item_block}//a[@data-qa="nomenclature-maplink"]
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


предмети_сторінка_детальної_інформації отримати deliveryAddress.countryName_ru
    [Arguments]  ${item_block}
    debug
    log to console  Поля немає на сторінці
    ${item_field_value}  set variable  empty
    [Return]  ${item_field_value}


предмети_сторінка_детальної_інформації отримати deliveryAddress.countryName_en
    [Arguments]  ${item_block}
    debug
    log to console  Поля немає на сторінці
    ${item_field_value}  set variable  empty
    [Return]  ${item_field_value}


предмети_сторінка_детальної_інформації отримати deliveryAddress.postalCode
    [Arguments]  ${item_block}
    ${item_field_value}  smarttender.get_item_deliveryAddress_value  ${item_block}  postalCode
	[Return]  ${item_field_value}


предмети_сторінка_детальної_інформації отримати deliveryAddress.region
    [Arguments]  ${item_block}
	${item_field_value}  smarttender.get_item_deliveryAddress_value  ${item_block}  region
	${item_field_value}  set variable  ${item_field_value.replace(u"обл.", u"область")}
	[Return]  ${item_field_value}


предмети_сторінка_детальної_інформації отримати deliveryAddress.locality
    [Arguments]  ${item_block}
	${item_field_value}  smarttender.get_item_deliveryAddress_value  ${item_block}  locality
	${item_field_value}  set variable if
		...  "Днепро" == "${item_field_value}"  Дніпро
		...  "с." in "${item_field_value}"  ${item_field_value.replace(u"с. ", "")}
		...  "смт." in "${item_field_value}"  ${item_field_value.replace(u"смт. ", "")}
		...  ${item_field_value}
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
    ${reg}  evaluate  re.search(u'(?P<postalCode>.+),${space*2}(?P<countryName>.+),${space*2}(?P<region>.+),${space*2}(?P<locality>.+),${space*2}(?P<streetAddress>.+)', u"""${item_field_value}""")  re
	${group_value}  set variable  ${reg.group('${group}')}
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


нецінові_сторінка_детальної отримати title
    [Arguments]  ${feature_block}
	${selector}  set variable  xpath=${feature_block}//*[@class="expander-title"]
	${feature_field_value}  get text  ${selector}
	[Return]  ${feature_field_value}


нецінові_сторінка_детальної отримати description
    [Arguments]  ${feature_block}
	${selector}  set variable  xpath=${feature_block}//*[@class="feature-description"]
	${feature_field_value}  get text  ${selector}
	[Return]  ${feature_field_value}


нецінові_сторінка_детальної отримати featureOf
    [Arguments]  ${feature_block}
    ${feature_field_value_in_smart_format}  get element attribute  ${feature_block}@data-qa
	${feature_field_value}  set variable if
		...  "${feature_field_value_in_smart_format}" == "tender-feature-list"  tenderer
		...  "${feature_field_value_in_smart_format}" == "lot-feature-list"  lot
		...  "${feature_field_value_in_smart_format}" == "nomenclature-feature-list"  item
	[Return]  ${feature_field_value}


Видалити предмет закупівлі
    [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${lot_id}=${Empty}
    [Documentation]  Видалити з тендера tender_uaid предмет з item_id в описі (предмет може бути прив'язаним до лоту з lot_id в описі, якщо lot_id != Empty).
	знайти тендер у webclient  ${tender_uaid}
	header натиснути на елемент за назвою  Змінити
	header натиснути на елемент за назвою  Коригувати
	# ПРЕДМЕТИ
	видалити item по id  ${item_id}
	#  Зберегти
    webclient.header натиснути на елемент за назвою  Зберегти
	${is_visible}  run keyword and return status  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  ${is_visible}  dialog box натиснути кнопку  Так
	run keyword if  'below' not in '${mode}'  run keywords
    ...  dialog box заголовок повинен містити  Накласти ЕЦП/КЕП на тендер?  AND
	...  dialog box натиснути кнопку  Ні


Створити лот
    [Arguments]  ${username}  ${tender_uaid}  ${lot}
    [Documentation]  Додати лот lot до тендера tender_uaid.   
	log to console  Створити лот
	debug
	
	
Створити лот із предметом закупівлі
    [Arguments]  ${username}  ${tender_uaid}  ${lot}  ${item}
    [Documentation]  Додати лот lot з предметом item до тендера tender_uaid.
	знайти тендер у webclient  ${tender_uaid}
	header натиснути на елемент за назвою  Змінити
	header натиснути на елемент за назвою  Коригувати
	# ЛОТИ
	webclient.додати бланк  GRID_ITEMS_HIERARCHY
	Змінити номенклатуру на лот
	Заповнити поля лоту  ${lot['data']}

	# ПРЕДМЕТИ
	webclient.додати бланк  GRID_ITEMS_HIERARCHY
	Заповнити поля предмету  ${item}
    #  Зберегти
    webclient.header натиснути на елемент за назвою  Зберегти
	${is_visible}  run keyword and return status  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  ${is_visible}  dialog box натиснути кнопку  Так
	run keyword if  'below' not in '${mode}'  run keywords
    ...  wait until keyword succeeds  20  1  dialog box заголовок повинен містити  Накласти ЕЦП/КЕП на тендер?  AND
	...  dialog box натиснути кнопку  Ні

	
Отримати інформацію із лоту
    [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${field_name}
    [Documentation]  Отримати значення поля field_name з лоту з lot_id в описі для тендера tender_uaid.
    перейти до сторінки детальної інформаціїї за необхідністю
    ${is_multilot}  run keyword and return status  Page Should Contain Element  //*[@data-qa="lot-list-block"]
    ${field_value}  run keyword if  ${is_multilot}  run keywords
    ...  перейти до лоту за необхідністю  lot_id=${lot_id}          AND
    ...  Отримати інформацію із лоту multilot  ${field_name}
    ...  ELSE
    ...  Отримати інформацію із лоту single  ${field_name}
    [Return]  ${field_value}



Отримати інформацію із лоту single
    [Arguments]  ${field_name}
    ${field_selector}      set variable if
    ...  '${field_name}' == 'description'                           //*[@data-qa="lot-description"]
    ...  '${field_name}' == 'title'                                 //*[@data-qa="lot-title"]
    ...  '${field_name}' == 'value.amount'                          //*[@data-qa="budget-amount"]
    ...  '${field_name}' == 'value.currency'                        //*[@data-qa="budget-currency"]
    ...  '${field_name}' == 'value.valueAddedTaxIncluded'           //*[@data-qa="budget-vat-title"]
    ...  '${field_name}' == 'minimalStep.amount'                    (//*[@data-qa="budget-min-step"]//span)[4]
    ...  '${field_name}' == 'minimalStep.currency'                  (//*[@data-qa="budget-min-step"]//span)[last()]
    ...  '${field_name}' == 'minimalStep.valueAddedTaxIncluded'     //*[@data-qa="budget-vat-title"]
    ${field_value}  get text  xpath=${field_selector}
    ${converted_field_value}  convert_page_values  ${field_name}  ${field_value}
    [Return]  ${converted_field_value}


Отримати інформацію із лоту multilot
    [Arguments]  ${field_name}
    ${field_value}  run keyword  smarttender.сторінка_детальної_інформації отримати lots  ${field_name}
    ${converted_field_value}  convert_page_values  ${field_name}  ${field_value}
    [Return]  ${converted_field_value}


Змінити лот
    [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${fieldname}  ${fieldvalue}
    [Documentation]  Змінити значення поля fieldname лоту з lot_id в описі для тендера tender_uaid на fieldvalue
	знайти тендер у webclient  ${tender_uaid}
	header натиснути на елемент за назвою  Змінити
	header натиснути на елемент за назвою  Коригувати
	#  Стати на комірку з потрібним лотом
	${lot_row_locator}  set variable  xpath=//*[@data-name="GRID_ITEMS_HIERARCHY"]//td[contains(text(),"${lot_id}")]/ancestor::tr[1]
	click element  ${lot_row_locator}
	wait until page contains element  ${lot_row_locator}[contains(@class,"rowselected")]  5
	#  Змінити поле лоту
	#  Костиль. Чомусь після вводу value.amount, поле minimalStep очищається,
	#  тому зберігаємо значення поля minimalStep для повторного вводу
	${minimalStep_locator}  set variable  //*[@data-name="LOT_MINSTEP"]//input
	${minimalStep}  get element attribute  ${minimalStep_locator}@value
	#####################################################################
    run keyword  webclient.заповнити поле для lot ${fieldname}  ${fieldvalue}
    #  Повторно вводимо minimalStep якщо ${fieldname} == value.amount
    run keyword if  "${fieldname}" == "value.amount"
    ...  run keyword  webclient.заповнити поле для lot minimalStep.amount  ${minimalStep}
    #  Зберегти
    webclient.header натиснути на елемент за назвою  Зберегти
	${is_visible}  run keyword and return status  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  ${is_visible}  dialog box натиснути кнопку  Так
	run keyword if  'below' not in '${mode}'  run keywords
    ...  wait until keyword succeeds  10  1  dialog box заголовок повинен містити  Накласти ЕЦП/КЕП на тендер?  AND
	...  dialog box натиснути кнопку  Ні

	
Додати предмет закупівлі в лот
    [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${item}
    [Documentation]  Додати предмет item в лот з lot_id в описі для тендера tender_uaid.   
	log to console  Додати предмет закупівлі в лот
	знайти тендер у webclient  ${tender_uaid}
	header натиснути на елемент за назвою  Змінити
	header натиснути на елемент за назвою  Коригувати
	#  Стати на комірку з потрібним лотом
	${lot_row_locator}  set variable  xpath=//*[@data-name="GRID_ITEMS_HIERARCHY"]//td[contains(text(),"${lot_id}")]/ancestor::tr[1]
	click element  ${lot_row_locator}
	wait until page contains element  ${lot_row_locator}[contains(@class,"rowselected")]  5
	# ПРЕДМЕТИ
	webclient.додати бланк  GRID_ITEMS_HIERARCHY
	Заповнити поля предмету  ${item}
    #  Зберегти
    webclient.header натиснути на елемент за назвою  Зберегти
	${is_visible}  run keyword and return status  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  ${is_visible}  dialog box натиснути кнопку  Так
	run keyword if  'below' not in '${mode}'  run keywords
    ...  dialog box заголовок повинен містити  Накласти ЕЦП/КЕП на тендер?  AND
	...  dialog box натиснути кнопку  Ні

	
Завантажити документ в лот
    [Arguments]  ${username}  ${filepath}  ${tender_uaid}  ${lot_id}
    [Documentation]  Завантажити документ, який знаходиться по шляху filepath, до лоту з lot_id в описі для тендера tender_uaid
    знайти тендер у webclient  ${tender_uaid}
	header натиснути на елемент за назвою  Змінити
	webclient.header натиснути на елемент за назвою  Коригувати
	webclient.активувати вкладку  Документи
	#  Стати на комірку з потрібним лотом
	${lot_row_locator}  set variable  xpath=//*[@data-name="TREEDOCS"]//td[contains(text(),"${lot_id}")]/ancestor::tr[1]
	click element  ${lot_row_locator}
	wait until page contains element  ${lot_row_locator}[contains(@class,"rowselected")]  5
	#  Додаєм документ
	webclient.натиснути додати документ
	loading дочекатись закінчення загрузки сторінки
	webclient.загрузити документ  ${filepath}
	log to console  Завантажити документ в ло
	debug
	webclient.header натиснути на елемент за назвою  Зберегти
	${is_visible}  run keyword and return status  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  ${is_visible}  dialog box натиснути кнопку  Так
    run keyword and ignore error  dialog box заголовок повинен містити  Накласти ЕЦП/КЕП на тендер?
	run keyword and ignore error  dialog box натиснути кнопку  Ні
	webclient.screen заголовок повинен містити  Завантаження документації
	click element   ${screen_root_selector}//*[@alt="Close"]
    sleep  60
	
	
Видалити лот
    [Arguments]  ${username}  ${tender_uaid}  ${lot_id}
    [Documentation]  Видалити лот з lot_id в описі для тендера tender_uaid.
	знайти тендер у webclient  ${tender_uaid}
	header натиснути на елемент за назвою  Змінити
	header натиснути на елемент за назвою  Коригувати
	# ЛОТИ
	видалити lot по id  ${lot_id}
	#  Зберегти
    webclient.header натиснути на елемент за назвою  Зберегти
	${is_visible}  run keyword and return status  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  ${is_visible}  dialog box натиснути кнопку  Так
	run keyword if  'below' not in '${mode}'  run keywords
    ...  dialog box заголовок повинен містити  Накласти ЕЦП/КЕП на тендер?  AND
	...  dialog box натиснути кнопку  Ні


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
    ${link}  Get Element Attribute  ${selector}/ancestor::div[@class="document-poptip ivu-poptip"]//a[@data-qa="file-preview"]@href
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
	${file_name}  smarttender.Отримати документ  ${username}  ${tender_uaid}  ${doc_id}
	[Return]  ${file_name}
    
    
Додати не ціновий показник на тендер
    [Arguments]  ${username}  ${tender_uaid}  ${feature}
    [Documentation]  Додати дані feature про не ціновий показник до тендера tender_uaid   
	log to console  Додати не ціновий показник на тендер
	знайти тендер у webclient  ${tender_uaid}
	header натиснути на елемент за назвою  Змінити
	header натиснути на елемент за назвою  Коригувати
	webclient.активувати вкладку  Якісні показники
	Заповнити якісні показники  ${feature}
    header натиснути на елемент за назвою  Зберегти
    ${is_visible}  run keyword and return status  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  ${is_visible}  dialog box натиснути кнопку  Так
	run keyword if  'below' not in '${mode}'  run keywords
    ...  dialog box заголовок повинен містити  Накласти ЕЦП/КЕП на тендер?  AND
	...  dialog box натиснути кнопку  Ні

	
	
Додати не ціновий показник на предмет
    [Arguments]  ${username}  ${tender_uaid}  ${feature}  ${item_id}
    [Documentation]  Додати дані feature про неціновий показник до предмету з item_id в описі для тендера tender_uaid.   
	log to console  Додати не ціновий показник на предмет
	знайти тендер у webclient  ${tender_uaid}
	header натиснути на елемент за назвою  Змінити
	header натиснути на елемент за назвою  Коригувати
	webclient.активувати вкладку  Якісні показники
	Заповнити якісні показники  ${feature}  ${item_id}
    header натиснути на елемент за назвою  Зберегти
    ${is_visible}  run keyword and return status  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  ${is_visible}  dialog box натиснути кнопку  Так
	run keyword if  'below' not in '${mode}'  run keywords
    ...  dialog box заголовок повинен містити  Накласти ЕЦП/КЕП на тендер?  AND
	...  dialog box натиснути кнопку  Ні


Додати не ціновий показник на лот
    [Arguments]  ${username}  ${tender_uaid}  ${feature}  ${lot_id}
    [Documentation]  Додати дані feature про неціновий показник до лоту з lot_id в описі для тендера tender_uaid.   
	log to console  Додати не ціновий показник на лот
	знайти тендер у webclient  ${tender_uaid}
	header натиснути на елемент за назвою  Змінити
	header натиснути на елемент за назвою  Коригувати
	webclient.активувати вкладку  Якісні показники
	Заповнити якісні показники  ${feature}  ${lot_id}
    header натиснути на елемент за назвою  Зберегти
    ${is_visible}  run keyword and return status  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  ${is_visible}  dialog box натиснути кнопку  Так
	run keyword if  'below' not in '${mode}'  run keywords
    ...  dialog box заголовок повинен містити  Накласти ЕЦП/КЕП на тендер?  AND
	...  dialog box натиснути кнопку  Ні
	
	
Отримати інформацію із нецінового показника
    [Arguments]  ${username}  ${tender_uaid}  ${feature_id}  ${field_name}
    [Documentation]  Отримати значення поля field_name з нецінового показника з feature_id в описі для тендера tender_uaid.
	перейти до сторінки детальної інформаціїї за необхідністю
	${feature_block}  set variable  //*[contains(@data-qa,"feature-list")][contains(., "${feature_id}")]
	smarttender.розгорнути всі експандери
    ${feature_field_name}  run keyword  smarttender.нецінові_сторінка_детальної отримати ${field_name}  ${feature_block}
    [Return]  ${feature_field_name}
    
   
Видалити неціновий показник
    [Arguments]  ${username}  ${tender_uaid}  ${feature_id}  ${obj_id}=${Empty}
    [Documentation]  Видалити неціновий показник з feature_id в описі для тендера tender_uaid.   
	log to console  Видалити неціновий показник
    знайти тендер у webclient  ${tender_uaid}
	header натиснути на елемент за назвою  Змінити
	header натиснути на елемент за назвою  Коригувати
	webclient.активувати вкладку  Якісні показники
	#  Видалити
	видалити feature по id  ${feature_id}
	#  Зберегти
	header натиснути на елемент за назвою  Зберегти
    ${is_visible}  run keyword and return status  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  ${is_visible}  dialog box натиснути кнопку  Так
	run keyword if  'below' not in '${mode}'  run keywords
    ...  dialog box заголовок повинен містити  Накласти ЕЦП/КЕП на тендер?  AND
	...  dialog box натиснути кнопку  Ні

	
Задати запитання на предмет
    [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${question}
    [Documentation]  Створити запитання з даними question до предмету з item_id в описі для тендера tender_uaid.
    smarttender.сторінка_детальної_інформації активувати вкладку  Запитання
	запитання_вибрати тип запитання  ${item_id}
	smarttender.запитання_натиснути кнопку "Поставити запитання"
	smarttender.запитання_заповнити тему             ${question['data']['title']}
	smarttender.запитання_заповнити текст запитання  ${question['data']['description']}
	smarttender.запитання_натиснути кнопку "Подати"
	
	
Задати запитання на лот
    [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${question}
    [Documentation]  Створити запитання з даними question до лоту з lot_id в описі для тендера tender_uaid.
	smarttender.сторінка_детальної_інформації активувати вкладку  Запитання
	запитання_вибрати тип запитання  ${lot_id}
	smarttender.запитання_натиснути кнопку "Поставити запитання"
	smarttender.запитання_заповнити тему             ${question['data']['title']}
	smarttender.запитання_заповнити текст запитання  ${question['data']['description']}
	smarttender.запитання_натиснути кнопку "Подати"
	
	
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
    #на той стороне решили не ждать синхронизации, можно зарепортить
    ${test_list}  create list
    ...  Відображення заголовку анонімного запитання на тендер без відповіді
    ...  Відображення заголовку анонімного запитання на всі лоти без відповіді
    run keyword if  u"${TEST_NAME}" in @{test_list}
    ...  smarttender.Синхронізувати тендер
    перейти до сторінки детальної інформаціїї за необхідністю
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
    знайти тендер у webclient  ${tender_uaid}
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
	run keyword and ignore error  webclient.header натиснути на елемент за назвою  Записати
	webclient.активувати вкладку  Тестові публічні закупівлі
	
	
Створити вимогу про виправлення умов закупівлі
    [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${document}=${None}
    [Documentation]  Створює вимогу claim про виправлення умов закупівлі у статусі claim для тендера tender_uaid. Можна створити вимогу як з документом, який знаходиться за шляхом document, так і без нього.
    ${title}  set variable  ${claim['data']['title']}
    ${description}  set variable  ${claim['data']['description']}
    перейти до сторінки детальної інформаціїї за необхідністю
    ${tender_title}  smarttender.сторінка_детальної_інформації отримати title
    smarttender.сторінка_детальної_інформації активувати вкладку  Вимоги/скарги на умови закупівлі
	вимога_вибрати тип запитання  ${tender_title}
	вимога_натиснути кнопку Подати вимогу "Замовнику"
	вимога_заповнити тему  ${title}
	вимога_заповнити текст запитання  ${description}
	run keyword if  "${document}" != "${None}"  вимога_завантажити документ  ${document}
	wait until keyword succeeds  1m  1  вимога_натиснути кнопку "Подати"
	${complaintID}  вимога_отримати complaintID по ${title}
    [Return]  ${complaintID}
    
    
Створити вимогу про виправлення умов лоту
    [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${lot_id}  ${document}=${None}
    [Documentation]  Створює вимогу claim про виправлення умов лоту у статусі claim для тендера tender_uaid. Можна створити вимогу як з документом, який знаходиться за шляхом document, так і без нього.
	${title}  set variable  ${claim['data']['title']}
    ${description}  set variable  ${claim['data']['description']}
    перейти до сторінки детальної інформаціїї за необхідністю
    smarttender.сторінка_детальної_інформації активувати вкладку  Вимоги/скарги на умови закупівлі
	вимога_вибрати тип запитання  ${lot_id}
	вимога_натиснути кнопку Подати вимогу "Замовнику"
	вимога_заповнити тему  ${title}
	вимога_заповнити текст запитання  ${description}
	run keyword if  "${document}" != "${None}"  вимога_завантажити документ  ${document}
	wait until keyword succeeds  1m  1  вимога_натиснути кнопку "Подати"
	${complaintID}  вимога_отримати complaintID по ${title}
    [Return]  ${complaintID}
    
    
Створити вимогу про виправлення визначення переможця
    [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${award_index}  ${document}=${None}
    [Documentation]  Створює вимогу claim про виправлення визначення переможця під номером award_index в статусі claim для тендера tender_uaid. Можна створити вимогу як з документом, який знаходиться за шляхом document, так і без нього.
    ${title}  set variable  ${claim['data']['title']}
    ${description}  set variable  ${claim['data']['description']}
    вимоги_кваліфікація перейти на сторінку по індексу  ${award_index}
    вимога_натиснути кнопку Подати вимогу "Замовнику"
	вимога_заповнити тему  ${title}
	вимога_заповнити текст запитання  ${description}
	run keyword if  "${document}" != "${None}"  вимога_завантажити документ  ${document}
	wait until keyword succeeds  1m  1  вимога_натиснути кнопку "Подати"
	${complaintID}  вимоги_кваліфікація отримати complaintID по ${title}
	go to  ${tender_detail_page}
	loading дочекатись закінчення загрузки сторінки
    [Return]  ${complaintID}
    
    
Скасувати вимогу про виправлення умов закупівлі
    [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}
    [Documentation]  Перевести вимогу complaintID про виправлення умов закупівлі для тендера tender_uaid у статус cancelled, використовуючи при цьому дані cancellation_data.
    перейти до сторінки детальної інформаціїї за необхідністю
    smarttender.сторінка_детальної_інформації активувати вкладку  Вимоги/скарги на умови закупівлі
    ${cancellationReason}  set variable  ${cancellation_data['data']['cancellationReason']}
	вимога_натиснути коригувати  ${complaintID}
	вимога_натиснути Скасувати вимогу  ${cancellationReason}


Скасувати вимогу про виправлення умов лоту
    [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}
    [Documentation]  Перевести вимогу complaintID про виправлення умов лоту для тендера tender_uaid у статус cancelled, використовуючи при цьому дані cancellation_data.
	перейти до сторінки детальної інформаціїї за необхідністю
    smarttender.сторінка_детальної_інформації активувати вкладку  Вимоги/скарги на умови закупівлі
	${cancellationReason}  set variable  ${cancellation_data['data']['cancellationReason']}
	вимога_натиснути коригувати  ${complaintID}
	вимога_натиснути Скасувати вимогу  ${cancellationReason}


Створити скаргу про виправлення визначення переможця
    [Documentation]  Створює скаргу у статусі "pending"
    ...      Можна створити скаргу як з документацією, так і без неї
    [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${award_index}  ${document}=${None}
    ${title}  set variable  ${claim['data']['title']}
    ${description}  set variable  ${claim['data']['description']}
    вимоги_кваліфікація перейти на сторінку по індексу  ${award_index}
    вимога_натиснути кнопку Подати скаргу до "АМКУ"
	вимога_заповнити тему  ${title}
	вимога_заповнити текст запитання  ${description}
	run keyword if  "${document}" != "${None}"  вимога_завантажити документ  ${document}
	wait until keyword succeeds  1m  1  вимога_натиснути кнопку "Подати"
	${complaintID}  вимоги_кваліфікація отримати complaintID по ${title}
	go to  ${tender_detail_page}
	loading дочекатись закінчення загрузки сторінки
    [Return]  ${complaintID}


Отримати інформацію із скарги
    [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${field_name}  ${award_index}=${None}
    [Documentation]  Отримати значення поля field_name скарги/вимоги complaintID
	# Не у всіх тесткейсах потрібно ждати синхронізацію
	${test_list}  create list
    ...  Відображення кінцевих статусів двох останніх вимог
    ...  Відображення статусу 'ignored' вимоги про виправлення визначення переможця
    run keyword if  "${TEST_NAME}" in @{test_list} or "SmartTender_Provider1" == "${username}"
        ...  smarttender.Синхронізувати тендер
	#  Залежно від того це звичайна скарга чи скарга на award відкриваємо потрібну сторінку
	${is_award_complaint}  run keyword and return status  log  ${submissionMethodDetails}
	run keyword if  ${is_award_complaint}
			...  smarttender._перейти до сторінки вимоги_кваліфікація  ${award_index}
	...  ELSE
			...  smarttender._перейти до сторінки вимоги
	#
	smarttender._розгорнути блок скарги  ${complaintID}
	${complaint_field_value}  run keyword  вимога_отримати інформацію по полю ${field_name}  ${complaintID}
    [Return]  ${complaint_field_value}


_розгорнути блок скарги
	[Arguments]  ${complaintID}
	${complaint_block_locator}  set variable  //*[@class="complaint-list"]//*[@data-qa="complaint" and contains(., "${complaintID}")]
	${selector_down_locator}  Set Variable  //*[contains(@class,"expander")]/i[contains(@class,"down")]
	${selector_down_visible}  run keyword and return status  element should be visible  xpath=${complaint_block_locator}${selector_down_locator}
	return from keyword if  ${selector_down_visible} == ${False}
	Click Element  xpath=${complaint_block_locator}${selector_down_locator}
    # Перевіряємо, що блок розгорнувся
    smarttender._розгорнути блок скарги  ${complaintID}


_перейти до сторінки вимоги
	перейти до сторінки детальної інформаціїї за необхідністю
	smarttender.сторінка_детальної_інформації активувати вкладку  Вимоги/скарги на умови закупівлі


_перейти до сторінки вимоги_кваліфікація
	[Arguments]  ${award_index}
	перейти до сторінки детальної інформаціїї за необхідністю
	smarttender.сторінка_детальної_інформації активувати вкладку  Тендер
    вимоги_кваліфікація перейти на сторінку по індексу  ${award_index}


Отримати інформацію із документа до скарги
	[Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${document_id}  ${field_name}
	log to console  Отримати інформацію із документа до скарги
	#  Залежно від того це звичайна скарга чи скарга до award відкриваємо потрібну сторінку
	${is_award_complaint}  run keyword and return status  log  ${submissionMethodDetails}
	run keyword if  ${is_award_complaint}
			...  smarttender._перейти до сторінки вимоги_кваліфікація  0
	...  ELSE
			...  smarttender._перейти до сторінки вимоги
	#
	smarttender._розгорнути блок скарги  ${complaintID}
	${complaint_field_value}  run keyword  вимога_отримати інформацію з докуммента по полю ${field_name}  ${complaintID}
    [Return]  ${complaint_field_value}

    
Відповісти на вимогу про виправлення умов закупівлі
    [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}
    [Documentation]  Відповісти на вимогу complaintID про виправлення умов закупівлі для тендера tender_uaid, використовуючи при цьому дані answer_data.
	webclient.знайти тендер у webclient  ${tender_uaid}  force_go_to=${True}
	#  знаходимо потрібну вимогу
	${tab_status}  run keyword and return status  webclient.активувати вкладку  Звернення за умовами тендеру
	run keyword if  "${tab_status}" == "False"    webclient.активувати вкладку  Оскарження умов тендеру
	webclient.header натиснути на елемент за назвою  Оновити
	${complaintID_search_field}  set variable  xpath=((//*[@data-type="GridView"])[2]//td//input)[1]
    clear input by JS  ${complaintID_search_field}
    Input Type Flex  ${complaintID_search_field}  ${complaintID}
	press key   ${complaintID_search_field}  \\13
	loading дочекатись закінчення загрузки сторінки
	#  вносимо відповідь на вимогу
	webclient.header натиснути на елемент за назвою  Змінити
	${answer_data}             set variable  ${answer_data['data']}
	${resolutionType}          conver_resolutionType  ${answer_data['resolutionType']}
	${resolution locator}      set variable  //*[@data-name="RESOLUTION"]//textarea
	${resolutionType locator}  set variable  //*[@data-name="RESOLUTYPE"]//input[@class]
	webclient.заповнити simple input                 ${resolution locator}      ${answer_data['resolution']}
	webclient.вибрати значення з випадаючого списку  ${resolutionType locator}  ${resolutionType}
	#  зберігаємо та відправляємо вимогу
    webclient.header натиснути на елемент за назвою  Зберегти
    dialog box заголовок повинен містити  Надіслати відповідь
	dialog box натиснути кнопку  Так

	
Підтвердити вирішення вимоги про виправлення умов закупівлі
    [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}
    [Documentation]  Перевести вимогу complaintID про виправлення умов закупівлі для тендера tender_uaid у статус resolved, використовуючи при цьому дані confirmation_data.
	перейти до сторінки детальної інформаціїї за необхідністю
    smarttender.сторінка_детальної_інформації активувати вкладку  Вимоги/скарги на умови закупівлі
	${satisfied}  set variable  ${confirmation_data['data']['satisfied']}
    вимога_натиснути коригувати  ${complaintID}
    вимогу_натиснути Вимогу задоволено?  ${satisfied}


Скасувати вимогу про виправлення визначення переможця
    [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}  ${award_index}
    [Documentation]  Перевести вимогу complaintID про виправлення визначення переможця під номером award_index для тендера tender_uaid у статус cancelled, використовуючи при цьому дані confirmation_data.  
	перейти до сторінки детальної інформаціїї за необхідністю
    вимоги_кваліфікація перейти на сторінку по індексу  ${award_index}
	${cancellationReason}  set variable  ${cancellation_data['data']['cancellationReason']}
	вимога_натиснути коригувати  ${complaintID}
	вимога_натиснути Скасувати вимогу  ${cancellationReason}
	go to  ${tender_detail_page}
	loading дочекатись закінчення загрузки сторінки


Відповісти на вимогу про виправлення визначення переможця
    [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}  ${award_index}
    [Documentation]  Відповісти на вимогу complaintID про виправлення визначення переможця під номером award_index для тендера tender_uaid, використовуючи при цьому дані answer_data.
	# Есть один тесткейс в котором нужно принудительно перезайти в вебклиент, а в других кейсах так делать не стоит, ведь мы потеряем 20-30 секунд и не успеем в период
	run keyword if  "відповісти і після того скасувати вимогу про виправлення визначення переможця" in "${TEST_NAME}"
		...  smart go to  https://test.smarttender.biz/
    webclient.знайти тендер у webclient  ${tender_uaid}
    #  знаходимо потрібну вимогу
	вибрати переможця за номером  ${award_index}+1
	run keyword if  "${mode}" == "openua"
        ...  webclient.активувати вкладку  Оскарження рішення
    ...  ELSE
        ...  webclient.активувати вкладку  Звернення  index=2
    log to console  Відповісти на вимогу про виправлення визначення переможця
    loading дочекатись закінчення загрузки сторінки
    wait until keyword succeeds  5x  1s  click element  //*[text()="${complaintID}"]
    loading дочекатись закінчення загрузки сторінки
	#  вносимо відповідь на вимогу
	webclient.header натиснути на елемент за назвою  Змінити
	${answer_data}             set variable  ${answer_data['data']}
	${resolutionType}          conver_resolutionType  ${answer_data['resolutionType']}
	${resolution locator}      set variable  //*[@data-name="RESOLUTION"]//textarea
	${resolutionType locator}  set variable  //*[@data-name="RESOLUTYPE"]//input[@class]
	webclient.заповнити simple input                 ${resolution locator}      ${answer_data['resolution']}
	webclient.вибрати значення з випадаючого списку  ${resolutionType locator}  ${resolutionType}
	#  зберігаємо та відправляємо вимогу
    webclient.header натиснути на елемент за назвою  Зберегти
    dialog box заголовок повинен містити  Надіслати відповідь
	dialog box натиснути кнопку  Так


Підтвердити вирішення вимоги про виправлення визначення переможця
    [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}  ${award_index}
    [Documentation]  Перевести вимогу complaintID про виправлення визначення переможця під номером award_index для тендера tender_uaid у статус resolved, використовуючи при цьому дані cancellation_data.  
	перейти до сторінки детальної інформаціїї за необхідністю
    вимоги_кваліфікація перейти на сторінку по індексу  ${award_index}
    ${satisfied}  set variable  ${confirmation_data['data']['satisfied']}
    вимога_натиснути коригувати  ${complaintID}
    вимогу_натиснути Вимогу задоволено?  ${satisfied}
    go to  ${tender_detail_page}
	loading дочекатись закінчення загрузки сторінки


Завантажити документ
    [Arguments]  ${username}  ${filepath}  ${tender_uaid}
    [Documentation]  Завантажити документ, який знаходиться по шляху filepath, до тендера tender_uaid.
	знайти тендер у webclient  ${tender_uaid}
	webclient.header натиснути на елемент за назвою  Змінити
	run keyword and ignore error  webclient.header натиснути на елемент за назвою  Коригувати
	webclient.активувати вкладку  Документи
	webclient.натиснути додати документ
	loading дочекатись закінчення загрузки сторінки
	webclient.загрузити документ  ${filepath}
	webclient.header натиснути на елемент за назвою  Зберегти
	${is_visible}  run keyword and return status  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  ${is_visible}  dialog box натиснути кнопку  Так
	run keyword if  'below' not in '${mode}'  run keywords
    ...  dialog box заголовок повинен містити  Накласти ЕЦП/КЕП на тендер?  AND
	...  dialog box натиснути кнопку  Ні
	webclient.screen заголовок повинен містити  Завантаження документації
	click element   ${screen_root_selector}//*[@alt="Close"]
    sleep  60


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


документи_сторінка_детальної_інформації отримати documentOf
    [Arguments]  ${doc_block}
    [Return]  tender


Подати цінову пропозицію
    [Arguments]  ${username}  ${tender_uaid}  ${bid}  ${lots_ids}=${None}  ${features_names}=${None}
    [Documentation]  Подати цінову пропозицію bid для тендера tender_uaid на лоти lots_ids (якщо lots_ids != None) з неціновими показниками features_names (якщо features_names != None).

    comment  Якщо id лоту відсутнє створюєму список з пустим значенням
    ${list_with_empty_value}  create list  ${Empty}
    ${lots_ids}  Set Variable If  "${lots_ids}" is "${None}"  ${list_with_empty_value}  ${lots_ids}

    smarttender.пропозиція_перевірити кнопку подачі пропозиції
    # ${count_lot} костиль для отриманяя правильного ['value']['amount'] для потрібного лоту
    # буде працювати тільки якщо relatedLot в lotValues буду співпадати з послідовністю в ${lots_ids}
    set test variable  ${count_lot}  0
    :FOR  ${lot}  IN  @{lots_ids}
    \  smarttender.пропозиція_заповнити поле з ціною  ${lot}  ${bid}

    run keyword if  "${features_names}" != "${None}"
    ...  _вибрати нецінові показники на сторінці детальної інформації тендера  ${bid}  ${features_names}

    ${should_upload_file}  create list  open_framework  openeu
    run keyword if  '${mode}' in ${should_upload_file}  створити та загрузити документ для подачі пропозиції

    smarttender.пропозиція_відмітити чекбокси при наявності
    smarttender.пропозиція_подати пропозицію
	smarttender.пропозиція_закрити вікно з ЕЦП


Отримати інформацію із пропозиції
    [Arguments]  ${username}  ${tender_uaid}  ${field}
    [Documentation]  Отримати значення поля field пропозиції користувача username для тендера tender_uaid.
    comment  пейти на сторінку біда за неохідністю
    ${current_location}  get location
    ${tender_bid_page}  set variable  ${tender_detail_page.replace("publichni-zakupivli-prozorro", "bid/edit")}
    run keyword if  "${current_location}" != "${tender_bid_page}"  run keywords
    ...  go to  ${tender_bid_page}  AND  loading дочекатись закінчення загрузки сторінки
    #############################################################################################
	${bid_field}  run keyword  smarttender.пропозиція_отримати інформацію по полю ${field}
    [Return]  ${bid_field}


створити та загрузити документ для подачі пропозиції
    ${file loading}  set variable  css=div.loader
    ${list_of_file_args}  create_fake_doc
	${file_path}  set variable  ${list_of_file_args[0]}
	Choose File  xpath=(//input[@type="file"][1])[1]  ${file_path}
	${status}  ${message}  Run Keyword And Ignore Error  Wait Until Page Contains Element  ${file loading}  3
	Run Keyword If  "${status}" == "PASS"  Run Keyword And Ignore Error  Wait Until Page Does Not Contain Element  ${file loading}


Змінити цінову пропозицію
    [Arguments]  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}
    [Documentation]  Змінити поле fieldname на fieldvalue цінової пропозиції користувача username для тендера tender_uaid.
	${status}  ${lot_number}  run keyword and ignore error  evaluate  re.search(r'\\d', "${fieldname}").group()  re
    ${lot_number}  set variable if  "${status}" == "FAIL"  ${Empty}  ${lot_number}
    ${selector}  set variable  //*[contains(@id, "lotAmount${lot_number}")]//input
	run keyword if  "value" in "${fieldvalue}"  ввести ціну пропозиції  ${selector}  ${fieldvalue}
	smarttender.пропозиція_подати пропозицію
	smarttender.пропозиція_закрити вікно з ЕЦП


Завантажити документ в ставку
    [Arguments]  ${username}  ${path}  ${tender_uaid}  ${doc_type}=None  ${doc_name}=None
    [Documentation]  Завантажити документ типу doc_type, який знаходиться за шляхом path, до цінової пропозиції користувача username для тендера tender_uaid.
	choose file  xpath=(//input[@type="file"][1])[1]  ${path}
	run keyword if  "${doc_type}" != "None"  smarttender.пропозиція_вибрати тип документу  ${doc_type}
	smarttender.пропозиція_подати пропозицію
	smarttender.пропозиція_закрити вікно з ЕЦП


Змінити документ в ставці
    [Arguments]  ${username}  ${tender_uaid}  ${path}  ${docid}
    [Documentation]  Змінити документ з doc_id в описі в пропозиції користувача username для тендера tender_uaid на документ, який знаходиться по шляху path.
	Choose File  xpath=(//input[@type="file"][1])[1]  ${path}
	smarttender.пропозиція_подати пропозицію
	smarttender.пропозиція_закрити вікно з ЕЦП
#    go back
#    loading дочекатись закінчення загрузки сторінки


Змінити документацію в ставці
    [Arguments]  ${username}  ${tender_uaid}  ${doc_data}  ${doc_id}
    [Documentation]  Змінити тип документа з doc_id в заголовку в пропозиції користувача username для тендера tender_uaid. Дані про новий тип документа знаходяться в doc_data.
	${confidentiality_status}  run keyword and return status  Dictionary Should Contain key  ${doc_data['data']}  confidentiality

	run keyword if  ${confidentiality_status}  пропозиція_змінити кофіденційність файлу  ${doc_data}  ${doc_id}
    smarttender.пропозиція_подати пропозицію
	smarttender.пропозиція_закрити вікно з ЕЦП


Скасувати цінову пропозицію
    [Arguments]  ${username}  ${tender_uaid}
    [Documentation]  Змінити статус цінової пропозиції для тендера tender_uaid користувача username на cancelled.
    ${block}                            set variable  //*[@class='ivu-card ivu-card-bordered']
    ${cancellation offers button}       set variable  ${block}\[last()]//div[@class="ivu-poptip-rel"]/button
    ${cancel. offers confirm button}    set variable  ${block}\[last()]//div[@class="ivu-poptip-footer"]/button[2]
	loading дочекатися відображення елемента на сторінці  ${cancellation offers button}
	Click Element  ${cancellation offers button}
	Click Element  ${cancel. offers confirm button}
	loading дочекатись закінчення загрузки сторінки
    ${status}  пропозиція_отримати інформацію по полю status
    run keyword if  "${status}" != "None"  Скасувати цінову пропозицію  ${username}  ${tender_uaid}


Завантажити документ у кваліфікацію
    [Arguments]  ${username}  ${document}  ${tender_uaid}  ${qualification_num}
    [Documentation]  Завантажити документ, який знаходиться по шляху document, до кваліфікації під номером qualification_num до тендера tender_uaid  
	log to console  Завантажити документ у кваліфікацію

	знайти тендер у webclient  ${tender_uaid}
    активувати вкладку  Прекваліфікація
	header натиснути на елемент за назвою  Оновити
	вибрати учасника за номером  ${qualification_num}+1

    header натиснути на елемент за назвою  Прийняти рішення прекваліфікації
	click element  //div[@data-name][@title="Додати протокол"]
	loading дочекатись закінчення загрузки сторінки
	загрузити документ  ${document}
	Заповнити текст рішення квалиіфікації  Загрузка документа без кваліфікації учасника
	header натиснути на елемент за назвою  Зберегти
	dialog box заголовок повинен містити  Увага!
	dialog box натиснути кнопку  Так


Підтвердити кваліфікацію
    [Arguments]  ${username}  ${tender_uaid}  ${qualification_num}
    [Documentation]  Перевести кваліфікацію під номером qualification_num до тендера tender_uaid в статус active.  
	log to console  Підтвердити кваліфікацію
    знайти тендер у webclient  ${tender_uaid}
    активувати вкладку  Прекваліфікація

    comment  в конкурентных диалогах qualification_num второго и выше учасника почему-то прилетает отрицательное число, поэтому берем абсолютное
    ${qualification_num}  evaluate  abs(${qualification_num})

	вибрати учасника за номером  ${qualification_num}+1
	header натиснути на елемент за назвою  Прийняти рішення прекваліфікації
	header натиснути на елемент за назвою  Допустити
    Кваліфікація. Відмітити чек-бокси для переможця за необхідністю
	header натиснути на елемент за назвою  Відіслати рішення
	dialog box заголовок повинен містити  Ви впевнені у своєму рішенні?
	dialog box натиснути кнопку  Так


Відхилити кваліфікацію
    [Arguments]  ${username}  ${tender_uaid}  ${qualification_num}
    [Documentation]  Перевести кваліфікацію під номером qualification_num до тендера tender_uaid в статус unsuccessful.  
	log to console  Відхилити кваліфікацію
    ${location}  get location
    run keyword if  "webclient" not in "${location}"  знайти тендер у webclient  ${tender_uaid}
    активувати вкладку  Прекваліфікація
	вибрати учасника за номером  ${qualification_num}+1
	header натиснути на елемент за назвою  Прийняти рішення прекваліфікації
	header натиснути на елемент за назвою  Відхилити
	${checkbox_1}  set variable  xpath=//td[.="Не відповідає кваліфікаційним критеріям"]/preceding-sibling::td[1]
	click element  ${checkbox_1}
	header натиснути на елемент за назвою  Відіслати рішення
	dialog box заголовок повинен містити  Ви впевнені у своєму рішенні?
	dialog box натиснути кнопку  Так


Скасувати кваліфікацію
    [Arguments]  ${username}  ${tender_uaid}  ${qualification_num}
    [Documentation]  Перевести кваліфікацію під номером qualification_num до тендера tender_uaid в статус cancelled.  
	log to console  Скасувати кваліфікацію
    ${location}  get location
    run keyword if  "webclient" not in "${location}"  знайти тендер у webclient  ${tender_uaid}

    comment  Если были действия с последним учасником, остается окно "Розгляд учасників закінчено? Перевести закупівлю на наступну стадію?"
    ...  закрываем его и прлдолжаем работу
    ${is_visible}  run keyword and return status  dialog box заголовок повинен містити  Розгляд учасників закінчено? Перевести закупівлю на наступну стадію?
    run keyword if  ${is_visible}  dialog box натиснути кнопку  Ні

    активувати вкладку  Прекваліфікація
	вибрати учасника за номером  ${qualification_num}+1
	header натиснути на елемент за назвою  Прийняти рішення прекваліфікації
	header натиснути на елемент за назвою  Скасувати прийняте рішення
    dialog box заголовок повинен містити  Ви впевнені що хочете скасувати своє рішення?
    dialog box натиснути кнопку  Так


Затвердити остаточне рішення кваліфікації
    [Arguments]  ${username}  ${tender_uaid}
    [Documentation]  Перевести тендер tender_uaid в статус active.pre-qualification.stand-still.  
	log to console  Затвердити остаточне рішення кваліфікації
    dialog box заголовок повинен містити  Розгляд учасників закінчено? Перевести закупівлю на наступну стадію?
    dialog box натиснути кнопку  Так
    ${is_visible}  run keyword and return status  dialog box заголовок повинен містити  Сформувати протокол розгляду пропозицій?
    run keyword if  "${is_visible}" == "${False}"  _надіслати вперед для отримання повідомлення
    dialog box натиснути кнопку  Так


_надіслати вперед для отримання повідомлення
    активувати вкладку  Тестові публічні закупівлі
    header натиснути на елемент за назвою  Надіслати вперед


Отримати посилання на аукціон для глядача
    [Arguments]  ${username}  ${tender_uaid}  ${lot_id}=${Empty}
    [Documentation]  Отримати посилання на аукціон для тендера tender_uaid (або для лоту з lot_id в описі для тендера tender_uaid, якщо lot_id != Empty).
    перейти до сторінки детальної інформаціїї за необхідністю
	${auctionUrl}  smarttender.отримати посилання на прегляд аукціону не учасником
    [Return]  ${auctionUrl}


Отримати посилання на аукціон для учасника
    [Arguments]  ${username}  ${tender_uaid}  ${lot_id}=${Empty}
    [Documentation]  Отримати посилання на участь в аукціоні для користувача username для тендера tender_uaid (або для лоту з lot_id в описі для тендера tender_uaid, якщо lot_id != Empty).
    перейти до сторінки детальної інформаціїї за необхідністю  
	${participationUrl}  ${auction_href}  отримати посилання на участь та прегляд аукціону для учасника
    [Return]  ${participationUrl}


Завантажити документ рішення кваліфікаційної комісії
    [Arguments]  ${username}  ${document}  ${tender_uaid}  ${award_num}
    [Documentation]  Завантажити документ, який знаходиться по шляху document до постачальника під номером award_num для тендера tender_uaid.
	знайти тендер у webclient  ${tender_uaid}
	${tab_status}  run keyword and return status  активувати вкладку  Пропозиції
	run keyword if  '${tab_status}' == 'False'    активувати вкладку  Предложения
	header натиснути на елемент за назвою  Оновити

	comment  из-за неправильного нэйминга теста, меняем индекс award
	${award_num}  smarttender.Визначити необхідний award_num для кваліфікації  ${award_num}

	вибрати переможця за номером  ${award_num}+1
	header натиснути на елемент за назвою  Кваліфікація
	smarttender._закарити сповіщення про кваліфікацію за необхідністю
	click element  //*[@data-name]//*[contains(text(), 'Перегляд...')]
	loading дочекатись закінчення загрузки сторінки
	загрузити документ  ${document}
	Заповнити текст рішення квалиіфікації  Загрузка документа без кваліфікації учасника
	${is_visible_save_btn}  run keyword and return status   header натиснути на елемент за назвою  Зберегти
	run keyword if  "${is_visible_save_btn}" == "${False}"  header натиснути на елемент за назвою  Продовжити кваліфікацію
	dialog box заголовок повинен містити  Увага!
	dialog box натиснути кнопку  Так
	Підписати ЕЦП(webclient)



Підтвердити постачальника
    [Arguments]  ${username}  ${tender_uaid}  ${award_num}
    [Documentation]  Перевести постачальника під номером award_num для тендера tender_uaid в статус active.
	знайти тендер у webclient  ${tender_uaid}
	${tab_status}  run keyword and return status  активувати вкладку  Пропозиції
	run keyword if  '${tab_status}' == 'False'    активувати вкладку  Предложения
	header натиснути на елемент за назвою  Оновити
	log to console  Підтвердити постачальника

    comment  из-за неправильного нэйминга теста, меняем индекс award
	${award_num}  smarttender.Визначити необхідний award_num для кваліфікації  ${award_num}

	вибрати переможця за номером  ${award_num}+1
	header натиснути на елемент за назвою  Кваліфікація
	smarttender._закарити сповіщення про кваліфікацію за необхідністю
	click element  //*[contains(text(), "Визначити переможцем")]
	wait until page contains  Визнаний переможцем
	Заповнити текст рішення квалиіфікації  Визначення переможцем
	Кваліфікація. Відмітити чек-бокси для переможця за необхідністю
	${list_of_file_args}  create_fake_doc
	${file_path}  set variable  ${list_of_file_args[0]}
	click element  //*[@data-name]//*[contains(text(), 'Перегляд...')]
	loading дочекатись закінчення загрузки сторінки
	загрузити документ  ${file_path}

	${is_visible_save_btn}  run keyword and return status   header натиснути на елемент за назвою  Зберегти
	run keyword if  "${is_visible_save_btn}" == "${False}"  header натиснути на елемент за назвою  Продовжити кваліфікацію
	dialog box заголовок повинен містити  Ви впевнені у своєму рішенні?
	dialog box натиснути кнопку  Так
	Підписати ЕЦП(webclient)


Визначити необхідний award_num для кваліфікації
    [Arguments]  ${award_num}
    ${mode_list}  create list  openua  openeu  open_competitive_dialogue  open_framework
	${award_num}  set variable if
	...  ("другого постачальника" in "${TEST_NAME}") and ("${mode}" in "${mode_list}")       ${award_num}-1
	...  ("третього постачальника" in "${TEST_NAME}") and ("${mode}" in "${mode_list}")      ${award_num}-1
	...  ("третього постачальника" in "${TEST_NAME}") and ("esco" in "${mode}")              ${award_num}-2
	...  ("четвертого постачальника" in "${TEST_NAME}") and ("${mode}" in "${mode_list}")    ${award_num}-1
    ...  ${award_num}
    [Return]  ${award_num}


_закарити сповіщення про кваліфікацію за необхідністю
	${notice_visible}  run keyword and return status  dialog box заголовок повинен містити  Увага!
	run keyword if  ${notice_visible}
		...  screen натиснути кнопку  ОК


Скасування рішення кваліфікаційної комісії
    [Arguments]  ${username}  ${tender_uaid}  ${award_num}
    [Documentation]  Перевести постачальника під номером award_num для тендера tender_uaid в статус cancelled.
	log to console  Скасування рішення кваліфікаційної комісії
	знайти тендер у webclient  ${tender_uaid}
	${tab_status}  run keyword and return status  активувати вкладку  Пропозиції
	run keyword if  '${tab_status}' == 'False'    активувати вкладку  Предложения
	header натиснути на елемент за назвою  Оновити
	вибрати переможця за номером  ${award_num}+1
	header натиснути на елемент за назвою  Кваліфікація
	smarttender._закарити сповіщення про кваліфікацію за необхідністю
    header натиснути на елемент за назвою  Скасувати прийняте рішення
    dialog box заголовок повинен містити  Увага! Після натискання кнопки «Скасувати прийняте рішення»
	dialog box натиснути кнопку  Так


Затвердити постачальників
     [Arguments]  ${username}  ${tender_uaid}
     [Documentation]  Завершити розгляд учасників "Рамкова угода 1-й етап" (всі учасники мають бути переможцями)
     smarttender.Затвердити остаточне рішення кваліфікації  ${username}  ${tender_uaid}


Редагувати угоду
    [Arguments]  ${username}  ${tender_uaid}  ${contract_index}  ${fieldname}  ${fieldvalue}
    [Documentation]  Змінює поле fieldname угоди тендера tender_uaid на fieldvalue
    comment  заполняем поля в кейворде Підтвердити підписання контракту continue
    run keyword if  '${fieldname}' == 'value.amountNet'  set global variable  ${contract value.amountNet}  ${fieldvalue}
    run keyword if  '${fieldname}' == 'value.amount'     set global variable  ${contract value.amount}     ${fieldvalue}


Встановити дату підписання угоди
    [Arguments]  ${username}  ${tender_uaid}  ${contract_index}  ${fieldvalue}
    [Documentation]  Встановлює дату підписання угоди тендера tender_uaid на fieldvalue
	log to console  Встановити дату підписання угоди


Вказати період дії угоди
    [Arguments]  ${username}  ${tender_uaid}  ${contract_index}  ${startDate}  ${endDate}
    [Documentation]  Встановлює період дії угоди тендера tender_uaid на startDate і endDate
	log to console  Вказати період дії угоди


Завантажити документ в угоду
    [Arguments]  ${username}  ${path}  ${tender_uaid}  ${contract_index}  ${doc_type}=${Empty}
    [Documentation]  Завантажити документ, який знаходиться по шляху path, до контракту contract_index з вказанням типу doc_type
	log to console  Завантажити документ в угоду


Підтвердити підписання контракту
    [Arguments]  ${username}  ${tender_uaid}  ${award_num}
    [Documentation]  Перевести договір під номером contract_num до тендера tender_uaid в статус active.
    ${ignore_TK}  set variable  Неможливість укласти угоду для переговорної процедури поки не пройде stand-still період
    #run keyword if  "${mode}" != "reporting" and "${ignore_TK}" != "${TEST_NAME}"  sleep  8m

    comment  из-за неправильного нэйминга теста, меняем индекс award согласно условия (действия должні віполянться для первого аварда https://prozorro.slack.com/archives/GRGH6Q8SG/p1579085479005400)
	${mode_list}  create list  openua  openeu  open_competitive_dialogue
	${award_num}  set variable if
	...  ("Можливість укласти угоду для закупівлі" in "${TEST_NAME}") and ("${mode}" in "${mode_list}")  ${award_num}-1
	...  "esco" in "${mode}"  0

    smarttender.Підтвердити підписання контракту continue  ${username}  ${tender_uaid}  ${award_num}


Підтвердити підписання контракту continue
    [Arguments]  ${username}  ${tender_uaid}  ${contract_num}
    Відкрити вікно прикріплення договору  ${contract_num}  ${tender_uaid}
    #  Заповнюємо поля договору
	${id}  evaluate  str(uuid.uuid4())  uuid
	заповнити поле для угоди id  ${id}
	${date}  get current date  result_format=%d.%m.%Y
	${date_to}  get current date
	${date_to}  Add Time To Date  ${date_to}  30 days  result_format=%d.%m.%Y
	заповнити поле для угоди date  ${date}
	заповнити поле для угоди date from  ${date}
	заповнити поле для угоди date to    ${date_to}

    ${global_amount}     run keyword and return status  Variable Should Exist  ${contract value.amount}
    run keyword if  ${global_amount}  заповнити поле для угоди value.amount     ${contract value.amount}

	${global_amountNet}  run keyword and return status  Variable Should Exist  ${contract value.amountNet}
	run keyword if  ${global_amountNet}  run keywords
	...  операція над чекбоксом  ${True}  xpath=//*[@data-type="CheckBox"]//input
	...  AND
	...  заповнити поле для угоди value.amountNet  ${contract value.amountNet}
    ...  ELSE  вказати суму без ПДВ залежно від чек-боксу (тендер з ПДВ чи без)

	#  Додаємо документ
	screen натиснути кнопку  Перегляд...
	${list_of_file_args}  create_fake_doc
	${file_path}  set variable  ${list_of_file_args[0]}
	загрузити документ  ${file_path}
	header натиснути на елемент за назвою  OK
	webclient.screen заголовок повинен містити  Завантаження документації
	click element   ${screen_root_selector}//*[@alt="Close"]
	loading дочекатись закінчення загрузки сторінки

	header натиснути на елемент за назвою  Підписати договір
	dialog box заголовок повинен містити  Ви дійсно хочете підписати договір?
	dialog box натиснути кнопку  Так
	Підписати ЕЦП(webclient)


вказати суму без ПДВ залежно від чек-боксу (тендер з ПДВ чи без)
    ${amount}            get element attribute  xpath=(//*[@data-type="SpinEdit"]//input)[1]@value
    ${amount}            evaluate  '${amount}'.replace(' ', '')
    ${amount minus 20%}  evaluate  "%.2f" % (${amount} / 1.2)
    ${checkbox}         set variable  //*[@data-type="CheckBox" and contains(., "з ПДВ")]
	${checkbox status}  get element attribute  ${checkbox}//span  class
	${amount without tax}  set variable if
	...  "Unchecked" in "${checkbox status}"  ${amount}
	...  "Checked" in "${checkbox status}"    ${amount minus 20%}
    заповнити поле для угоди value.amountNet  ${amount without tax}


Перевести тендер на статус очікування обробки мостом
    [Arguments]  ${username}  ${tender_uaid}
    [Documentation]  Перевести тендер tender_uaid в статус active.stage2.waiting.
	comment  Ждем пока пройдет период обжалования
	знайти тендер у webclient  ${tender_uaid}
    Wait Until Keyword Succeeds  6m  30s  smarttender.Перейти до другої фази


Перейти до другої фази
    smarttender._надіслати вперед для отримання повідомлення
    dialog box заголовок повинен містити  Перейти до другої фази?
	dialog box натиснути кнопку  Так


Отримати тендер другого етапу та зберегти його
    [Arguments]  ${username}  ${tender_id}
    [Documentation]  Отримати доступ до тендера другого етапу по tender id.
	log to console  Отримати тендер другого етапу та зберегти його
	${location}  get location
    run keyword if  "webclient" not in "${location}"  знайти тендер у webclient  ${tender_id}


Активувати другий етап
	[Arguments]  ${username}  ${tender_uaid}
    [Documentation]  Перевести тендер tender_uaid в статус active.tendering
	log to console  Активувати другий етап
	smarttender._надіслати вперед для отримання повідомлення
    dialog box заголовок повинен містити  Опублікувати процедуру?
	dialog box натиснути кнопку  Так
	dialog box заголовок повинен містити  Накласти ЕЦП/КЕП на тендер?
	dialog box натиснути кнопку  Ні


Дискваліфікувати постачальника
    [Arguments]  ${username}  ${tender_uaid}  ${award_num}
    [Documentation]  Перевести постачальника під номером award_num для тендера tender_uaid в статус unsuccessful.
	return from keyword if  "esco" in "${mode}"
	знайти тендер у webclient  ${tender_uaid}
	${tab_status}  run keyword and return status  активувати вкладку  Пропозиції
	run keyword if  '${tab_status}' == 'False'    активувати вкладку  Предложения
	header натиснути на елемент за назвою  Оновити
	#TODO убрать условие       ${award_num}  set variable if  "esco" in "${mode}"  ${award_num}-1  ${award_num}
    вибрати переможця за номером  ${award_num}+1
    header натиснути на елемент за назвою  Кваліфікація
	smarttender._закарити сповіщення про кваліфікацію за необхідністю
	click element  //*[contains(text(), "Відхилити пропозицію")]
	loading дочекатись закінчення загрузки сторінки
	Заповнити текст рішення квалиіфікації  Загрузка документа без кваліфікації учасника
	${checkbox_1}  set variable  xpath=//td[contains(text(),"Не відповідає кваліфікаційним критеріям")]/preceding-sibling::td[1]
    click element  ${checkbox_1}

    screen натиснути кнопку  Перегляд...
	${list_of_file_args}  create_fake_doc
	${file_path}  set variable  ${list_of_file_args[0]}
	загрузити документ  ${file_path}

	${is_visible_save_btn}  run keyword and return status   header натиснути на елемент за назвою  Зберегти
	run keyword if  "${is_visible_save_btn}" == "${False}"  header натиснути на елемент за назвою  Продовжити кваліфікацію
	dialog box заголовок повинен містити  Ви впевнені у своєму рішенні?
	dialog box натиснути кнопку  Так
	Підписати ЕЦП(webclient)


Створити постачальника, додати документацію і підтвердити його
    [Arguments]  ${username}  ${tender_uaid}  ${supplier_data}  ${document}
    [Documentation]  Додати постачальника supplier_data для тендера tender_uaid, додати до нього документ, який знаходиться по шляху document та перевести в статус active.
	header натиснути на елемент за назвою  Додати учасника

	${identifier.id}  set variable  ${supplier_data['data']['suppliers'][0]['identifier']['id']}
	${identifier.legalName}  set variable  ${supplier_data['data']['suppliers'][0]['identifier']['legalName']}
	${scale}  set variable  ${supplier_data['data']['suppliers'][0]['scale']}
	${contactPoint.name}  set variable  ${supplier_data['data']['suppliers'][0]['contactPoint']['name']}
	${contactPoint.telephone}  set variable  ${supplier_data['data']['suppliers'][0]['contactPoint']['telephone']}
	${contactPoint.email}  set variable  ${supplier_data['data']['suppliers'][0]['contactPoint']['email']}
	${contactPoint.url}  set variable  ${supplier_data['data']['suppliers'][0]['contactPoint']['url']}
	${address.postalCode}  set variable  ${supplier_data['data']['suppliers'][0]['address']['postalCode']}
	${address.streetAddress}  set variable  ${supplier_data['data']['suppliers'][0]['address']['streetAddress']}
	${address.locality}  set variable  ${supplier_data['data']['suppliers'][0]['address']['locality']}
	${value.amount}  set variable  ${supplier_data['data']['value']['amount']}
	${value.valueAddedTaxIncluded}  set variable  ${supplier_data['data']['value']['valueAddedTaxIncluded']}

	${qualified}  set variable  ${supplier_data['data']['qualified']}
	${qualified_checkbox}  set variable if  ${qualified}  //*[@data-name="qualified"]//input  //*[@data-name="nonQualified"]//input
    ${qualified_decision}  set variable if  ${qualified}  Визнати учасника переможцем         Визначити учасником переговорів
	&{scale_dict}  create dictionary
	...  micro=Суб'єкт мікропідприємництва
	...  sme=Суб'єкт малого підприємництва
	...  large=Суб'єкт великого підприємництва
	...  mid=Суб'єкт середнього підприємництва
	...  not specified=Не субъект предпринимательства

    # todo написать отдельный ввод для этого поля если еще раз упадет
	заповнити simple input  //*[@data-name="AMOUNT"]//input  ${value.amount}  check=${False}
	заповнити simple input  //*[@data-name="OKPO"]//input  ${identifier.id}
	заповнити simple input  //*[@data-name="NORG_DOC"]//input  ${identifier.legalName}
	заповнити autocomplete field  //*[@data-name="IDSCALE"]//input  ${scale_dict['${scale}']}  action_after_input=press_key
	заповнити simple input  //*[@data-name="CONTACTPERSON"]//input  ${contactPoint.name}
    заповнити simple input  //*[@data-name="TEL"]//input  ${contactPoint.telephone}${space}${space}${space}  input_methon=Input Type Flex
	заповнити simple input  //*[@data-name="EMAIL"]//input  ${contactPoint.email}    check=${False}
	заповнити simple input  //*[@data-name="URL"]//input  ${contactPoint.url}
	заповнити simple input  //*[@data-name="PIND"]//input  ${address.postalCode}
	заповнити simple input  //*[@data-name="APOTR"]//input  ${address.streetAddress}
	заповнити autocomplete field  //*[@data-name="CITY_KOD"]//input  ${address.locality}  ${False}  action_after_input=press_key
	операція над чекбоксом  ${value.valueAddedTaxIncluded}  //*[@data-name="WITHVAT"]//input

    log to console  Створити постачальника, додати документацію і підтверди

	webclient.header натиснути на елемент за назвою  OK

	run keyword if  "${mode}" == "negotiation"  run keywords
	...  click element  //*[@data-name]//*[contains(text(), 'Перегляд...')]     AND
	...  loading дочекатись закінчення загрузки сторінки                        AND
	...  загрузити документ  ${document}                                        AND
    ...  заповнити simple input  //*[@data-name="decision"]//textarea  Кваліфікація. Визнати учасника переможцем  AND
    ...  операція над чекбоксом  ${True}  ${qualified_checkbox}                 AND
    ...  click element  //*[@data-name="chooseDecision"]                        AND
    ...  wait until keyword succeeds  10  1  click element  //span[text()="${qualified_decision}"]

    ...  ELSE  run keywords

	...  dialog box заголовок повинен містити  Увага!       AND
	...  dialog box натиснути кнопку  Так                   AND
	...  click element  //*[@data-name]//*[contains(text(), 'Перегляд...')]     AND
	...  loading дочекатись закінчення загрузки сторінки                        AND
	...  загрузити документ  ${document}                                        AND
	...  заповнити simple input  //*[@data-name="decision"]//textarea  Кваліфікація. Визнати учасника переможцем  AND
	...  webclient.header натиснути на елемент за назвою  Визнати учасника переможцем

	wait until keyword succeeds  10  1  dialog box заголовок повинен містити  Увага!
	# текст в диалоговом окне - Після прийняття рішення, коригувати дані про учасника буде неможливо. Ви впевнені у своєму виборі?
	dialog box натиснути кнопку  Так
	${status}  run keyword and return status  Підписати ЕЦП(webclient)
	run keyword if  ${status}
	...  log  ЕЦП накладено  WARN
	...  ELSE
	...  log  ЕЦП НЕ накладено WARN


Створити план
    [Arguments]  ${username}  ${tender_data}
    [Documentation]  Створити план з початковими даними tender_data. Повернути uaid створеного плану.
	${tender_data}  get from dictionary  ${tender_data}  data
    smart go to  https://test.smarttender.biz/plan/add/test/
    loading дочекатися відображення елемента на сторінці  //h1[.="Створення плану закупівлі"]

	${procurementMethodType_en}  			set variable  					${tender_data['tender']['procurementMethodType']}
	${procurementMethodType}  				get_en_procurement_method_type  ${procurementMethodType_en}
	${tenderPeriod_startDate_not_formated}  set variable  					${tender_data['tender']['tenderPeriod']['startDate']}
	${tender_start}          convert date  	${tenderPeriod_startDate_not_formated}  result_format=%Y  date_format=%Y-%m-%dT%H:%M:%S+02:00
	${plan_strat}            convert date  	${tenderPeriod_startDate_not_formated}  result_format=%m.%Y  date_format=%Y-%m-%dT%H:%M:%S+02:00
	${budget_description}  					set variable  					${tender_data['budget']['description']}
	${budget_amount}  						convert_float_to_string         ${tender_data['budget']['amount']}
	${budget_id}  							set variable  					${tender_data['classification']['id']}
	${additionalClassifications_status}  	${additionalClassifications}  	run keyword and ignore error  set variable  ${tender_data['additionalClassifications']}
    plan edit обрати "Тип процедури закупівлі"                                  ${procurementMethodType}
	plan edit заповнити "Рік"                                                   ${tender_start}
	run keyword if  'Framework' in '${mode}'
	...  plan edit заповнити "Рік по"                                           ${tender_start}
	plan edit заповнити "Дата старту закупівлі"                                 ${plan_strat}
	plan edit заповнити "Конкретна назва предмету закупівлі"                    ${budget_description}
    plan edit заповнити "Очікувана вартість закупівлі"                          ${budget_amount}
    plan edit обрати "Замовник"  index=1
    plan edit обрати "Код ДК021"                                                ${budget_id}

    run keyword if  '${additionalClassifications_status}' == 'PASS'
    ...  plan edit Додати доп. класифікацію  ${additionalClassifications}

    comment  Джерело фінансування
    ${i}  set variable  0
    :FOR  ${breakdown}  IN  @{tender_data['budget']['breakdown']}
    \  ${i}  evaluate  ${i} + 1
    \  plan edit натиснути Додати в блоці Джерело фінансування
    \  plan edit breakdown додати "Джерело фінансування"  ${breakdown}  ${i}

    comment  додати номенклатуру
    ${i}  set variable  0
    :FOR  ${item}  IN  @{tender_data['items']}
    \  ${i}  evaluate  ${i} + 1
    \  plan edit натиснути Додати в блоці Номенклатури
    \  plan edit додати номенклатуру  ${item}  ${i}

    plan edit натиснути Зберегти
    plan edit Опублікувати план
    ${planID}  smarttender.план_сторінка_детальної_інформації отримати planID  planID
    [Return]  ${planID}


Внести зміни в план
	[Arguments]  ${username}  ${tender_uaid}  ${field_name}  ${value}
    button type=button click by text  Коригувати план
	run keyword if
	...  "${field_name}" == "budget.description"  plan edit заповнити "Конкретна назва предмету закупівлі"  ${value}  ELSE IF
	...  "${field_name}" == "budget.amount"       plan edit заповнити "Очікувана вартість закупівлі"        ${value}  ELSE IF
	...  "${field_name}" == "budget.period"       no operation                                                        ELSE IF
	...  "${field_name}" == "items[0].quantity"   plan edit заповнити "Кількість"                           ${value}  index=1
    plan edit натиснути Зберегти


Додати предмет закупівлі в план
 	[Arguments]  ${username}  ${tender_uaid}  ${item}
	button type=button click by text  Коригувати план
    plan edit натиснути Додати в блоці Номенклатури
    ${items_count}  Get Matching Xpath Count  ${plan_item_title_input}
    plan edit додати номенклатуру  ${item}  field_number=${items_count}
    plan edit натиснути Зберегти


Пошук плану по ідентифікатору
    [Arguments]  ${username}  ${planID}
    [Documentation]  Знайти план з uaid рівним tender_uaid.
	smarttender.перейти до сторінки планів  ${username}  ${planID}
	smarttender.сторінка_планів ввести текст в поле пошуку  ${planID}
    smarttender.сторінка_планів виконати пошук
	smarttender.сторінка_планів перейти за першим результатом пошуку
	${taken_planID}  smarttender.план_сторінка_детальної_інформації отримати planID  planID
	should be equal as strings  ${taken_planID}  ${planID}


перейти до сторінки планів
	[Arguments]  ${username}  ${planID}
    smart go to  https://test.smarttender.biz/plans/?q&tm=2&p=1&af&at
    loading дочекатись закінчення загрузки сторінки
    # Зачекати поки план засинхронізується
	wait until keyword succeeds  5m  5s  smarttender._дочекатися синхронізації плану  ${planID}


_дочекатися синхронізації плану
	[Arguments]   ${planID}
	${planID_status}  evaluate  requests.get("https://test.smarttender.biz/plans/details/${planID}/").status_code   requests
	should be equal as integers  ${planID_status}  200


Отримати інформацію із плану
    [Arguments]  ${username}  ${plan_uaid}  ${field_name}
    [Documentation]  Отримати значення поля field_name для плану plan_uaid.
    comment  Повертаємося на сторінку детальної інформації по плану якщо ми не на ній
    ${current_location}  get location
    run keyword if  "${plan_detail_page}" != "${current_location}"  smart go to  ${plan_detail_page}
    #####################################
	${field_name_splited}  set variable  ${field_name.split('[')[0]}
    ${field_value}  run keyword  smarttender.план_сторінка_детальної_інформації отримати ${field_name_splited}  ${field_name}
    [Return]  ${field_value}


Видалити предмет закупівлі плану
    [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${lot_id}=${Empty}
    [Documentation]  Видалити з плану tender_uaid предмет з item_id в описі (предмет може бути прив'язаним до лоту з lot_id в описі, якщо lot_id != Empty).
	button type=button click by text  Коригувати план
	${count}  get Matching Xpath Count  xpath=(${plan_item_title_input})
	:FOR  ${i}  IN RANGE  1  ${count}+1
    \  ${value}  get element attribute  xpath=(${plan_item_title_input})[${i}]@value
    \  ${index}  set variable if  "${item_id}" in """${value}"""  ${i}
    \  exit for loop if           "${item_id}" in """${value}"""
    button class=button click by text  Видалити  count=${index}  root_xpath=//div[@class="nomenclatures-section"]
    plan edit натиснути Зберегти


Оновити сторінку з планом
    [Arguments]   ${username}  ${plan_uaid}
    [Documentation]   Оновити сторінку з тендером для отримання потенційно оновлених даних.
    smarttender.Оновити сторінку з тендером  ${username}  ${plan_uaid}


########################################################################################################
########################################################################################################
сторінка_планів ввести текст в поле пошуку
    [Arguments]  ${text}
    input text  //*[@data-qa="search-block-input"]  ${text}


сторінка_планів виконати пошук
    click element  //*[@data-qa="search-block-button"]
    loading дочекатись закінчення загрузки сторінки
    ${location}  get location
    log  ${location}


сторінка_планів перейти за першим результатом пошуку
	${plan_number}  set variable  1
	${link}  get element attribute  xpath=(//*[@id="plan"])[${plan_number}]//*[@data-qa="plan-title"]@href
	log  plan_link: ${link}  WARN
	set global variable  ${plan_detail_page}  ${link}
	smart go to  ${link}


план_сторінка_детальної_інформації отримати status
    [Arguments]  ${field_name}
    ${selector}  set variable  xpath=//*[@data-qa="plan-status"]
	${field_value}  get text  ${selector}
	${field_value}  convert_plan_status  ${field_value}
	[Return]  ${field_value}


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
    debug
	[Return]  ${field_value}


план_сторінка_детальної_інформації отримати budget.project.id
    [Arguments]  ${field_name}
    log to console  Поле не отображается на странице
    debug
	[Return]  ${field_value}


план_сторінка_детальної_інформації отримати budget.project.name
    [Arguments]  ${field_name}
    log to console  Поле не отображается на странице
    debug
	[Return]  ${field_value}


план_сторінка_детальної_інформації отримати procuringEntity.name
    [Arguments]  ${field_name}
    ${selector}  set variable  xpath=(//*[@data-qa="plan-organizer"]|//*[@data-qa="plan-purchaser"])[last()]//*[@data-qa="value"]
	${field_value}  get text  ${selector}
	[Return]  ${field_value}


план_сторінка_детальної_інформації отримати procuringEntity.identifier.scheme
    [Arguments]  ${field_name}
    ${selector}  set variable  xpath=(//*[@data-qa="plan-usreou"]|//*[@data-qa="plan-purchaser-usreou"])[last()]//*[@data-qa="key"]
	${field_value_in_smart_format}  get text  ${selector}
	${field_value}  set variable if  "${field_value_in_smart_format}" == "Код ЄДРПОУ"  UA-EDR  ERROR!
	[Return]  ${field_value}


план_сторінка_детальної_інформації отримати procuringEntity.identifier.id
    [Arguments]  ${field_name}
    ${selector}  set variable  xpath=(//*[@data-qa="plan-usreou"]|//*[@data-qa="plan-purchaser-usreou"])[last()]//*[@data-qa="value"]
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
	${selector}  set variable  //*[@data-qa="plan-date-publish"]
	${field_value_in_smart_format}  get text  ${selector}
	${field_value}  convert date  ${field_value_in_smart_format}  date_format=%d.%m.%Y %H:%M  result_format=%Y-%m-%dT00:00:00${time_zone}
	[Return]  ${field_value}


план_сторінка_детальної_інформації отримати items
	[Arguments]  ${field_name}
	${reg}  evaluate  re.search(r'.*\\[(?P<number>\\d)\\]\\.(?P<field>.*)', '${field_name}')  re
	${item_number_in_cdb}  	evaluate  '${reg.group('number')}'
	${field}  	evaluate  '${reg.group('field')}'
	${item_selector}  smarttender._план_сторінка_детальної_інформації отримати selector для items  ${item_number_in_cdb}
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
    [Return]  ${converted_field_value}


_план_сторінка_детальної_інформації отримати selector для items
	[Arguments]  ${item_number_in_cdb}
	${plan_cdb_id}  get text  //*[@data-qa="plan-id-cdb"]
	${cdb_data}  evaluate  requests.get("https://lb-api-staging.prozorro.gov.ua/api/2.5/plans/${plan_cdb_id}").json()  requests
	${cdb_item_description}  set variable  ${cdb_data['data']['items'][${item_number_in_cdb}]['description']}
	${item_selector}  set variable  xpath=//*[@data-qa="value-list"][contains(., "${cdb_item_description}")]
	[Return]  ${item_selector}


сторінка_детальної_інформації отримати agreements
	[Arguments]  ${field_name}
	${field_value}  run keyword  сторінка_детальної_інформації отримати ${field_name}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати agreements[${agreement_index}].status
	${field_locator}  set variable  //*[@data-qa="agreement-status"]//*[@data-qa="value"]
	${field_value_in_smart_format}  get text  ${field_locator}
	${field_value}  set variable if
		...  "${field_value_in_smart_format}" == "Укладена рамкова угода"  active
		...  Error!
	[Return]  ${field_value}


сторінка_детальної_інформації отримати agreements[${agreement_index}].agreementID
    return from keyword if  "framework_selection" == "${mode}"  ${agreement_cdb_number}
	${field_locator}  set variable  //*[@data-qa="agreement-cdb-number"]//*[@data-qa="value"]
	${field_value}  get text  ${field_locator}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати awards
	[Arguments]  ${field_name}
	# розгорунти блок, якщо потрібно
	smarttender.розгорнути всі експандери
    # отримати дані
	${field_value}  run keyword  сторінка_детальної_інформації отримати ${field_name}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати awards[${award_index}].complaintPeriod.endDate
	sleep  8m
	Синхронізувати тендер
	${href}  run keyword if  "${mode}" == "openua_defense"
		...  _отримати посилання на сторінку оскарження openua_defense
	...  ELSE
		...  smarttender._отримати посилання на сторінку оскарження  ${award_index}
	go to  ${href}
	loading дочекатись закінчення загрузки сторінки
	${selector}  set variable  //*[@data-qa="period"]/p
    ${get}  get text  ${selector}
	${get_reg}  evaluate  re.findall(ur'\\d{2}.\\d{2}.\\d{4} \\d{2}:\\d{2}', u'${get}')  re
	${value}  convert date  ${get_reg[1]}  date_format=%d.%m.%Y %H:%M  result_format=%Y-%m-%dT%H:%M:%S${time_zone}
	go back
	loading дочекатись закінчення загрузки сторінки
	[Return]  ${value}


_отримати посилання на сторінку оскарження
	[Arguments]  ${award_index}
	${href}  get element attribute  xpath=(//*[@data-qa="complaint-button"])[${award_index}+1]@href
	return from keyword if  ${href.__len__()} != 0  ${href}
	${href}  get element attribute  xpath=(//*[@data-qa="complaint-button"])[${award_index}]@href
	[Return]  ${href}


_отримати посилання на сторінку оскарження openua_defense
	${href}  get element attribute  xpath=//*[@data-qa="complaint-button" and @class="complaint-button"]@href
	[Return]  ${href}


сторінка_детальної_інформації отримати maxAwardsCount
	[Arguments]  ${field_name}
    ${selector}  set variable  //*[@data-qa="max-winner-count"]//*[@data-qa="value"]
	${field_value}  get text  ${selector}
	${field_value}  convert to integer  ${field_value}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати agreementDuration
	[Arguments]  ${field_name}
    ${selector}  set variable  //*[@data-qa="agreement-duration"]/div[@class="second ivu-col ivu-col-span-xs-24 ivu-col-span-sm-15"]
	${value}  get text  ${selector}
	${reg}  evaluate  re.search(u'(?P<years>[0-9]+).+(?P<months>[0-9]+).+(?P<days>[0-9]+)', u"""${value}""")  re
	${field_value}  set variable  P${reg.group('years')}Y${reg.group('months')}M${reg.group('days')}D
	[Return]  ${field_value}


сторінка_детальної_інформації отримати awards[${award_index}].documents[${document_index}].title
	${selector}  set variable  xpath=((//*[@data-qa="qualification-info"])[${award_index} + 1]/ancestor::*[@class="ivu-card-body"]//*[@data-qa="file-name"])[${document_index} + 1]
	${field_value}  get text  ${selector}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати awards[${award_index}].status
	${selector}  set variable  xpath=(//*[@data-qa="qualification-info"])[${award_index} + 1]/ancestor::*[@class="ivu-card-body"]//div[text()='Статус']/following-sibling::*
    ${field_value_in_smart_format}  get text  ${selector}
	${field_value}  convert_award_status  ${field_value_in_smart_format}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати awards[${award_index}].value.amount
	${selector}  set variable  (//*[@data-qa="qualification-info"])[${award_index} + 1]/ancestor::*[@class="ivu-card-body"]//div[contains(text(),'Сума пропозиції')]/following-sibling::*
    ${field_value_in_smart_format}  get text  xpath=${selector}
    ${field_value}  convert_page_values  value.amount  ${field_value_in_smart_format}
    [Return]  ${field_value}


сторінка_детальної_інформації отримати awards[${award_index}].value.valueAddedTaxIncluded
	${selector}  set variable  (//*[@data-qa="qualification-info"])[${award_index} + 1]/ancestor::*[@class="ivu-card-body"]//div[contains(text(),'Сума пропозиції')]/following-sibling::*
    ${field_value_in_smart_format}  get text  xpath=${selector}
    ${field_value}  convert_page_values  value.valueAddedTaxIncluded  ${field_value_in_smart_format}
    [Return]  ${field_value}


сторінка_детальної_інформації отримати awards[${award_index}].value.currency
    ${selector}  set variable  //*[@id="auction_results"]//*[@data-qa="captions"]//*[@class="ivu-col ivu-col-span-sm-4"]
    ${value}  get text  ${selector}
	${field_value_in_smart_format}  fetch from right  ${value}  ${space}
	${field_value}  set variable if  "${field_value_in_smart_format}" == "грн."  UAH  ERROR!
    [Return]  ${field_value}


сторінка_детальної_інформації отримати awards[${award_index}].suppliers[${supplier_index}].address.countryName
    ${selector}  set variable  (//*[@data-qa="qualification-info"])[${award_index} + 1]/ancestor::*[@class="ivu-card-body"]//*[text()="Адреса"]/parent::*/following-sibling::*
    ${address}  get text  xpath=${selector}
    ${reg}  evaluate  re.search(u'^(?P<postalCode>[0-9]+), (?P<countryName>[^,]+), (?P<region>[^,]+), (?P<locality>[^,]+), (?P<streetAddress>.+)', u"""${address}""")  re
	${field_value}  set variable  ${reg.group('countryName')}
    [Return]  ${field_value}


сторінка_детальної_інформації отримати awards[${award_index}].suppliers[${supplier_index}].address.locality
    ${selector}  set variable  (//*[@data-qa="qualification-info"])[${award_index} + 1]/ancestor::*[@class="ivu-card-body"]//*[text()="Адреса"]/parent::*/following-sibling::*
    ${address}  get text  xpath=${selector}
    ${reg}  evaluate  re.search(u'^(?P<postalCode>[0-9]+), (?P<countryName>[^,]+), (?P<region>[^,]+), (?P<locality>[^,]+), (?P<streetAddress>.+)', u"""${address}""")  re
	${field_value}  set variable  ${reg.group('locality')}
    [Return]  ${field_value}


сторінка_детальної_інформації отримати awards[${award_index}].suppliers[${supplier_index}].address.postalCode
    ${selector}  set variable  (//*[@data-qa="qualification-info"])[${award_index} + 1]/ancestor::*[@class="ivu-card-body"]//*[text()="Адреса"]/parent::*/following-sibling::*
    ${address}  get text  xpath=${selector}
    ${reg}  evaluate  re.search(u'^(?P<postalCode>[0-9]+), (?P<countryName>[^,]+), (?P<region>[^,]+), (?P<locality>[^,]+), (?P<streetAddress>.+)', u"""${address}""")  re
	${field_value}  set variable  ${reg.group('postalCode')}
    [Return]  ${field_value}


сторінка_детальної_інформації отримати awards[${award_index}].suppliers[${supplier_index}].address.region
    ${selector}  set variable  (//*[@data-qa="qualification-info"])[${award_index} + 1]/ancestor::*[@class="ivu-card-body"]//*[text()="Адреса"]/parent::*/following-sibling::*
    ${address}  get text  xpath=${selector}
    ${reg}  evaluate  re.search(u'^(?P<postalCode>[0-9]+), (?P<countryName>[^,]+), (?P<region>[^,]+), (?P<locality>[^,]+), (?P<streetAddress>.+)', u"""${address}""")  re
	${field_value}  set variable  ${reg.group('region')}
	${field_value}  set variable  ${field_value.replace(u"обл.", u"область")}
    [Return]  ${field_value}


сторінка_детальної_інформації отримати awards[${award_index}].suppliers[${supplier_index}].address.streetAddress
    ${selector}  set variable  (//*[@data-qa="qualification-info"])[${award_index} + 1]/ancestor::*[@class="ivu-card-body"]//*[text()="Адреса"]/parent::*/following-sibling::*
    ${address}  get text  xpath=${selector}
    ${reg}  evaluate  re.search(u'^(?P<postalCode>[0-9]+), (?P<countryName>[^,]+), (?P<region>[^,]+), (?P<locality>[^,]+), (?P<streetAddress>.+)', u"""${address}""")  re
	${field_value}  set variable  ${reg.group('streetAddress')}
    [Return]  ${field_value}


сторінка_детальної_інформації отримати awards[${award_index}].suppliers[${supplier_index}].contactPoint.telephone
    ${selector}  set variable  (//*[@data-qa="qualification-info"])[${award_index} + 1]/ancestor::*[@class="ivu-card-body"]//*[text()="Телефон"]/parent::*/following-sibling::*
    ${field_value}  get text  xpath=${selector}
    [Return]  ${field_value}


сторінка_детальної_інформації отримати awards[${award_index}].suppliers[${supplier_index}].contactPoint.name
    ${selector}  set variable  (//*[@data-qa="qualification-info"])[${award_index} + 1]/ancestor::*[@class="ivu-card-body"]//*[text()="ПІБ"]/parent::*/following-sibling::*
    ${field_value}  get text  xpath=${selector}
    [Return]  ${field_value}


сторінка_детальної_інформації отримати awards[${award_index}].suppliers[${supplier_index}].contactPoint.email
    ${selector}  set variable  (//*[@data-qa="qualification-info"])[${award_index} + 1]/ancestor::*[@class="ivu-card-body"]//*[text()="Email"]/parent::*/following-sibling::*
    ${field_value}  get text  xpath=${selector}
    [Return]  ${field_value}


сторінка_детальної_інформації отримати awards[${award_index}].suppliers[${supplier_index}].identifier.scheme
    ${selector}  set variable  (//*[@data-qa="qualification-info"])[${award_index} + 1]/ancestor::*[@class="ivu-card-body"]//*[text()="Код ЄДРПОУ"]
    ${field_value_in_smart_format}  get text  xpath=${selector}
    ${field_value}  set variable if  "${field_value_in_smart_format}" == "Код ЄДРПОУ"  UA-EDR  ERROR
    [Return]  ${field_value}


сторінка_детальної_інформації отримати awards[${award_index}].suppliers[${supplier_index}].identifier.legalName
    ${selector}  set variable  (//*[@data-qa="qualification-info"])[${award_index} + 1]//*[@class="expander-title"]
    ${field_value}  get text  xpath=${selector}
    [Return]  ${field_value}


сторінка_детальної_інформації отримати awards[${award_index}].suppliers[${supplier_index}].identifier.id
    ${selector}  set variable  (//*[@data-qa="qualification-info"])[${award_index} + 1]/ancestor::*[@class="ivu-card-body"]//*[text()="Код ЄДРПОУ"]/parent::*/following-sibling::*
    ${field_value}  get text  xpath=${selector}
    [Return]  ${field_value}


сторінка_детальної_інформації отримати awards[${award_index}].suppliers[${supplier_index}].name
    ${selector}  set variable  (//*[@data-qa="qualification-info"])[${award_index} + 1]//*[@class="expander-title"]
    ${field_value}  get text  xpath=${selector}
    [Return]  ${field_value}


сторінка_детальної_інформації отримати contracts
    [Arguments]  ${field_name}
	log  ${field_name}
    ${field_value}  run keyword  smarttender.сторінка_детальної_інформації отримати ${field_name}
	[Return]  ${field_value}


сторінка_детальної_інформації отримати contracts[${contract_index}].status
	${field_value}  run keyword if  "${mode}" == "open_esco"
		...  сторінка_детальної_інформації отримати contracts[${contract_index}].status open_esco
	...  ELSE
		...  сторінка_детальної_інформації отримати contracts[${contract_index}].status default
	[Return]  ${field_value}


сторінка_детальної_інформації отримати contracts[${contract_index}].status open_esco
	Синхронізувати тендер
	${down_arrow_selector}  set variable  xpath=(//*[@data-qa="qualification-info"])[${contract_index} + 1]//*[contains(@class,"expander")]/i[contains(@class,"down")]
	loading дочекатися відображення елемента на сторінці  ${down_arrow_selector}
	click element  ${down_arrow_selector}
	loading дочекатись закінчення загрузки сторінки
	${contract_field_selector}  set variable  xpath=//*[@data-qa="qualification-expanded-info"]//*[@class="ivu-row" and contains(., "Договір")]
    ${contract_status}  run keyword and return status  element should be visible  ${contract_field_selector}
	${field_value}  set variable if
		...  ${contract_status}  active
		...  pending
	[Return]  ${field_value}


сторінка_детальної_інформації отримати contracts[${contract_index}].status default
	${have_contract}  run keyword and return status  wait until keyword succeeds  15m  1s  smarttender._дочекатися відображення посилання на договір
	return from keyword if  ${have_contract} == ${False}  pending
	###########################################
	open button  //*[@data-qa="contract"]/a
    ${selector}  set variable  //*[@data-qa="contract-status-info-title"]
    ${field_value}  get text  ${selector}
    ${field_value}  convert_contract_status  ${field_value}
	go back
	loading дочекатись закінчення загрузки сторінки
	[Return]  ${field_value}


сторінка_детальної_інформації отримати contracts[${contract_index}].value.amount
	Синхронізувати тендер
	перейти до сторінки детальної інформаціїї за необхідністю
	wait until keyword succeeds  5m  1s  smarttender._дочекатися відображення посилання на договір
	open button  //*[@data-qa="contract"]/a
	loading дочекатись закінчення загрузки сторінки
	${selector}  set variable  //*[@data-qa="contract-amount"]
    ${field_value_in_smart_format}  get text  xpath=${selector}
    ${field_value}  convert_page_values  value.amount  ${field_value_in_smart_format}
    [Return]  ${field_value}


сторінка_детальної_інформації отримати contracts[${contract_index}].dateSigned
	Синхронізувати тендер
	перейти до сторінки детальної інформаціїї за необхідністю
	wait until keyword succeeds  5m  1s  smarttender._дочекатися відображення посилання на договір
	open button  //*[@data-qa="contract"]/a
	loading дочекатись закінчення загрузки сторінки
	${selector}  set variable  //*[@data-qa="contract-party-date-signed"]//*[@data-qa="value"]
    ${field_value_in_smart_format}  get text  xpath=${selector}
    ${field_value}  convert date  ${field_value_in_smart_format}  date_format=%d.%m.%Y  result_format=%Y-%m-%dT00:00:00${time_zone}
    [Return]  ${field_value}


smarttender.сторінка_детальної_інформації отримати contracts[${contract_index}].period.startDate
	Синхронізувати тендер
	перейти до сторінки детальної інформаціїї за необхідністю
	wait until keyword succeeds  5m  1s  smarttender._дочекатися відображення посилання на договір
	open button  //*[@data-qa="contract"]/a
	loading дочекатись закінчення загрузки сторінки
	${selector}  set variable  //*[@data-qa="contract-date-from"]
    ${field_value_in_smart_format}  get text  xpath=${selector}
    ${field_value}  convert date  ${field_value_in_smart_format}  date_format=%d.%m.%Y  result_format=%Y-%m-%dT00:00:00${time_zone}
    [Return]  ${field_value}


smarttender.сторінка_детальної_інформації отримати contracts[${contract_index}].period.endDate
	Синхронізувати тендер
	перейти до сторінки детальної інформаціїї за необхідністю
	wait until keyword succeeds  5m  1s  smarttender._дочекатися відображення посилання на договір
	open button  //*[@data-qa="contract"]/a
	loading дочекатись закінчення загрузки сторінки
	${selector}  set variable  //*[@data-qa="contract-date-to"]
    ${field_value_in_smart_format}  get text  xpath=${selector}
    ${field_value}  convert date  ${field_value_in_smart_format}  date_format=%d.%m.%Y  result_format=%Y-%m-%dT00:00:00${time_zone}
    [Return]  ${field_value}


сторінка_детальної_інформації отримати qualifications
    [Arguments]  ${field_name}
    log to console  сторінка_детальної_інформації отримати qualifications
    log  ${field_name}
    ${field_value}  run keyword  smarttender.сторінка_детальної_інформації отримати ${field_name}
    [Return]  ${field_value}


сторінка_детальної_інформації отримати qualifications[${award_index}].status
    #Синхронізувати тендер
	перейти до сторінки детальної інформаціїї за необхідністю
	${selector}  set variable  xpath=(//*[@data-qa="prequalification-info"])[${award_index} + 1]/ancestor::*[@class="ivu-card-body"]//div[text()='Статус']/following-sibling::*
    ${field_value_in_smart_format}  get text  ${selector}
	${field_value}  convert_award_status  ${field_value_in_smart_format}
	[Return]  ${field_value}


_дочекатися відображення посилання на договір
	${contract_btn}  set variable  //*[@data-qa="contract"]/a
	sleep  5s
	Reload Page
	loading дочекатись закінчення загрузки сторінки
	element should be visible  ${contract_btn}
	${contract_btn_href}  Get Element Attribute  ${contract_btn}@href
	should not be equal as strings  ${contract_btn_href}  https://test.smarttender.biz/publichni-zakupivli-prozorro-dogovory/


Видалити донора
	[Arguments]  ${username}  ${tender_auid}  ${json}
	знайти тендер у webclient  ${tender_uaid}
	header натиснути на елемент за назвою  Змінити
	операція над чекбоксом  ${False}  //*[@data-name="FUNDERS_CB"]//input
	header натиснути на елемент за назвою  Зберегти
	${status}  ${ret}  run keyword and ignore error
	...  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  '${status}' == 'PASS'  run keyword and ignore error
	...  dialog box натиснути кнопку  Так


Додати донора
	[Arguments]  ${username}  ${tender_auid}  ${json}
	знайти тендер у webclient  ${tender_uaid}
	header натиснути на елемент за назвою  Змінити
	операція над чекбоксом  ${True}  //*[@data-name="FUNDERS_CB"]//input
	webclient.Заповнити Autocomplete Field  //*[@data-name="FUNDERID"]//input  ${json['identifier']['legalName']}  check=${False}
	header натиснути на елемент за назвою  Зберегти
	${status}  ${ret}  run keyword and ignore error
	...  dialog box заголовок повинен містити  "Вид предмету закупівлі" не відповідає вказаному коду CPV
	run keyword if  '${status}' == 'PASS'  run keyword and ignore error
	...  dialog box натиснути кнопку  Так



########################################################################################################
########################################################################################################
###########################################KEYWORDS#####################################################
########################################################################################################
########################################################################################################
Авторизуватися
	[Arguments]  ${username}
	${login}  set variable  ${USERS.users['${username}']['login']}
	${password}  set variable  ${USERS.users['${username}']['password']}
	сторінка_стартова натиснути вхід
	ввести логін  ${login}
	ввести пароль  ${password}
	натиснути Увійти
	run keyword and ignore error  click element   ${screen_root_selector}//*[@alt="Close"]


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

розгорнути всі експандери
    ${selector down}  Set Variable  //*[contains(@class,"expander")]/i[contains(@class,"down")]
    Run Keyword And Ignore Error  loading дочекатися відображення елемента на сторінці  ${selector down}  2
    ${count}  Get Matching Xpath Count  ${selector down}
    Run Keyword If  ${count} != 0  Run Keywords
    ...  Repeat Keyword  ${count} times  run keyword and ignore error  Click Element  ${selector down}  AND
    ...  smarttender.розгорнути всі експандери


get text by JS
	[Arguments]    ${xpath}
	${xpath}  Set Variable  ${xpath.replace("'", '"')}
	${xpath}  Set Variable  ${xpath.replace('xpath=', '')}
	${text_is}  Execute JavaScript
	...  return document.evaluate('${xpath}', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.textContent
	[Return]  ${text_is}


clear input by JS
    [Arguments]    ${xpath}
	${xpath}  Set Variable  ${xpath.replace("'", '"')}
	${xpath}  Set Variable  ${xpath.replace('xpath=', '')}
    Execute JavaScript
    ...  document.evaluate('${xpath}', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.value=""


Input Type Flex
  [Arguments]    ${locator}    ${text}
  [Documentation]    write text letter by letter
  ${items}    Get Length    ${text}
  : FOR    ${item}    IN RANGE    ${items}
  \    Press Key    ${locator}    ${text[${item}]}


оновити дані тендера з ЦБД
    ${cdb_status}  ${cdb}  run keyword and ignore error  отримати дані тендеру з cdb по id  ${tender_cdb_id}
    run keyword if  '${cdb_status}' == 'PASS'  run keywords
    ...  Set Global Variable  ${tender_data}  ${cdb}  AND
    ...  log  ${tender_data}


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
    ${url}  set variable  https://test.smarttender.biz/participation/tenders/?trs=3
    smart go to  ${url}


перейти до тестових рамок
    ${url}  set variable  https://test.smarttender.biz/agreements?tm=2
    smart go to  ${url}


сторінка_торгів ввести текст в поле пошуку
	[Arguments]  ${text}
	${selector}  set variable  //*[@data-qa="search-block-input"]
	loading дочекатися відображення елемента на сторінці  ${selector}  20s
    input text  ${selector}  ${text}


сторінка_торгів виконати пошук
	${selector}  set variable  //*[@data-qa="search-block-button"]
    loading дочекатись закінчення загрузки сторінки
    loading дочекатися відображення елемента на сторінці  ${selector}  20s
	click element  ${selector}
	loading дочекатись закінчення загрузки сторінки


сторінка_торгів перейти за першим результатом пошуку
	${selector}  set variable  //*[@data-qa="tender-0"]//a[@data-qa="prozopro-trade-detail-url"]
	loading дочекатися відображення елемента на сторінці  ${selector}  20s
	#  Зберігаємо лінк на сторінку детальної тендеру
	${link}  get element attribute  xpath=${selector}@href
	set global variable  ${tender_detail_page}  ${link}
	log  tender_link: ${link}  WARN
	smart go to  ${link}
	log location

	#  Зберігаємо id в ЦБД
	${tender_cdb_id}  get text  //*[@data-qa="prozorro-id"]//*[@data-qa="value"]
    set global variable  ${tender_cdb_id}
	log  tender_cdb_id: ${tender_cdb_id}  WARN


сторінка_рамок перейти за першим результатом пошуку
	${selector}  set variable  xpath=(//*[@data-qa="agreement-detail-url"])[1]
	loading дочекатися відображення елемента на сторінці  ${selector}  20s
	#  Зберігаємо лінк на сторінку детальної тендеру
	${link}  get element attribute  ${selector}@href
	set global variable  ${agreement_detail_page}  ${link}
	log  agreement_link: ${link}  WARN
	smart go to  ${link}
	log location

	#  Зберігаємо id в ЦБД
	${agreement_cdb_id}      get text  //*[@data-qa="agreement-idcdb"]
	${agreement_cdb_number}  get text  //*[@data-qa="agreement-cdbnumber"]
    set global variable  ${agreement_cdb_id}
	set global variable  ${agreement_cdb_number}
	log  agreement_cdb_id: ${agreement_cdb_id}  WARN


loading дочекатись закінчення загрузки сторінки
    [Arguments]  ${time_to_wait}=120
    ${current_locationa}  Get Location
	Run Keyword And Ignore Error  loading дочекатися відображення елемента на сторінці  ${loadings}  1
	loading дочекатися зникнення елемента зі сторінки  ${loadings}  ${time_to_wait}
	${is visible}  Run Keyword And Return Status  loading дочекатися відображення елемента на сторінці  ${loadings}  0.5
	Run Keyword If  ${is visible}  loading дочекатись закінчення загрузки сторінки


loading дочекатися відображення елемента на сторінці
	[Arguments]  ${locator}  ${timeout}=10s
	Set Selenium Implicit Wait  .1
	Log  Element Should Be Visible "${locator}" after ${timeout}
	Register Keyword To Run On Failure  No Operation
	Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  ${timeout}  .5  Element Should Be Visible  ${locator}
	Register Keyword To Run On Failure  Capture Page Screenshot
	[Teardown]  Run Keyword If  "${KEYWORD STATUS}" == "FAIL"
			...  run keywords
				...  Element Should Be Visible  ${locator}  Oops!${\n}Element "${locator}" is not visible after ${timeout} (s/m).  AND
				...  Set Selenium Implicit Wait  5


loading дочекатися зникнення елемента зі сторінки
	[Documentation]  timeout=...s/...m
	[Arguments]  ${locator}  ${timeout}=10s
	Set Selenium Implicit Wait  .1
	Log  Element Should Not Be Visible "${locator}" after ${timeout}
	Register Keyword To Run On Failure  No Operation
	Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  ${timeout}  .5  Element Should Not Be Visible  xpath=${locator}
	Register Keyword To Run On Failure  Capture Page Screenshot
	[Teardown]  Run Keyword If  "${KEYWORD STATUS}" == "FAIL"
			...  run keywords
				...  Element Should Not Be Visible  ${locator}  Oops!${\n}Element "${locator}" is visible after ${timeout} (s/m).  AND
				...  Set Selenium Implicit Wait  5


Синхронізувати тендер
    [Documentation]  Если известен номер тендера в ЦБД синхронизируем принудительно єтот тендер,
    ...  если нет, просто ждем плановой синхронизации
    log to console  ${\n}
    log to console  zzzzzZZZZZZZZZZZZZZzzzzz
    log to console  Чекаємо пока пройде синхронізація
    ##########################################################
    Wait Until Keyword Succeeds  10m  5s  run keyword if  "${tender_cdb_id}" == "${None}"
    ...  _Дочекатись синхронізації  ELSE
    ...  _синхронізувати тендер за номером в ЦБД
    Switch Browser  1
    reload page
	loading дочекатись закінчення загрузки сторінки


_синхронізувати тендер за номером в ЦБД
    [Documentation]  Синхронізуємо тендер за id в ЦБД post запитом, доки не отримаеємо відповідь 200
    ...  оголошення ${tender_cdb_id} у 'сторінка_торгів перейти за першим результатом пошуку'
    ${responce}  sync_tender_by_cdb_id  ${tender_cdb_id}
    should be equal as integers  ${responce}  ${200}  msg=${\n}response.status_code != 200, наступна спроба...
    log to console  ${\n}
    log to console  Тендер ${tender_cdb_id} успішно синхронізован
    log to console  response.status_code == 200
    log to console  ...................................................


_Дочекатись синхронізації
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
	log to console  Синхронізація після ${TENDER['LAST_MODIFICATION_DATE']} пройшла успішно.
    log to console  ...................................................


сторінка_детальної_інформації активувати вкладку
    [Arguments]  ${tab_name}
    ${tab_selector}  Set Variable  //*[@data-qa="tabs"]//*[contains(text(), "${tab_name}")]
    Wait Until Keyword Succeeds  10  2  Click Element  ${tab_selector}
    loading дочекатись закінчення загрузки сторінки


перейти до сторінки детальної інформаціїї за необхідністю
    ${current_location}  get location
    run keyword if  "${tender_detail_page}" != "${current_location}"  smart go to  ${tender_detail_page}


перейти до лоту за необхідністю
    [Arguments]  ${lot_id}=None  ${index}=None
    [Documentation]  В залежності від аргументу переходимо до лоту по lot_id або по index
    ${is_lots_list}  run keyword and return status  element should be visible  //*[@data-qa="lot-list-block"]
    run keyword if  ${is_lots_list} and ${lot_id} != None
    ...  open button  xpath=//*[@data-qa="lot-list-block"]//a[contains(text(),"${lot_id}")]
    run keyword if  ${is_lots_list} and ${index} != None
    ...  open button  xpath=(//*[@data-qa="lot-list-block"]//a)[${index}]

################################################################################
#                           ПОДАТИ ПРОПОЗИЦІЮ                                  #
################################################################################
пропозиція_перевірити кнопку подачі пропозиції
    ${button}  Set Variable  xpath=//*[@data-qa="action-participation-buttons"]//a[@role="button"]|//a[@data-qa="bid-button"]
    loading дочекатися відображення елемента на сторінці  ${button}
    smarttender.Open button  ${button}
    Location Should Contain  /edit/
    comment  Захист від "швидкої" подачи пропозиції
    Wait Until Keyword Succeeds  5m  3  Run Keywords
    ...  Reload Page  AND
    ...  Element Should Not Be Visible  //*[@class='modal-dialog ']//h4


пропозиція_заповнити поле з ціною
    [Documentation]  takes lot number and coefficient
    ...  fill bid field with max available price
    [Arguments]  ${lot_id}  ${bid}

    comment  Розгорнути лот якщо id існує
    run keyword if  "${lot_id}" != "${Empty}"  _розгорнути лот по id  ${lot_id}

    comment  Якщо ESCO пропозиція_заповнити поле з ціною для ESCO та виходимо з кейворда пропозиція_заповнити поле з ціною
    run keyword if  "${mode}" == "open_esco"  run keywords
    ...  пропозиція_заповнити поле з ціною для ESCO  ${lot_id}  ${bid}  AND
    ...  return from keyword

    ${input}  set variable  //*[@class="bid-card"][contains(., "${lot_id}")]//*[contains(@id, "lotAmount")]//input[1]
    ${status}  run keyword and return status  loading дочекатися відображення елемента на сторінці  ${input}/..
    return from keyword if  not ${status}  Сума пропозиції не заповнюється

    comment  Отримуємо значення ціни пропозиції
    ${is_multiple}  set variable  ${bid['data'].get('lotValues')}
    ${float}  set variable if  """${is_multiple}""" == "${None}"
    ...  ${bid['data']['value']['amount']}
    ...  ${bid['data']['lotValues'][${count_lot}]['value']['amount']}
    ${amount}  evaluate  str(${float})
    ${count_lot}  evaluate  ${count_lot} + 1

    comment  Ввести ціну пропозиції
    input text  ${input}  ${amount}


пропозиція_заповнити поле з ціною для ESCO
    [Arguments]  ${lot_id}  ${bid}
    ${lot_selector}  set variable  //*[@class="bid-card"][contains(., "${lot_id}")]

    comment  вибрати ручний розподіл скорочення витрат
    ${element}  set variable  ${lot_selector}//label[contains(@class, 'radio')][2]
    click element  ${element}

    comment  натиснути розгорнути
    ${element}  set variable  ${lot_selector}//*[@class="collapse-box-toogle-inner"]//*[contains(@class, 'down')]
    click element  ${element}/..
    loading дочекатися зникнення елемента зі сторінки  ${element}

    comment  заповнити срок дії договору років
    input text  xpath=(${lot_selector}//input)[1]  ${bid['data']['lotValues'][0]['value']['contractDuration']['years']}

    comment  заповнити срок ді' договору днів
    input text  xpath=(${lot_selector}//input)[2]  ${bid['data']['lotValues'][0]['value']['contractDuration']['days']}

    comment  заповнити фіксований відсоток щорічних платежів
    ${yearlyPaymentsPercentage}  evaluate  str(${bid['data']['lotValues'][0]['value']['yearlyPaymentsPercentage']}*100)
    input text  xpath=(${lot_selector}//input)[3]  ${yearlyPaymentsPercentage}

    comment  заповнити поля скорочення витрат
    ${index}  set variable  1
    :FOR  ${annualCostsReduction}  IN  @{bid['data']['lotValues'][0]['value']['annualCostsReduction']}
    \  ${value}  evaluate  str(${annualCostsReduction})
    \  ${input}  set variable  xpath=(${lot_selector}//div[contains(@class, "col")]/input)[${index}+1]
    \  loading дочекатися відображення елемента на сторінці  ${input}
    \  input text  ${input}  ${value}
    \  ${index}  evaluate  ${index} + 1


_вибрати нецінові показники на сторінці детальної інформації тендера
    [Arguments]  ${bid}  ${features_names}
    [Documentation]  надеемся что последовательность в ${bid['data']['parameters']} и ${features_names} совпадают,
    ...  иначе нужно стучаться в цбд для связки кода и наименования ${feature}
    ${feature_index}  set variable  0
    :FOR  ${feature}  IN  @{bid['data']['parameters']}
    \  ${value}  set variable  ${feature['value']}
    \  ${name}  set variable  ${features_names[${feature_index}]}
    \  _вибрати неціновий показник на сторінці детальної інформації тендера  ${name}  ${value}
    \  ${feature_index}  evaluate  ${feature_index} + 1


_вибрати неціновий показник на сторінці детальної інформації тендера
    [Arguments]  ${name}  ${value}
    ${drop_down}  set variable  //*[@class="ivu-select-dropdown"]/..
    ${feature_locator}  set variable  //*[contains(@class, "feature")]/div[contains(., "${name}")]
    click element  ${feature_locator}${drop_down}
    ${feature_value}  evaluate  str(${value}*100).replace('.', ',')
    ${li_element}  set variable  ${feature_locator}${drop_down}//li[contains(., '(${feature_value}')]
    loading дочекатися відображення елемента на сторінці  ${li_element}
    click element  ${li_element}
    loading дочекатися зникнення елемента зі сторінки  ${li_element}


_розгорнути лот по id
    [Arguments]  ${lot_id}
    ${button}  set variable  //*[@class="bid-card"][contains(., "${lot_id}")]//*[@type="button" and contains(., "Прийняти участь")][not(@disabled="disabled")]
    wait until keyword succeeds  20  1  run keywords
    ...  click element  ${button}  AND
    ...  loading дочекатися зникнення елемента зі сторінки  ${button}


ввести ціну пропозиції
    [Arguments]  ${selector}  ${fieldvalue}
    ${fieldvalue}  evaluate  str(${fieldvalue})
	input text  ${selector}  ${fieldvalue}


пропозиція_відмітити чекбокси при наявності
    ${checkbox1}   set variable         //*[@id="SelfEligible"]//input/..
    ${checkbox2}   set variable         //*[@id="SelfQualified"]//input/..
    run keyword and ignore error  run keywords
    ...  Click Element  ${checkbox1}            AND
	...  Click Element  ${checkbox2}


пропозиція_подати пропозицію
    ${send offer button}   set variable  xpath=//button[contains(@id,"submitBidPlease")]
    Click Element  ${send offer button}
    sleep  2
    loading дочекатись закінчення загрузки сторінки
	smarttender.закрити валідаційне вікно (Так/Ні)  Рекомендуємо Вам для файлів з ціновою пропозицією обрати тип  Ні


закрити валідаційне вікно (Так/Ні)
	[Arguments]  ${title}  ${action}
	${button}  Set Variable  //div[contains(text(),'${title}')]/ancestor::div[@class="ivu-modal-confirm"]//button/span[text()="${action}"]
	${status}  Run Keyword And Return Status  Wait Until Page Contains Element  ${button}  3
	Run Keyword If  '${status}' == 'True'  Run Keywords  Click Element  ${button}  AND  loading дочекатись закінчення загрузки сторінки


пропозиція_закрити вікно з ЕЦП
    loading дочекатись закінчення загрузки сторінки
    ${selector}  set variable  //*[@data-qa="modal-eds"]//*[@class="ivu-modal-close"]
    run keyword and ignore error  run keywords
    ...  loading дочекатися відображення елемента на сторінці  ${selector}  60  AND
    ...  click element  ${selector}  AND
    ...  loading дочекатися зникнення елемента зі сторінки  ${selector}


пропозиція_отримати інформацію по полю ${field}
    ${status}  ${lot_number}  run keyword and ignore error  evaluate  re.search(r'\\d', "${field}").group()  re
    ${lot_number}  set variable if  "${status}" == "FAIL"  ${Empty}  ${lot_number}
    ${selector}  set variable  //*[contains(@id, "lotAmount${lot_number}")]//input
    ${bid_field}  get element attribute  ${selector}@value
    ${bid_field}  evaluate  float(str('${bid_field}'.replace(" ", "")))
    [Return]  ${bid_field}


пропозиція_отримати інформацію по полю status
    ${status_dict}  create dictionary
    ...  Пропозиція недійсна=invalid
    ...  Пропозиція подана=pending
    ...  Пропозиція не подана=None
    ${text}  get text  //*[@class="ivu-alert-message"]
    ${value}  get from dictionary  ${status_dict}  ${text}
    [Return]  ${value}


пропозиція_вибрати тип документу
    [Arguments]  ${doc_type}
    log to console  ${\n}пропозиція_вибрати тип документу
    ${dict_types}  create dictionary
    ...  eligibility_documents=Документи, що підтверджують відповідність
#    ...  financial_documents=Документи учасника-переможця
    ...  financial_documents=Цінова пропозиція
    ...  qualification_documents=Документи, що підтверджують кваліфікацію
    ${doc_name}  set variable  ${dict_types['${doc_type}']}
    ${last_doc_type}  set variable  (//*[@data-qa="document-type-btn"])[last()]
    ${item_in_list}  set variable  (//*[@data-qa="document-type-item"][contains(., "${doc_name}")])[last()]

    loading дочекатися відображення елемента на сторінці  xpath=${last_doc_type}
    click element  xpath=${last_doc_type}

#    loading дочекатися відображення елемента на сторінці  xpath=${item_in_list}
    wait until keyword succeeds  10x  3s  click element  xpath=${item_in_list}
    loading дочекатися зникнення елемента зі сторінки  ${item_in_list}


пропозиція_змінити кофіденційність файлу
    [Arguments]   ${doc_data}  ${doc_id}
	пропозиція_встановити тип кофіденційності на  true  ${doc_id}
    пропозиція_ввести текст причини конфіденційності документу  ${doc_data}  ${doc_id}


пропозиція_встановити тип кофіденційності на
    [Documentation]   ${new_status} может быть 'false' или 'true'
    [Arguments]  ${new_status}  ${doc_id}
    ${selector}  set variable  xpath=(//*[@class="file-container"])[1]//*[@class="file ivu-row"][contains(., "${doc_id}")]//*[@type="hidden"]
    ${current_status}  get element attribute  ${selector}@value
    run keyword if  "${current_status}" != "${new_status}"  run keywords
    ...  click element  ${selector}/..              AND
    ...  sleep  1                                   AND
    ...  пропозиція_встановити тип кофіденційності на  ${new_status}  ${doc_id}


пропозиція_ввести текст причини конфіденційності документу
    [Arguments]  ${doc_data}  ${doc_id}
    ${selector}  set variable  xpath=(//*[@class="file-container"])[1]//*[@class="file ivu-row"][contains(., "${doc_id}")]//*[@placeholder="Введіть причину"]
    ${text_to_enter}  set variable  ${doc_data['data']['confidentialityRationale']}
    input text  ${selector}  ${doc_data['data']['confidentialityRationale']}
    sleep  .5
    ${entered_text}  get element attribute  ${selector}@value
    ${status}  run keyword and return status  should be equal as strings  ${entered_text}  ${text_to_enter}
    run keyword if  not ${status}  пропозиція_ввести текст причини конфіденційності документу  ${doc_data}  ${doc_id}


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
#                             СКАРГИ/ВИМОГИ                                    #
################################################################################
вимога_вибрати тип запитання
    [Arguments]  ${type}
    ${dropdown_selector}  set variable  xpath=//*[@class="complaint-list"]//*[@class="ivu-select-selection"]
    ${type_selector}      set variable  xpath=//*[@class="complaint-list"]//*[@class="ivu-select-dropdown-list"]/li[contains(text(),"${type}")]
    click element  ${dropdown_selector}/i[last()]
    loading дочекатися відображення елемента на сторінці  ${type_selector}
    click element  ${type_selector}
    sleep  2
    ${get}  get text by JS  ${dropdown_selector}
    should contain  ${get}  ${type}


вимога_натиснути кнопку Подати вимогу "Замовнику"
    ${complaint button}    Set Variable  //*[@class="complaint-list"]//*[@data-qa="submit-claim"]
    ${complaint send btn}  Set Variable  //*[@class="complaint-list"]//*[@data-qa="new-complaint"]//button[contains(@class,"btn-success")]
    loading дочекатися відображення елемента на сторінці  ${complaint button}
    Click Element  ${complaint button}
    Wait Until Element Is Visible  ${complaint send btn}


вимога_натиснути кнопку Подати скаргу до "АМКУ"
    ${complaint button}    Set Variable  //*[@class="complaint-list"]//*[@data-qa="submit-complaint"]
    ${complaint send btn}  Set Variable  //*[@class="complaint-list"]//*[@data-qa="new-complaint"]//button[contains(@class,"btn-success")]
    loading дочекатися відображення елемента на сторінці  ${complaint button}
    Click Element  ${complaint button}
    Wait Until Element Is Visible  ${complaint send btn}


вимога_заповнити тему
    [Arguments]  ${text}
    ${complaint theme}  Set Variable  //*[@class="complaint-list"]//label[text()="Тема"]/following-sibling::div//input
    loading дочекатися відображення елемента на сторінці  ${complaint theme}
    Input Text  ${complaint theme}  ${text}
    Sleep  .5
    ${get}  Get Element Attribute  ${complaint theme}@value
    Should Be Equal  ${get}  ${text}


вимога_заповнити текст запитання
    [Arguments]  ${text}
    ${complaint text}  Set Variable  //*[@class="complaint-list"]//label[text()="Опис"]/following-sibling::div//textarea
    Input Text  ${complaint text}  ${text}
    Sleep  .5
    ${get}  Get Element Attribute  ${complaint text}@value
    Should Be Equal  ${get}  ${text}


вимога_завантажити документ
    [Arguments]  ${document}
    ${doc_name}  set variable  ${document.split('/')[-1]}
    Choose File  //*[@class="complaint-list"]//*[@data-qa="add-files"]//input  ${document}
    wait until page contains  ${doc_name}  20


вимога_натиснути кнопку "Подати"
    ${complaint send btn}  Set Variable  //*[@class="complaint-list"]//*[@data-qa="new-complaint"]//button[contains(@class,"btn-success")]
    Click Element  ${complaint send btn}
    loading дочекатись закінчення загрузки сторінки
    Wait Until Element Is Not Visible  ${complaint send btn}  10


вимога_натиснути коригувати
    [Arguments]  ${name}
    ${button}  set variable  //*[@class="complaint-list"]//*[@data-qa="complaint" and contains(., "${name}")]//*[@data-qa="start-edit-mode"]
    click element  ${button}
    loading дочекатися зникнення елемента зі сторінки  ${button}


вимога_натиснути Скасувати вимогу
    [Arguments]  ${cancellationReason}
    ${cancel_button}  set variable  //*[@class="complaint-list"]//*[@data-qa="cancel-complaint"]
    wait until keyword succeeds  20  1  click element  ${cancel_button}
    ${cancel_reason_input}  set variable  //*[@data-qa="cancel-reason"]//input
    loading дочекатися відображення елемента на сторінці  ${cancel_reason_input}
    wait until keyword succeeds  20  1  input text  ${cancel_reason_input}  ${cancellationReason}
    ${cancel_modal_button}  set variable  //*[@data-qa="cancel-modal-submit"]
    wait until keyword succeeds  20  1  click element  ${cancel_modal_button}
    loading дочекатися зникнення елемента зі сторінки  ${cancel_button}


вимогу_натиснути Вимогу задоволено?
    [Arguments]  ${satisfied}
    ${decision}  set variable if  "${satisfied}" == "${True}"  ${Empty}  un
    ${decision_button}  set variable  //*[@class="complaint-list"]//*[@data-qa="${decision}satisfied-decision"]
    loading дочекатися відображення елемента на сторінці  ${decision_button}
	click element  ${decision_button}
	loading дочекатись закінчення загрузки сторінки
	loading дочекатися зникнення елемента зі сторінки  ${decision_button}


вимога_отримати інформацію по полю status
    [Arguments]  ${complaintID}
    ${complaint}  set variable  //*[@class="complaint-list"]//*[@data-qa="complaint" and contains(., "${complaintID}")]
    ${status}  set variable  //*[@data-qa="type-status"]//*[contains(@class, "complaint-status")]
    ${text}  get text  xpath=${complaint}${status}
    ${dict_status}  create dictionary
    ...  Чернетка=draft
    ...  Вимога в обробці=claim
    ...  Дана відповідь=answered
    ...  Скарга в обробці=pending
    ...  Недійсна=invalid
    ...  Не задоволена=declined
    ...  Вирішена=resolved
    ...  Відхилена=cancelled
    ...  Прийнята до розгляду=accepted
    ...  Задоволена=satisfied
    ...  Прийнята до розгляду, скасована заявником=stopping
    ...  Прийнята до розгляду, скасована комісією=stopped
    ...  Помилково надіслана=mistaken
    ...  Залишено без розгляду=ignored
    ...  Скасована прийнята скарга заявником=stopping
    ${status}  get from dictionary  ${dict_status}  ${text}
    [Return]  ${status}


вимога_отримати інформацію по полю description
    [Arguments]  ${complaintID}
    ${complaintID}  set variable if  "${complaintID}" == "None"  ${Empty}  ${complaintID}
    ${complaint_locator}  set variable  //*[@data-qa="complaint" and contains(., "${complaintID}")]
    ${complaint_description_locator}  set variable  xpath=${complaint_locator}//*[@data-qa="description"]//*[@style="margin-left: 10px;"]
    ${field_value}  get text  ${complaint_description_locator}
    [Return]  ${field_value}


вимога_отримати інформацію по полю title
    [Arguments]  ${complaintID}
    ${complaintID}  set variable if  "${complaintID}" == "None"  ${Empty}  ${complaintID}
    ${complaint_locator}  set variable  //*[@data-qa="complaint" and contains(., "${complaintID}")]
    ${complaint_title_locator}  set variable  xpath=${complaint_locator}//*[@class="break-word"]
    ${field_value}  get text  ${complaint_title_locator}
    [Return]  ${field_value}


вимога_отримати інформацію по полю resolutionType
    [Arguments]  ${complaintID}
    ${complaintID}  set variable if  "${complaintID}" == "None"  ${Empty}  ${complaintID}
    ${complaint_locator}  set variable  //*[@data-qa="complaint" and contains(., "${complaintID}")]
    ${complaint_resolutionType_locator}  set variable  xpath=${complaint_locator}//span[contains(., "Тип рішення: ")]//*[@class="bold-text"]
    ${field_value_in_smart_format}  get text  ${complaint_resolutionType_locator}
    ${field_value}  set variable if
        ...  "${field_value_in_smart_format}" == "Відхилено"  declined
        ...  "${field_value_in_smart_format}" == "Недійсне"  invalid
        ...  "${field_value_in_smart_format}" == "Вирішено"  resolved
        ...  Error
    [Return]  ${field_value}


вимога_отримати інформацію по полю resolution
    [Arguments]  ${complaintID}
    ${complaintID}  set variable if  "${complaintID}" == "None"  ${Empty}  ${complaintID}
    ${complaint_locator}  set variable  //*[@data-qa="complaint" and contains(., "${complaintID}")]
    ${complaint_resolution_locator}  set variable  xpath=${complaint_locator}//*[@class="ivu-timeline-item-content" and contains(., "Тип рішення")]//*[@class="content break-word"]
    ${field_value}  get text  ${complaint_resolution_locator}
    [Return]  ${field_value}


вимога_отримати інформацію по полю satisfied
    [Arguments]  ${complaintID}
    ${complaintID}  set variable if  "${complaintID}" == "None"  ${Empty}  ${complaintID}
    ${complaint_locator}  set variable  //*[@data-qa="complaint" and contains(., "${complaintID}")]
    ${complaint_satisfied_locator}  set variable  xpath=${complaint_locator}//*[text()="Вимога задовільнена"]
    ${field_value}  run keyword and return status  element should be visible  ${complaint_satisfied_locator}
    [Return]  ${field_value}


вимога_отримати інформацію по полю cancellationReason
    [Arguments]  ${complaintID}
    ${complaintID}  set variable if  "${complaintID}" == "None"  ${Empty}  ${complaintID}
    ${complaint_locator}  set variable  //*[@data-qa="complaint" and contains(., "${complaintID}")]
    ${complaint_cancellationReason_locator}  set variable  xpath=${complaint_locator}//*[@class="ivu-timeline-item-content" and contains(., "Отменена жалобщиком")]//*[@class="content break-word"]
    ${field_value}  get text  ${complaint_cancellationReason_locator}
    [Return]  ${field_value}


вимога_отримати інформацію з докуммента по полю title
    [Arguments]  ${complaintID}
    ${complaintID}  set variable if  "${complaintID}" == "None"  ${Empty}  ${complaintID}
    ${complaint_locator}  set variable  //*[@data-qa="complaint" and contains(., "${complaintID}")]
	smarttender.розгорнути всі експандери
    ${complaint_doc_title_locator}  set variable  xpath=${complaint_locator}//*[@class="text-nowrap"]//a
    ${field_value}  get text  ${complaint_doc_title_locator}
    [Return]  ${field_value}

вимога_отримати complaintID по ${title}
    Синхронізувати тендер
    smarttender.сторінка_детальної_інформації активувати вкладку  Вимоги/скарги на умови закупівлі
    ${complaint}  set variable  //*[@class="complaint-list"]//*[@data-qa="complaint" and contains(., "${title}")]
    ${status}  set variable  //*[@data-qa="type-status"]//*[contains(text(), "UA-")]
    ${complaintID}  get text  ${complaint}${status}
    [Return]  ${complaintID}


вимоги_кваліфікація отримати complaintID по ${title}
    Синхронізувати тендер
    ${complaint}  set variable  //*[@class="complaint-list"]//*[@data-qa="complaint" and contains(., "${title}")]
    ${status}  set variable  //*[@data-qa="type-status"]//*[contains(text(), "UA-")]
    ${complaintID}  get text  ${complaint}${status}
    [Return]  ${complaintID}


вимоги_кваліфікація перейти на сторінку по індексу
    [Arguments]  ${award_index}
    ${current_location}  get_location
    return from keyword if  "AppealNew" in "${current_location}"
    ${href}  get element attribute  xpath=(//*[@data-qa="complaint-button"])[${award_index}+1]@href
    go to  ${href}
    loading дочекатись закінчення загрузки сторінки


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


Змінити номенклатуру на лот
	wait until keyword succeeds  5x  .1  run keywords
	...  click element  ${active_tab_in_screen}//*[contains(@class, "rowselected")]//*[text()="Номенклатура"]  AND
	...  click element  ${active_tab_in_screen}//*[contains(@class, "rowselected")]//*[text()="Номенклатура"]  AND
	...  click element  //*[@class="dhxcombo_option_text" and text()= "Лот"]



############################################################
#####                   PLAN EDIT                      #####
############################################################
plan edit обрати "Тип процедури закупівлі"
    [Arguments]  ${tender_type}
    selectInputNew open dropdown by click  root=${tender_type_root}
    selectInputNew select item by name  ${tender_type}  root=${tender_type_root}


plan edit заповнити "Рік"
    [Arguments]  ${year}
    number-input input text  ${year}  root=${year_root}


plan edit заповнити "Конкретна назва предмету закупівлі"
    [Arguments]  ${value}
    clear input by JS  ${plan_desc_input}
    input text  ${plan_desc_input}   ${value}


plan edit заповнити "Рік по"
    [Arguments]  ${year_to}
    number-input input text  ${year_to}  root=${year_to_root}


plan edit заповнити "Очікувана вартість закупівлі"
    [Arguments]  ${amount}
    return from keyword if  'esco' in '${mode}'
    wait until keyword succeeds  3x  1  number-input input text  ${amount}  root=${amount_root}


plan edit обрати "Валюта"
    [Arguments]  ${value}
    ${get}  selectInputNew get value  root=${currency_root}
    return from keyword if  "${get}" == "${value}"
    selectInputNew open dropdown by click         root=${currency_root}
    selectInputNew select item by name  ${value}  root=${currency_root}


plan edit заповнити "Дата старту закупівлі"
    [Arguments]  ${value}
    ivu-datePicker input text  ${value}  root=${plan_start_root}  check=${False}
    press key  //body  \\09


plan edit обрати "Замовник"
    [Arguments]  ${value}=${NONE}  ${index}=${NONE}
    [Documentation]  По умолчанию выбираем из списка по имени, но можем и по индексу,
    ...  передав например аргумент select_by=1
    scroll page to element xpath  xpath=${bayer_root}
    selectInputNew open dropdown by click         root=${bayer_root}
    run keyword if  ${index} != ${NONE}
    ...  selectInputNew select item by index  ${index}  root=${bayer_root}
    ...  ELSE
    ...  selectInputNew select item by name   ${value}  root=${bayer_root}


plan edit обрати "Код ДК021"
    [Arguments]  ${code}
    button class=button click by text  ДК021
    loading дочекатися відображення елемента на сторінці  ${cpv_input}
    input text  ${cpv_input}  ${code}
    click element  ${cpv_input}/following-sibling::div
    ${cpv_item}  set variable  //*[contains(text(),"${code}")]/ancestor::div[@class="row-wrap"][1]//*[@class="item-checkbox"]
    loading дочекатися відображення елемента на сторінці  ${cpv_item}
    click element  ${cpv_item}
    element should contain  //div[@class="tag"]  ${code}
    button type=button click by text  Зберегти  root_xpath=//*[contains(text(),"${code}")]/ancestor::div[@class="ivu-modal-body"]
    sleep  1
    page should contain  ${code}



plan edit Додати доп. класифікацію
    [Arguments]  ${additionalClassifications}  ${field_number}=1
    return from keyword
    :FOR  ${Classification}  IN  @{additionalClassifications}
    \  ${description}  set variable  ${Classification['description']}
    \  ${id}           set variable  ${Classification['id']}
    \  ${scheme}       set variable  ${Classification['scheme']}
    \  button class=button click by text  Дод. класифікація  count=${field_number}
    \  log to console  plan edit Додати доп. класифікацію
    \  debug


plan edit натиснути Додати в блоці ${name}
    ${root}  set variable  //h4[.="${name}"]/../..
    button class=button click by text  Додати  root_xpath=${root}


plan edit breakdown додати "Джерело фінансування"
    [Arguments]  ${breakdown}  ${field_number}=1
    ${convert_dict}  create dictionary
    ...  state=Державний бюджет України
    ...  crimea=Бюджет Автономної Республіки Крим
    ...  local=Місцевий бюджет
    ...  own=Власний бюджет (кошти від господарської діяльності підприємства)
    ...  fund=Бюджет цільових фондів (що не входять до складу Державного або місцевого бюджетів)
    ...  loan=Кредити та позики міжнародних валютно-кредитних організацій
    ...  other=Інше

    ${title}         set variable    ${breakdown['title']}
    ${title}         set variable    ${convert_dict['${title}']}
    ${description}   set variable    ${breakdown['description']}
    ${amount}        convert_float_to_string        ${breakdown['value']['amount']}

    comment  обрати джерело
    scroll page to element xpath  xpath=(${breakdown_root})[${field_number}]
    selectInputNew open dropdown by click          root=(${breakdown_root})[${field_number}]
    selectInputNew select item by name  ${title}   root=(${breakdown_root})[${field_number}]

    comment  вказати Сумму
    wait until keyword succeeds  3x  1  number-input input text  ${amount}  root=(${breakdownAmount_root})[${field_number}]

    comment  вказати Опис
    input text  xpath=(${breakdownDecription_input})[${field_number}]  ${description}


plan edit додати номенклатуру
    [Arguments]  ${item}  ${field_number}=1
    ${classification_id}  	set variable  ${item['classification']['id']}
	${description}  	    set variable  ${item['description']}
	${unit_name}  			set variable  ${item['unit']['name']}
	${quantity}  			convert_float_to_string  ${item['quantity']}  s=3
	${deliveryDate}  		set variable  ${item['deliveryDate']['endDate']}
	${deliveryDate}         convert date  ${deliveryDate}  result_format=%d.%m.%Y  date_format=%Y-%m-%dT%H:%M:%S+02:00

    plan edit вказати "Назва номенклатури"  ${description}   index=${field_number}
    plan edit заповнити "Од. вим."          ${unit_name}     index=${field_number}
    plan edit заповнити "Кількість"         ${quantity}      index=${field_number}
    plan edit обрати "Код ДК021"            ${classification_id}
    plan edit вказати "Дата поставки по"    ${deliveryDate}  index=${field_number}

    ${additionalClassifications_status}  ${additionalClassifications}  run keyword and ignore error  set variable  ${item['additionalClassifications']}
	run keyword if  '${additionalClassifications_status}' == 'PASS'
	...  plan edit Додати доп. класифікацію  ${additionalClassifications}  field_number=${field_number}+1


plan edit вказати "Дата поставки по"
    [Arguments]  ${value}  ${index}=1
    ivu-datePicker input text  ${value}  root=${deliveryDate_root}  check=${False}
    press key  //body  \\09


plan edit вказати "Назва номенклатури"
    [Arguments]  ${value}  ${index}=1
    scroll page to element xpath  xpath=(${plan_item_title_input})[${index}]
    input text                    xpath=(${plan_item_title_input})[${index}]  ${value}


plan edit заповнити "Од. вим."
    [Arguments]  ${value}  ${index}=1
    ${unit_name}  replace_unit_name_dict  ${value}
    ${unit_name}  set variable if
    ...  "${unit_name}" == "Штука"  штуки
    ...  "${unit_name}" == "набір"  набор
    ...  "${unit_name}" == "упаковка"  упаков
    ...  "${unit_name}" == "Упаковка"  упаков
    ...  ${unit_name}
    selectInputNew open dropdown by click         root=(${plan_item_unit_name_root})[${index}]
    click element  xpath=(${plan_item_unit_name_root})[${index}]//i[contains(@class, "smt-icon-search")]
    sleep  1
    input text     xpath=(${plan_item_unit_name_root})[${index}]//input  ${unit_name}
    selectInputNew select item by name  ${unit_name}  root=(${plan_item_unit_name_root})[${index}]


plan edit заповнити "Кількість"
    [Arguments]  ${value}  ${index}=1
    wait until keyword succeeds  3x  1  number-input input text  ${value}  root=(${plan_item_quantity_root})[${index}]


plan edit натиснути Зберегти
    ${btn}  set variable  xpath=(//*[@class="action-buttons"]//*[@class="button"][contains(text(),"Зберегти")])[1]
    click element  ${btn}
    loading дочекатись закінчення загрузки сторінки


plan edit натиснути Скасувати
    ${btn}  set variable  xpath=(//*[@class="action-buttons"]//*[@class="button"][contains(text(),"Скасувати")])[1]
    click element  ${btn}
    loading дочекатись закінчення загрузки сторінки


plan edit Опублікувати план
    button type=button click by text  Опублікувати план
    eds накласти ецп  pressEDSbtn=${False}  index=1
    ${plan_status}  план_сторінка_детальної_інформації отримати status  status
    should be equal as strings  ${plan_status}  scheduled


eds накласти ецп
    [Arguments]  ${pressEDSbtn}=${True}  ${index}=1
    run keyword if  ${pressEDSbtn}  no operation
    comment  Завантажити ключ ЕЦП
    choose file  xpath=(//*[@data-qa="modal-eds"]//input[@type='file'])[${index}]  ${EXECDIR}${/}src${/}robot_tests.broker.smarttender${/}key.dat

    comment  пароль для ключа
	wait until keyword succeeds  30  3  Input Password  xpath=(//*[@data-qa="modal-eds"]//*[@data-qa="eds-password"]//input)[${index}]  AIRman82692  #29121963

    click element  xpath=(//*[@data-qa="eds-submit-sign"])[1]
    loading дочекатися зникнення елемента зі сторінки  (//*[@data-qa="eds-submit-sign"])[${index}]  200
############################################################
############################################################
Встановити ціну за одиницю для контракту
    [Arguments]  ${username}  ${tender_uaid}  ${award_data}
    log to console  Встановити ціну за одиницю для контракту

    comment  після негативного тесткейса залишилося вікно кваліфікації, закриваемо
    run keyword and ignore error  click element   ${screen_root_selector}//*[@alt="Close"]

    ${award_name}  set variable  ${award_data['data']['suppliers'][0]['name']}
    ${unitPrices}  set variable  ${award_data['data']['unitPrices'][0]['value']['amount']}

    вибрати переможця за ім'ям  ${award_name}
    header натиснути на елемент за назвою  Заповнити ціни
    Запонити поле з ціною за одиницю
    header натиснути на елемент за назвою  OK


Зареєструвати угоду
    [Arguments]  ${username}  ${tender_uaid}  ${agreement_dates}
    log to console  Зареєструвати угоду

    ${startDate}  convert_date_from_smart_format  ${agreement_dates['startDate']}
    ${startDate}  convert date  ${startDate}  result_format=%d.%m.%Y  date_format=%Y-%m-%dT%H:%M:%S+02:00
    ${endDate}  convert_date_from_smart_format  ${agreement_dates['endDate']}
    ${endDate}  convert date  ${endDate}  result_format=%d.%m.%Y  date_format=%Y-%m-%dT%H:%M:%S+02:00

    знайти тендер у webclient  ${tender_uaid}
    # Ждем окончания периода обжалования  5 мин == 5 дней
    Sleep  5m
    header натиснути на елемент за назвою  Коригувати рамкову угоду

    ${id}  evaluate  random.randint(100000, 999999)  random
    заповнити simple input  xpath=(//*[@data-type="TextBox"])[1]//input  ${id}
    ${signDate}  Get Current Date  result_format=%d.%m.%Y
    заповнити поле з датою  xpath=(//*[@data-type="DateEdit"])[1]//input  ${signDate}
    заповнити поле з датою  xpath=(//*[@data-type="DateEdit"])[2]//input  ${startDate}
    заповнити поле з датою  xpath=(//*[@data-type="DateEdit"])[3]//input  ${endDate}
    header натиснути на елемент за назвою  OK
    header натиснути на елемент за назвою  Заключить рамочное соглашение
    dialog box заголовок повинен містити  Ви впевнені, що бажаєте перевести рамкову угоду
	dialog box натиснути кнопку  Так
    dialog box заголовок повинен містити  Накласти ЕЦП/КЕП
	dialog box натиснути кнопку  Так
	Підписати ЕЦП(webclient)
















############################################################
############################################################
#####                   ELEMENTS                       #####
############################################################
############################################################
selectInputNew get value
    [Arguments]  ${root}=${EMPTY}
    ${value}  get element attribute  xpath=${root}${selectInputNew_input}@value
    [Return]  ${value}


selectInputNew open dropdown by click
    [Arguments]  ${root}=${EMPTY}
    click element  xpath=${root}${selectInputNew_input}
    loading дочекатися відображення елемента на сторінці  xpath=${selectOptions_item}


selectInputNew select item by name
    [Arguments]  ${text}  ${root}=${EMPTY}  ${check}=${True}
    ${selector}  set variable  xpath=${root}${selectOptions_item}\[contains(text(),"${text}")]
    loading дочекатися відображення елемента на сторінці  ${selector}
    click element  ${selector}
	sleep  1
	return from keyword if  ${check} != ${True}
	${value}  selectInputNew get value  ${root}
	should be equal as strings  ${value}  ${text}


selectInputNew select item by index
    [Arguments]  ${index}  ${root}=${EMPTY}
    ${selector}  set variable  xpath=(${root}${selectOptions_item})[${index}]
    sleep  1
    click element  ${selector}
	sleep  1


number-input input text
	[Arguments]  ${text}  ${root}=${EMPTY}  ${check}=${True}
	click element  xpath=${root}${number_input}
    ${value}  number-input get value  ${root}
    ${len}  get length  "${value}"
    :FOR  ${i}  IN RANGE  ${len}
    \  press key  xpath=${root}${number_input}  \\08
	input text  xpath=${root}${number_input}  ${text.__str__()}
	${value}  number-input get value  ${root}
	run keyword if  ${check}  should be equal as strings  ${value}  ${text}



number-input get value
	[Arguments]  ${root}=${EMPTY}
	${input}  set variable  xpath=${root}${number_input}
	${value}  get element attribute  ${input}@value
	${value}  evaluate  '${value}'.replace(' ', '')
	${value}  evaluate  str("${value}")
	[Return]  ${value}


ivu-datePicker input text
	[Arguments]  ${text}  ${root}=${EMPTY}  ${field_number}=1  ${check}=${True}
	comment  очищаем поле
	${value}  __ivu-datePicker get value  ${root}  ${field_number}
    run keyword if  "${value}" != "${EMPTY}"  __ivu-datePicker clear input  ${root}  ${field_number}

    comment  вводим дату
	input text  xpath=(${root}${ivu_datePicker_input})[${field_number}]  ${text}

	comment  проверяем дату
	return from keyword if  ${check} != ${True}
	${value}  __ivu-datePicker get value  ${root}  ${field_number}
	should be equal as strings  ${value}  ${text}


ivu-datePicker choose period
    [Arguments]  ${from}  ${to}  ${root}=${EMPTY}  ${field_number}=1  ${check}=${True}
    comment  очищаем поле
	${value}  __ivu-datePicker get value  ${root}  ${field_number}
    run keyword if  "${value}" != "${EMPTY}"  __ivu-datePicker clear input  ${root}  ${field_number}

    comment  вводим период
	input text  xpath=(${root}${ivu_datePicker_input})[${field_number}]  ${from} - ${to}
	press key  ${root}  \\13
    sleep  1

	comment  проверяем дату
	return from keyword if  ${check} != ${True}
	${value}  __ivu-datePicker get value  ${root}  ${field_number}
	should be equal as strings  ${value}  ${from} - ${to}


__ivu-datePicker get value
    [Arguments]  ${root}=${EMPTY}  ${field_number}=1
    ${value}  get element attribute  xpath=(${root}${ivu_datePicker_input})[${field_number}]@value
    [Return]  ${value}


__ivu-datePicker clear input
    [Arguments]  ${root}=${EMPTY}  ${field_number}=1
    mouse over  xpath=(${root}${ivu_datePicker_input})[${field_number}]
    loading дочекатися відображення елемента на сторінці  ${root}${ivu_datePicker_close}
    click element  xpath=${root}${ivu_datePicker_close}
    ${value}  get element attribute  xpath=(${root}${ivu_datePicker_input})[${field_number}]@value
    should be empty  ${value}


button type=button click by text
	[Arguments]  ${text}  ${count}=1  ${root_xpath}=${EMPTY}
	${locator}  set variable  xpath=(${root_xpath}//button[@type="button" and contains(., "${text}")])[${count}]
	click element  ${locator}
	loading дочекатись закінчення загрузки сторінки


button class=button click by text
	[Arguments]  ${text}  ${count}=1  ${root_xpath}=${EMPTY}
	${locator}  set variable  xpath=(${root_xpath}//button[@class="button" and contains(., "${text}")])[${count}]
	click element  ${locator}
	loading дочекатись закінчення загрузки сторінки


smart go to
	[Arguments]  ${href}
	go to  ${href}
	loading дочекатись закінчення загрузки сторінки


scroll page to element xpath
	[Arguments]  ${locator}
	${x}  Get Horizontal Position  ${locator}
	${y}  Get Vertical Position  ${locator}
	@{size}  Execute Javascript  var w = window, d = document, e = d.documentElement, g = d.getElementsByTagName('body')[0], x = w.innerWidth || e.clientWidth || g.clientWidth, y = w.innerHeight|| e.clientHeight|| g.clientHeight;
										...  return [x, y]
	${x}  Evaluate  ${x}-${size[0]}/2
	${y}  Evaluate  ${y}-${size[1]}/2
	Execute JavaScript  window.scrollTo(${x},${y});