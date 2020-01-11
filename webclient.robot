*** Settings ***
Library  	DateTime
Library  	smarttender_service.py
Variables	smarttender_service.py


*** Variables ***
${active_tab_in_screen}  			//*[@id="pcModalMode_PW-1"]//*[@class="dxtc-content"]/div[@style="" or (not(@style) and @id)]
${milestone_active_row}				(//*[contains(@class, "rowselected")])[last()]
${enum_active_row}                  //*[@data-name="GRID_CRITERIONVALUES"]//tr[contains(@class,"rowselected")]
${milestone_dropdown_list}			//*[@class="dhxcombolist_material" and not(contains(@style, 'display: none;'))]
${screen_root_selector}             //*[(@id="pcCustomDialog_PW-1" or @id="pcModalMode_PW-1") and contains(@style, "visibility: visible;")]
${locator_for_click_tab_tbsk}	    //*[contains(@class, "dxtc-tab")]
${row_sitfp}						//tr[contains(@class,"Row")]
${grid}								//*[@data-type="GridView"]
${active_view}						//*[contains(@class, "active-dxtc-frame")]
${plan_cursor_row}               	//*[@data-name="GRIDTABLE"]//tr[contains(@class,"Row")]
${plan_block}                    	//div[@data-name="GRIDTABLE"]
${lot_row}                          //*[@data-name="GRID_PAYMENT_TERMS_LOTS"]//tr[contains(@class,"Row")]
${sign btn}                         //*[@id="eds_placeholder"]//*[contains(@class,"btn")][text()="Підписати"]


*** Keywords ***
заповнити поле enquiryPeriod.endDate
	[Arguments]  ${date}
	${date_input}  set variable  //*[@data-name="DDM"]//input
	${formated_date}  convert date  ${date}  result_format=%d.%m.%Y %H:%M  date_format=%Y-%m-%dT%H:%M:%S.%f${time_zone}
	заповнити поле з датою  ${date_input}  ${formated_date}


заповнити поле tenderPeriod.startDate
	[Arguments]  ${date}
	${date_input}  set variable  //*[@data-name="D_SCH"]//input
	${formated_date}  convert date  ${date}  result_format=%d.%m.%Y %H:%M  date_format=%Y-%m-%dT%H:%M:%S.%f${time_zone}
	заповнити поле з датою  ${date_input}  ${formated_date}


заповнити поле tenderPeriod.endDate
	[Arguments]  ${date}
	${date_input}  set variable  //*[@data-name="D_SROK"]//input
	${status}  ${formated_date}  run keyword and ignore error  convert date  ${date}  result_format=%d.%m.%Y %H:%M  date_format=%Y-%m-%dT%H:%M:%S.%f${time_zone}
	${formated_date}  run keyword if  '${status}' == 'FAIL'  convert date  ${date}  result_format=%d.%m.%Y %H:%M  date_format=%Y-%m-%dT%H:%M:%S${time_zone}  ELSE  set variable  ${formated_date}
	заповнити поле з датою  ${date_input}  ${formated_date}


заповнити поле value.amount
	[Arguments]  ${amount}
	${input}  set variable  //*[@data-name="INITAMOUNT"]//input
	заповнити autocomplete field  ${input}  ${amount}  check=${False}


заповнити поле minimalStep.amount
	[Arguments]  ${amount}
	${input}  set variable  //*[@data-name="MINSTEP"]//input
	заповнити autocomplete field  ${input}  ${amount}  check=${False}


заповнити поле value.valueAddedTaxIncluded
	[Arguments]  ${bool}
	${locator}  set variable  //*[@data-name="WITHVAT"]//input
	wait until keyword succeeds  5x  1  операція над чекбоксом  ${bool}  ${locator}



заповнити поле title
	[Arguments]  ${text}
	${locator}  set variable  //*[@data-name="TITLE"]//input
	заповнити simple input  ${locator}  ${text}


заповнити поле title_en
	[Arguments]  ${text}
	${locator}  set variable  //*[@data-name="TITLE_EN"]//input
	заповнити simple input  ${locator}  ${text}


заповнити поле description
	[Arguments]  ${text}
	${locator}  set variable  //*[@data-name="DESCRIPT"]//textarea
	заповнити simple input  ${locator}  ${text}


заповнити поле description_en
	[Arguments]  ${text}
	${locator}  set variable  //*[@data-name="DESCRIPT_EN"]//textarea
	заповнити simple input  ${locator}  ${text}


заповнити поле cause
	[Arguments]  ${text}
	${locator}  set variable  //*[@data-name="KREASON"]//input
	заповнити simple input  ${locator}  п. 1, ч. 2, cт. 35  input_methon=input text


заповнити поле cause_description
	[Arguments]  ${text}
	${locator}  set variable  //*[@data-name="REASONING"]//input
	заповнити simple input  ${locator}  ${text}


заповнити поле mainProcurementCategory
	[Arguments]  ${text}
	${locator}  set variable  //*[@data-name="IDCATGROUP"]
	${dict}  create dictionary
	...  goods=Товари
	...  services=Послуги
	...  works=Роботи
	заповнити фіксований випадаючий список  ${locator}  ${dict['${text}']}


заповнити поле NBUdiscountRate
	[Arguments]  ${text}
	${text}  evaluate  float(${text}) * 100
	${locator}  set variable  //*[@data-name="NBUDISCRAT"]//input
	clear input by Backspace  ${locator}
	заповнити autocomplete field  ${locator}  ${text.__str__()}  check=${False}


заповнити поле fundingKind
	[Arguments]  ${key}
	${locator}  set variable  //*[@data-name="FUNDING_KIND"]
	${dict}  create dictionary  budget=З бюджетних коштів  other=За рахунок учасника
	вибрати значення з випадаючого списку  ${locator}  ${dict['${key}']}


заповнити поле maxAwardsCount
	[Arguments]  ${text}
	${locator}  set variable  //*[@data-name="MAXWINNERCOUNT"]//input
	заповнити simple input  ${locator}  ${text}


заповнити поле agreementDuration
	[Arguments]  ${agreementDuration}
	${reg}  evaluate  re.search(r'P(?P<year>\\d)Y(?P<month>\\d)M(?P<day>\\d)', '${agreementDuration}')  re
	${year}  evaluate  ${reg.group('year')}
	${month}  evaluate  ${reg.group('month')}
	${day}  evaluate  ${reg.group('day')}
	${year_locator}  set variable  //*[@data-name="DURAGRYEARS"]//input
	${month_locator}  set variable  //*[@data-name="DURAGRMONTH"]//input
	${day_locator}  set variable  //*[@data-name="DURAGRDAYS"]//input
	заповнити simple input  ${year_locator}  ${year}
	заповнити simple input  ${month_locator}  ${month}
	заповнити simple input  ${day_locator}  ${day}


##################################################
######################LOTS#######################
##################################################
заповнити поле для lot title
	[Arguments]  ${title}
	${locator}  set variable  //*[@data-name="LOT_TITLE"]//input
	заповнити simple input  ${locator}  ${title}


заповнити поле для lot title_en
	[Arguments]  ${title}
	${locator}  set variable  //*[@data-name="LOT_TITLE_EN"]//input
	заповнити simple input  ${locator}  ${title}


заповнити поле для lot description
	[Arguments]  ${description}
	${locator}  set variable  //*[@data-name="LOT_DESCRIPTION"]//textarea
	заповнити simple input  ${locator}  ${description}


заповнити поле для lot description_en
	[Arguments]  ${description}
	${locator}  set variable  //*[@data-name="LOT_DESCRIPTION_EN"]//textarea
	заповнити simple input  ${locator}  ${description}


заповнити поле для lot value.amount
	[Arguments]  ${amount}
	${locator}  set variable  //*[@data-name="LOT_INITAMOUNT"]//input
	заповнити simple input  ${locator}  ${amount}  check=${False}


заповнити поле для lot minimalStep.amount
	[Arguments]  ${minimalStep}
	${locator}  set variable  //*[@data-name="LOT_MINSTEP"]//input
	clear input by JS  ${locator}
	заповнити autocomplete field  ${locator}  ${minimalStep}  check=${True}  input_methon=Input Type Flex


заповнити поле для lot value.valueAddedTaxIncluded
	[Arguments]  ${bool}
	${locator}  set variable  //*[@data-name="WITHVAT"]//input
	операція над чекбоксом  ${bool}  ${locator}


заповнити поле для lot minimalStepPercentage
	[Arguments]  ${text}
	${locator}  set variable  //*[@data-name="LOT_MINSTEP_PERCENT"]//input
	${value}  evaluate  ${text} * 100
	clear input by Backspace  ${locator}
	заповнити simple input  ${locator}  ${value.__str__()}  check=${False}  input_methon=Input Type Flex


заповнити поле для lot yearlyPaymentsPercentageRange
	[Arguments]  ${text}
	${locator}  set variable  //*[@data-name="LOT_PERCENT_REDUCTION"]//input
	${value}  evaluate  ${text} * 100
	clear input by JS  ${locator}
	заповнити simple input  ${locator}  ${value.__str__()}  input_methon=Input Type Flex


##################################################
######################ITEMS#######################
##################################################
заповнити поле для item description
	[Arguments]  ${description}
	${locator}  set variable  //*[@data-name="KMAT"]//input
	clear input by JS  ${locator}
	заповнити autocomplete field  ${locator}  ${description}  input_methon=Input Type Flex

заповнити поле для item description_en
	[Arguments]  ${description}
	${locator}  set variable  //*[@data-name="RESOURSENAME_EN"]//input
	заповнити simple input  ${locator}  ${description}


заповнити поле для item quantity
	[Arguments]  ${quantity}
	${locator}  set variable  //*[@data-name="QUANTITY"]//input
	clear input by JS  ${locator}
	заповнити autocomplete field  ${locator}  ${quantity}  input_methon=Input Type Flex


заповнити поле для item unit.name
	[Arguments]  ${value}
	${locator}  set variable  //*[@data-name="EDI"]//input
	${unit_name}  replace_unit_name_dict  ${value}
    ${unit_name}  set variable if
    ...  "${unit_name}" == "Штука"  штуки
    ...  "${unit_name}" == "набір"  набор
    ...  "${unit_name}" == "упаковка"  упаков
    ...  "${unit_name}" == "Упаковка"  упаков
    ...  ${unit_name}
	заповнити autocomplete field  ${locator}  ${unit_name}  action_after_input=press enter


заповнити поле для item classification.id
	[Arguments]  ${classification.id}
	${locator}  set variable  //*[@data-name="MAINCLASSIFICATION"]//input
	заповнити autocomplete field  ${locator}  ${classification.id}  check=${True}  action_after_input=press enter


заповнити поле для item additionalClassifications.scheme
	[Arguments]  ${additionalClassifications.scheme}
	${locator}  set variable  //*[@data-name="CLASSIFICATIONSCHEME"]
	${dict}  create dictionary
	...  ДКПП=ДКПП (ДК 016:2010)  ДК003=Классификатор профессий (ДК 003:2010)  ДК015=Классификация видов научно-технической деятельности (ДК 015-97)
	...  ДК018=Государственный классификатор зданий и сооружений (ДК 018-2000)  INN=Спеціальні норми та інше
	...  UA-ROAD=Індекс автомобільних доріг
	${scheme_converted}  get from dictionary  ${dict}  ${additionalClassifications.scheme}
	заповнити фіксований випадаючий список  ${locator}  ${scheme_converted}


заповнити поле для item additionalClassifications.description
	[Arguments]  ${additionalClassifications.description}
	${locator}  set variable  //*[@data-name="IDCLASSIFICATION"]//input
	заповнити autocomplete field  ${locator}  ${additionalClassifications.description}  check=${False}


заповнити поле для item deliveryAddress.postalCode
	[Arguments]  ${deliveryAddress.postalCode}
	${locator}  set variable  //*[@data-name="POSTALCODE"]//input
	заповнити simple input  ${locator}  ${deliveryAddress.postalCode}


заповнити поле для item deliveryAddress.streetAddress
	[Arguments]  ${deliveryAddress.streetAddress}
	${locator}  set variable  //*[@data-name="STREETADDR"]//input
	заповнити simple input  ${locator}  ${deliveryAddress.streetAddress}


заповнити поле для item deliveryAddress.locality
	[Arguments]  ${deliveryAddress.locality}
	${locator}  set variable  //*[@data-name="CITY_KOD"]//input
	clear input by JS  ${locator}
	заповнити autocomplete field  ${locator}  ${deliveryAddress.locality}  check=${True}  input_methon=Input Type Flex


заповнити поле для item deliveryDate.startDate
	[Arguments]  ${deliveryDate.startDate}
	${locator}  set variable  //*[@data-name="DDATEFROM"]//input
	${formated_date}  convert date  ${deliveryDate.startDate}  result_format=%d.%m.%Y  date_format=%Y-%m-%dT%H:%M:%S${time_zone}
	заповнити поле з датою  ${locator}  ${formated_date}


заповнити поле для item deliveryDate.endDate
	[Arguments]  ${deliveryDate.endDate}
	${locator}  set variable  //*[@data-name="DDATETO"]//input
	${formated_date}  convert date  ${deliveryDate.endDate}  result_format=%d.%m.%Y  date_format=%Y-%m-%dT%H:%M:%S${time_zone}
	заповнити поле з датою  ${locator}  ${formated_date}
	press key  ${locator}  \\09


##################################################
################## FEATURES #####################
##################################################
вибрати рівень прив'язки для feature
    [Arguments]  ${featureOf}
    webclient.вибрати значення з випадаючого списку  //*[@data-name="CRITERIONBINDINGLEVEL"]  ${featureOf}  ${True}


заповнити поле для feature title
    [Arguments]  ${title}
    ${locator}  set variable  //*[@data-name="CRITERIONNAME"]//input
    заповнити simple input  ${locator}  ${title}


заповнити поле для feature description
    [Arguments]  ${description}
    ${locator}  set variable  //*[@data-name="CRITERIONDESCRIPTION"]//textarea
    заповнити simple input  ${locator}  ${description}


заповнити поле для feature enum title
    [Arguments]  ${title}
    ${locator}  set variable  ${enum_active_row}//td[2]
    ввести значення в поле в гріді  ${locator}  ${title}


заповнити поле для feature enum value
    [Arguments]  ${value}
    ${locator}  set variable  ${enum_active_row}//td[4]
    ${value}  evaluate  ${value}*100
    ввести значення в поле в гріді  ${locator}  "${value}"


##################################################
###################MILESTONES#####################
##################################################
заповнити поле для milestone code
	[Arguments]  ${code}
	${locator}  set variable  ${milestone_active_row}/td[2]
	вибрати значення з випадаючого списку в гріді  ${locator}  ${code}


заповнити поле для milestone title
	[Arguments]  ${title}
	${locator}  set variable  ${milestone_active_row}/td[3]
	вибрати значення з випадаючого списку в гріді  ${locator}  ${title}


заповнити поле для milestone duration.type
	[Arguments]  ${duration.type}
	${locator}  set variable  ${milestone_active_row}/td[5]
	вибрати значення з випадаючого списку в гріді  ${locator}  ${duration.type}


заповнити поле для milestone duration.days
	[Arguments]  ${duration.days}
	${locator}  set variable  ${milestone_active_row}/td[6]
	ввести значення в поле в гріді  ${locator}  ${duration.days}


заповнити поле для milestone percentage
	[Arguments]  ${percentage}
	${locator}  set variable  ${milestone_active_row}/td[7]
	ввести значення в поле в гріді  ${locator}  ${percentage}


заповнити поле для milestone description
	[Arguments]  ${description}
	${locator}  set variable  ${milestone_active_row}/td[4]
	ввести значення в поле в гріді  ${locator}  ${description}


заповнити поле для угоди value.amountNet
	[Arguments]  ${fieldvalue}
	${amount_input}  set variable  //div/*[text()='Сума без ПДВ']/following-sibling::table//input
	clear input by Backspace  ${amount_input}
	заповнити simple input  ${amount_input}  ${fieldvalue.__str__()}  check=${False}


заповнити поле для угоди value.amount
	[Arguments]  ${fieldvalue}
	${amount_input}  set variable  //div/*[text()='Сума за договором, грн.:']/following-sibling::table//input
	clear input by Backspace  ${amount_input}
	заповнити simple input  ${amount_input}  ${fieldvalue.__str__()}  check=${False}


заповнити поле для угоди id
	[Arguments]  ${fieldvalue}
	${input}  set variable  //div/*[text()='Номер договору']/following-sibling::table//input
	заповнити simple input  ${input}  ${fieldvalue}  check=${False}


заповнити поле для угоди date
	[Arguments]  ${fieldvalue}
	${date_input}  set variable  //div/*[text()='Дата підписання']/following-sibling::table//input
	заповнити поле з датою  ${date_input}  ${fieldvalue}


заповнити поле для угоди date from
	[Arguments]  ${fieldvalue}
	${date_input}  set variable  //div/*[text()='Дата дії з']/following-sibling::table//input
	заповнити поле з датою  ${date_input}  ${fieldvalue}


заповнити поле для угоди date to
	[Arguments]  ${fieldvalue}
	${date_input}  set variable  //div/*[text()='по']/following-sibling::table//input
	заповнити поле з датою  ${date_input}  ${fieldvalue}


############################################################
######################PLANNING##############################
############################################################
create_plan заповнити "Тип процедури закупівлі"
	[Arguments]  ${procurementMethodType}
	${locator}  set variable  (${plan_cursor_row})[1]//td[count(${plan_block}//div[contains(@title,"Тип процедури") and contains(@title,"закупівлі")]/ancestor::td/preceding-sibling::*)+1]
	вибрати значення з випадаючого списку в гріді  ${locator}  ${procurementMethodType}


create_plan заповнити "Орієнтований початок процедури закупівлі"
	[Arguments]  ${value}
	${tenderPeriod_startDate_year}  convert date  ${value}  result_format=%Y  date_format=%Y-%m-%dT%H:%M:%S${time_zone}
	${tenderPeriod_startDate_month_str}  convert date  ${value}  result_format=%m  date_format=%Y-%m-%dT%H:%M:%S${time_zone}
	${tenderPeriod_startDate_month}  evaluate  str(int(${tenderPeriod_startDate_month_str}))
	${locator}  set variable  xpath=(${plan_cursor_row})[1]//td[count(${plan_block}//div[contains(@title,"Орієнтований початок") and contains(@title,"процедури закупівлі")]/ancestor::td/preceding-sibling::*)+1]
	click element  ${locator}
	wait until page contains  Введіть рік і місяць  10
	заповнити simple input  //*[@data-type="SpinEdit"]//input  ${tenderPeriod_startDate_year}
	вибрати значення з випадаючого списку  //*[@data-type="ComboBox"]  ${tenderPeriod_startDate_month}
	header натиснути на елемент за назвою  OK


create_plan заповнити "Конкретна назва предмету закупівлі"
	[Arguments]  ${value}
	${locator}  set variable  (${plan_cursor_row})[1]//td[count(${plan_block}//div[contains(@title,"Конкретна назва") and contains(@title,"предмету закупівлі")]/ancestor::td/preceding-sibling::*)+1]
	ввести значення в поле в гріді  ${locator}  ${value}


create_plan заповнити "Рік з"
	[Arguments]  ${value}
	${tenderPeriod_startDate_year}  convert date  ${value}  result_format=%Y  date_format=%Y-%m-%dT%H:%M:%S${time_zone}
	${locator}  set variable  (${plan_cursor_row})[1]//td[count(${plan_block}//div[contains(@title,"Примітки")]/ancestor::td/preceding-sibling::*)+2]
	ввести значення в поле в гріді  ${locator}  ${tenderPeriod_startDate_year}


create_plan заповнити "Очікувана вартість закупівлі"
	[Arguments]  ${value}
	${value}  evaluate  str(${value})
	${locator}  set variable  (${plan_cursor_row})[1]//td[count(${plan_block}//div[contains(@title,"Очікувана") and contains(@title,"вартість закупівлі")]/ancestor::td/preceding-sibling::*)+2]
	ввести значення в поле в гріді  ${locator}  ${value}


create_plan заповнити "Коди відповідних класифікаторів предмета закупівлі"
	[Arguments]  ${value}  ${row}=1
	${locator}  set variable  (${plan_cursor_row})[${row}]//td[count(${plan_block}//div[contains(@title,"Коди відповідних") and contains(@title,"класифікаторів предмета")]/ancestor::td/preceding-sibling::*)+2]
	ввести значення в поле в гріді  ${locator}  ${value}


create_plan заповнити "Дод.класифікація-Тип"
	[Arguments]  ${value}  ${row}=1
	${locator}  set variable  (${plan_cursor_row})[${row}]//td[count(${plan_block}//div[contains(@title,"Коди відповідних") and contains(@title,"класифікаторів предмета")]/ancestor::td/preceding-sibling::*)+3]
	вибрати значення з випадаючого списку в гріді   ${locator}  ${value}


create_plan заповнити "Дод.класифікація-Код"
	[Arguments]  ${value}  ${row}=1
	${locator}  set variable  (${plan_cursor_row})[${row}]//td[count(${plan_block}//div[contains(@title,"Коди відповідних") and contains(@title,"класифікаторів предмета")]/ancestor::td/preceding-sibling::*)+4]
	ввести значення в поле в гріді   ${locator}  ${value}
	comment  вибір з випадаючого списку
	run keyword and ignore error  click element  //*[@class="ade-list-back"]//*[contains(@style, "visibility: visible;")][2]/div[1]


create_plan заповнити "Назва номенклатури"
	[Arguments]  ${value}  ${row}=1
	${locator}  set variable  (${plan_cursor_row})[${row}]//td[count(${plan_block}//div[contains(@title,"Назва") and contains(@title,"номенклатури")]/ancestor::td/preceding-sibling::*)+3]
	ввести значення в поле в гріді   ${locator}  ${value}


create_plan заповнити "Од. вим."
	[Arguments]  ${value}  ${row}=1
	${locator}  set variable  (${plan_cursor_row})[${row}]//td[count(${plan_block}//div[contains(@title,"Од.") and contains(@title,"вим.")]/ancestor::td/preceding-sibling::*)+3]
	вибрати значення з випадаючого списку в гріді   ${locator}  ${value}
	click element  xpath=${locator}
	sleep  2
	Assign Id To Element  xpath=${milestone_dropdown_list}//*[text()="${value}"]  pls_click_this_${value}
	Execute Javascript  document.getElementById("pls_click_this_${value}").click()


create_plan заповнити "Кількість"
	[Arguments]  ${value}  ${row}=1
	${value}  evaluate  str(${value})
	${locator}  set variable  (${plan_cursor_row})[${row}]//td[count(${plan_block}//div[contains(@title,"Кількість")]/ancestor::td/preceding-sibling::*)+3]
	ввести значення в поле в гріді   ${locator}  ${value}


create_plan заповнити "Дата поставки"
	[Arguments]  ${value}  ${row}=1
	${deliveryDate}  convert date  ${value}  result_format=%d.%m.%Y  date_format=%Y-%m-%dT%H:%M:%S${time_zone}
	${locator}  set variable  (${plan_cursor_row})[${row}]//td[count(${plan_block}//div[contains(@title,"Дата") and contains(@title,"поставки")]/ancestor::td/preceding-sibling::*)+3]
	wait until keyword succeeds  5x  .1s  run keywords
	...  click element  xpath=${locator}  AND
	...  click element  xpath=${locator}  AND
	...  Assign Id To Element  xpath=${locator}//input  pls_click_this_${deliveryDate}  AND
	...  Execute JavaScript  document.getElementById("pls_click_this_${deliveryDate}").value='${deliveryDate}'  AND
	...  press key  //body  \\09







element attribute should contains value
	[Arguments]  ${element}  ${attr}  ${value}
	${class_value}  get element attribute  ${element}@${attr}
	should contain  ${class_value}  ${value}


get tab selector by name
	[Arguments]  ${name}
	${root}  check for open screen
	[Return]  ${root}${locator_for_click_tab_tbsk}\[contains(., "${name}")]


get view status
	[Arguments]  ${tab}
	# return 'active" if screen is open
	return from keyword if  """${screen_root_selector}""" in """${tab}"""  active
	###################################
	${class_value}  get element attribute  ${tab}/ancestor::*[@data-placeid]@class
	${view_status}  set variable if  "active-dxtc-frame" in "${class_value}"  active  none
	[Return]  ${view_status}


get tab status
	[Arguments]  ${tab}
	${style_value}  get element attribute  ${tab}@style
	${tab_status}  set variable if  "display:none" in "${style_value.replace(" ", "")}"  active  none
	[Return]  ${tab_status}


check for open screen
	${status}  run keyword and return status  element should be visible  ${screen_root_selector}
	${screen}  set variable if  ${status} == ${True}  ${screen_root_selector}  ${EMPTY}
	[Return]  ${screen}


натиснути додати документ
	${locator}  set variable  //*[@data-name="BTADDATTACHMENT"]
	click element  ${locator}


отримати номер тендера
	${locator}  set variable if
	...  '${mode}' == 'negotiation'  xpath=(//*[contains(@class, "rowselected")]/td)[7]
	...  '${mode}' == 'reporting'    xpath=(//*[contains(@class, "rowselected")]/td)[7]
	...  xpath=(//*[contains(@class, "rowselected")]/td/a)[1]
	${UAID}  get text  ${locator}
	[Return]  ${UAID}


вибрати тип процедури
    [Arguments]  ${value}
    wait until keyword succeeds  3x  1s  webclient.вибрати значення з випадаючого списку  //*[@data-name="KDM2"]  ${value}


пошук тендера по title
	[Arguments]  ${title}
	${find tender field}  Set Variable  xpath=((//tr[@class=' has-system-column'])[1]/td[count(//div[contains(text(), 'Узагальнена назва закупівлі')]/ancestor::td[@draggable]/preceding-sibling::*)+1]//input)[1]
	loading дочекатись закінчення загрузки сторінки
	Click Element  ${find tender field}
	Clear Element Text  ${find tender field}
	Sleep  .5
	Input Text  ${find tender field}  ${title}
	Press Key  ${find tender field}  \\13
	loading дочекатись закінчення загрузки сторінки


додати тендерну документацію
	${list_of_file_args}  create_fake_doc
	${file_path}  set variable  ${list_of_file_args[0]}
	${file_name}  set variable  ${list_of_file_args[1]}
	${file_content}  set variable  ${list_of_file_args[2]}
	webclient.активувати вкладку  Документи
	webclient.натиснути додати документ
	loading дочекатись закінчення загрузки сторінки
	загрузити документ  ${file_path}


загрузити документ
	[Arguments]  ${file_path}
	${ok_btn}  set variable  //*[@id="pcModalMode_PW-1"]//*[text()="ОК"]
	choose file  //*[@id="pcModalMode_PW-1"]//input  ${file_path}
	loading дочекатись закінчення загрузки сторінки
	click element  ${ok_btn}
	loading дочекатись закінчення загрузки сторінки
    ${is_visible}  run keyword and return status  element should be visible  ${ok_btn}
    run keyword if  ${is_visible}  run keywords
    ...  click element  ${ok_btn}                   AND
    ...  loading дочекатись закінчення загрузки сторінки


знайти тендер у webclient
	[Arguments]  ${tender_uaid}
	${location}  get location
	${grid_search_field}  set variable  xpath=((//tr[@class=' has-system-column'])[1]/td[count(//div[contains(text(), 'Номер тендеру')]/ancestor::td[@draggable]/preceding-sibling::*)+1]//input)[1]
	run keyword if  '/webclient/' not in '${location}'
	...  webclient.перейти до списку тендерів за типом процедури  ${mode}
	loading дочекатися відображення елемента на сторінці  ${grid_search_field}
	заповнити simple input  ${grid_search_field}  ${tender_uaid}
	loading дочекатись закінчення загрузки сторінки


перейти до списку тендерів за типом процедури
    [Arguments]  ${mode}
    ${label_name}  set variable if
    ...  "open_framework" in "${mode}"          Рамкові угоди(тестові)
    ...  "framework_selection" in "${mode}"     Рамкові угоди 2 етап(тестові)
    ...  "reporting" in "${mode}"               Звіт про укладений договір(тестові)
    ...  "negotiation" in "${mode}"             Переговорная процедура(тестовые)
    ...  "dialogue" in "${mode}"                Конкурентний діалог(тестові)
    ...  "open_esco" in "${mode}"               Открытые закупки энергосервиса (ESCO) (тестовые)
    ...                                         Публічні закупівлі (тестові)
	smart go to  http://test.smarttender.biz/webclient/?testmode=1&proj=it_uk&tz=3
	webclient.робочий стіл натиснути на елемент за назвою  ${label_name}
	webclient.header натиснути на елемент за назвою  Очистити
	webclient.header натиснути на елемент за назвою  OK


знайти план у webclient
	[Arguments]  ${tender_uaid}
	${location}  get location
	${grid_search_field}  set variable  xpath=((//*[@data-type="GridView"])[1]//td//input)[3]
	run keyword if  '/webclient/' not in '${location}'  run keywords
	...  go to  http://test.smarttender.biz/webclient/?testmode=1&proj=it_uk&tz=3  AND
	...  loading дочекатись закінчення загрузки сторінки
	webclient.робочий стіл натиснути на елемент за назвою  Планы закупок(тестовые)
	webclient.header натиснути на елемент за назвою  Очистити
	webclient.header натиснути на елемент за назвою  OK
	loading дочекатися відображення елемента на сторінці  ${grid_search_field}
	заповнити simple input  ${grid_search_field}  ${tender_uaid}
    loading дочекатись закінчення загрузки сторінки


Заповнити текст рішення квалиіфікації
	[Arguments]  ${text}
	input text  ${screen_root_selector}//textarea  ${text}


check for active tab
	${screen}  check for open screen
	${active_view_status}  run keyword and return status  element should be visible  ${screen}${active_view}
	${tab}  set variable if  ${active_view_status}  ${active_view}//*[@class="dxtc-content"]/div[@style="" or (not(@style) and @id)]  //*[@class="dxtc-content"]/div[@style="" or (not(@style) and @id)]
	${active_tab_exist_status}  run keyword and return status  element should be visible  ${screen}${tab}
	${tab_selector}  set variable if  ${active_tab_exist_status}  ${tab}  ${EMPTY}
	[Return]  ${tab_selector}


отримати локатор для гріда
	[Arguments]  ${grid_number}
	${screen}  check for open screen
	${tab}  check for active tab
	[Return]  (${screen}${tab}${grid})\[${grid_number}]


Підписати ЕЦП(webclient)
    loading дочекатися відображення елемента на сторінці  ${sign btn}
    Вибрати ключ ЕЦП
	Ввести пароль від ключа
	Натиснути кнопку "Підписати"


############################################################################################
############################################################################################
#####################################KEYWORDS###############################################
############################################################################################
############################################################################################
робочий стіл натиснути на елемент за назвою
	[Arguments]  ${element_name}
	click element  //*[text()="${element_name}"]
	loading дочекатись закінчення загрузки сторінки


header натиснути на елемент за назвою
	[Arguments]  ${button_name}
	${root}  check for open screen
	${btn locator}  set variable  ${root}//*[contains(@title, "${button_name}")]
	Wait Until Element Is Visible  ${btn locator}
	Click Element  ${btn locator}
	loading дочекатись закінчення загрузки сторінки


grid вибрати рядок за номером
    [Arguments]  ${row_number}  ${grid_number}=1
    ${grid_selector}  отримати локатор для гріда  ${grid_number}
    loading дочекатися відображення елемента на сторінці  xpath=${grid_selector}${row_sitfp}\[${row_number}]
    Wait Until Keyword Succeeds  5  .5  Click Element  xpath=${grid_selector}${row_sitfp}\[${row_number}]
    loading дочекатись закінчення загрузки сторінки
    loading дочекатися відображення елемента на сторінці  xpath=${grid_selector}${row_sitfp}\[${row_number}]\[contains(@class,"selected")]


вибрати переможця за номером
    [Arguments]  ${award_num}
    ${winners}  set variable
    ...  //*[@data-placeid="BIDS"]//td[@class="gridViewRowHeader"]/following-sibling::td[count(//*[@data-placeid="BIDS"]//div[contains(text(),"Поста")]/ancestor::td[1]/preceding-sibling::*)][text()]
    Wait Until Keyword Succeeds  10  2  Click Element  xpath=(${winners})[${award_num}]


вибрати учасника за номером
    [Arguments]  ${qualification_num}
    ${participants}  set variable
    ...  //*[@data-placeid="CRITERIA"]//td[@class="gridViewRowHeader"]/following-sibling::td[count(//*[@data-placeid="CRITERIA"]//div[text()="ЄДРПОУ"]/ancestor::td[1]/preceding-sibling::*)][text()]
    Wait Until Keyword Succeeds  10  2  Click Element  xpath=(${participants})[${qualification_num}]


screen заголовок повинен містити
	[Arguments]  ${text}
	${selector}  set variable  ${screen_root_selector}//*[@id="pcModalMode_PWH-1T" or @id="pcCustomDialog_PWH-1T"]
	loading дочекатися відображення елемента на сторінці  ${selector}  15
	${title}  get text  ${selector}
	should contain  ${title}  ${text}

screen натиснути кнопку
    [Arguments]  ${name}
    click element  //*[contains(@class,"Button")]//span[.="${name}"]
	loading дочекатись закінчення загрузки сторінки


dialog box натиснути кнопку
	[Arguments]  ${text}
	${locator}  set variable  //*[@class='message-box']//*[text()="${text}"]
	loading дочекатися відображення елемента на сторінці  ${locator}
	click element  ${locator}
	loading дочекатись закінчення загрузки сторінки


dialog box вибрати строку зі списка
	[Arguments]  ${text}  ${delta}=1
	[Documentation]  TODO требует пересмотра
	${selector}  set variable  //*[@id="contextMenu"]//*[contains(@class, "dxm-item") and contains(., "${text}")]
	loading дочекатися відображення елемента на сторінці  xpath=${selector}
	click element  xpath=(${selector})[${delta}]
	loading дочекатись закінчення загрузки сторінки


dialog box заголовок повинен містити
	[Arguments]  ${text}
	${locator}  set variable  //*[@id="IMMessageBox_PWH-1"]//*[@class="dxpc-headerContent"]
	${title}  get text  ${locator}
	capture page screenshot
	should contain  ${title}  ${text}


вибрати значення з випадаючого списку в гріді
	[Arguments]  ${locator}  ${text}
	wait until keyword succeeds  5x  1s  run keywords
	...  click element  xpath=${locator}  AND
	...  sleep  .5  AND
	...  click element  xpath=${locator}  AND
	...  click element  xpath=${milestone_dropdown_list}//*[text()="${text}"]  AND
	...  loading дочекатись закінчення загрузки сторінки


ввести значення в поле в гріді
	[Arguments]  ${locator}  ${text}
	wait until keyword succeeds  5x  1s  run keywords
	...  click element  xpath=${locator}  AND
	...  click element  xpath=${locator}  AND
	...  input text  xpath=${locator}//input|${locator}//textarea  ${text}  AND
#	...  press key  //body  \\09  AND
	...  click screen header  AND
	...  loading дочекатись закінчення загрузки сторінки


вибрати значення з випадаючого списку
	[Arguments]  ${locator}  ${text}  ${check}=${False}
	${dropdown_table_locator}  set variable  //*[contains(@class,"dxpcDropDown_DevEx") and contains(@style,"visibility: visible")]
	wait until keyword succeeds  5x  1s  run keywords
	...  click element  ${locator}  AND
	...  loading дочекатися відображення елемента на сторінці  ${dropdown_table_locator}  AND
	...  loading дочекатися відображення елемента на сторінці  ${dropdown_table_locator}//*[contains(text(), "${text}")]  AND
	...  click element  ${dropdown_table_locator}//*[contains(text(), "${text}")]  AND
	...  loading дочекатись закінчення загрузки сторінки
	return from keyword if  ${check} == ${False}
	${get}  get element attribute  ${locator}//input[not(@type="hidden")]@value
	should be equal as strings  ${get}  ${text}


заповнити фіксований випадаючий список
    [Arguments]  ${locator}  ${text}
	wait until keyword succeeds  5x  1s  заповнити фіксований випадаючий список continue  ${locator}  ${text}


заповнити фіксований випадаючий список continue
	[Arguments]  ${locator}  ${text}
	click element  ${locator}//td[3]
	press key  ${locator}//td[2]//input  \\127
	input text  ${locator}//td[2]//input  ${text}
	click screen header
	loading дочекатись закінчення загрузки сторінки
	${get}  get element attribute  ${locator}//td[2]//input@value
	should be equal  "${get}"  "${text}"


заповнити simple input
	[Arguments]  ${locator}  ${input_text}  ${check}=${True}  ${input_methon}=input text
	wait until keyword succeeds  10x  1s  заповнити simple input continue  ${locator}  ${input_text}  ${check}  ${input_methon}
	loading дочекатись закінчення загрузки сторінки


заповнити simple input continue
    [Arguments]  ${locator}  ${input_text}  ${check}  ${input_methon}=input text
	${text}  evaluate      """${input_text}""".decode('UTF-8')
	click element             ${locator}
	clear input by JS         ${locator}
	run keyword               ${input_methon}  ${locator}  ${text}
	press key                 ${locator}  \\13
#	click screen header
#	loading дочекатись закінчення загрузки сторінки
	${get}  get element attribute  ${locator}@value
	${get}  set variable           ${get.replace('\n', '')}
	should not be empty            ${get}
	run keyword if                 ${check}  should be equal as strings  "${get}"  "${text}"


заповнити autocomplete field
	[Arguments]  ${locator}  ${input_text}  ${check}=${True}  ${input_methon}=input text  ${action_after_input}=click screen header
	wait until keyword succeeds  5x  1s  заповнити autocomplete field continue  ${locator}  ${input_text}  ${check}  input text  ${action_after_input}


заповнити autocomplete field continue
	[Arguments]  ${locator}  ${input_text}  ${check}  ${input_methon}  ${action_after_input}
	${dropdown_list}  set variable  //*[@class="ade-list-back" and contains(@style, "left")]
	${item_in_dropdown_list}  set variable  //*[@class="dhxcombo_option dhxcombo_option_selected"]
	${text}  evaluate  u"""${input_text}"""
	click element  ${locator}
	clear input by JS  ${locator}
	run keyword  ${input_methon}  ${locator}  ${text}
	run keyword if  '${action_after_input}' == 'click screen header'  run keywords  loading дочекатись закінчення загрузки сторінки  AND  click screen header  ELSE
	...  press key  //body  \\13
	${dropdown_status}  run keyword and return status  loading дочекатися відображення елемента на сторінці  ${dropdown_list}${item_in_dropdown_list}  timeout=2s
	run keyword if  ${dropdown_status}  click element  ${dropdown_list}${item_in_dropdown_list}
	loading дочекатись закінчення загрузки сторінки
	${get}  get element attribute  ${locator}@value
	run keyword if  ${check}  should contain  ${get}  ${text}


операція над чекбоксом
	[Arguments]  ${bool}  ${locator}
	${class}  get element attribute  ${locator}/../..@class
	run keyword if  'Unchecked' in '${class}' and ${bool} or 'Checked' in '${class}' and '${bool}' == '${False}'
	...  click element  ${locator}/../..
	loading дочекатись закінчення загрузки сторінки
	${class}  get element attribute  ${locator}/../..@class
	run keyword if  ${bool}  should contain  ${class}  Checked
	...  ELSE                should contain  ${class}  Unchecked


заповнити поле з датою
	[Arguments]  ${locator}  ${date}
	wait until keyword succeeds  5x  1s  заповнити поле з датою continue  ${locator}  ${date}
	#Capture Page Screenshot


заповнити поле з датою continue
  	[Arguments]  ${locator}  ${date}
	clear input by JS  ${locator}
	input text  ${locator}  ${date}
#	sleep  .5
#	press key  //body  \\13
	click screen header
#	loading дочекатись закінчення загрузки сторінки
	${get}  get element attribute  ${locator}@value
	should be equal  "${get}"  "${date}"


click screen header
	click element  //*[@id="pcModalMode_PWH-1"]


додати бланк
	[Arguments]  ${grid_name}
	${locator}  set variable  xpath=//*[@data-name="${grid_name}"]//*[@title="Додати"]
	${count}  Get Matching Xpath Count  //*[@data-name="${grid_name}"]//tr[contains(@class,"Row")]
	loading дочекатися відображення елемента на сторінці  ${locator}  2
    click element  ${locator}
	loading дочекатись закінчення загрузки сторінки
	${count_after}  Get Matching Xpath Count  //*[@data-name="${grid_name}"]//tr[contains(@class,"Row")]
	return from keyword if  ${count_after} == ${count}+1
    додати бланк  ${grid_name}


видалити всі лоти та предмети
    [Arguments]  ${screen}=GRID_ITEMS_HIERARCHY  ${index}=1
    ${count}  Get Matching Xpath Count  //*[@data-name="${screen}"]//tr[contains(@class,"Row")]
    ${del_btn}  set variable  xpath=//*[@data-name="${screen}"]//*[@title="Видалити"][${index}]
	return from keyword if  ${count} == 0
	run keyword and ignore error  click element  ${del_btn}
	loading дочекатись закінчення загрузки сторінки
	webclient.видалити всі лоти та предмети


видалити item по id
	[Arguments]  ${item_id}  ${index}=1
	#  Стати на комірку з потрібним предметом
	${item_row_locator}  set variable  xpath=//*[@data-name="GRID_ITEMS_HIERARCHY"]//td[contains(text(),"${item_id}")]/ancestor::tr[1]
	click element  ${item_row_locator}
	loading дочекатись закінчення загрузки сторінки
	wait until page contains element  ${item_row_locator}[contains(@class,"rowselected")]  5
    #  Видалити
	${del_btn}  set variable  xpath=//*[@data-name="GRID_ITEMS_HIERARCHY"]//*[@title="Видалити"][${index}]
	click element  ${del_btn}
	loading дочекатись закінчення загрузки сторінки


видалити lot по id
	[Arguments]  ${lot_id}  ${index}=1
	#  Стати на комірку з потрібним лотом
	${lot_row_locator}  set variable  xpath=//*[@data-name="GRID_ITEMS_HIERARCHY"]//td[contains(text(),"${lot_id}")]/ancestor::tr[1]
	click element  ${lot_row_locator}
	wait until page contains element  ${lot_row_locator}[contains(@class,"rowselected")]  5
    #  Видалити
	${del_btn}  set variable  xpath=//*[@data-name="GRID_ITEMS_HIERARCHY"]//*[@title="Видалити"][${index}]
	click element  ${del_btn}
	loading дочекатись закінчення загрузки сторінки


видалити feature по id
	[Arguments]  ${feature_id}  ${index}=1
	#  Стати на комірку з потрібним показником
	${feature_row_locator}  set variable  xpath=//*[@data-name="GRID_CRITERIA"]//td[contains(text(),"${feature_id}")]/ancestor::tr[1]
	click element  ${feature_row_locator}
	loading дочекатись закінчення загрузки сторінки
	wait until page contains element  ${feature_row_locator}[contains(@class,"rowselected")]  5
    #  Видалити
	${del_btn}  set variable  xpath=//*[@data-name="GRID_CRITERIA"]//*[@title="Видалити"][${index}]
	click element  ${del_btn}
	loading дочекатись закінчення загрузки сторінки


активувати вкладку
	[Arguments]  ${tab_name}  ${index}=1
	[Documentation]  Активирует вкладку по содержащую _tab_name_ в имени.
	${tab}  webclient.get tab selector by name  ${tab_name}
	${view_status}  webclient.get view status  ${tab}
	${tab_status}  webclient.get tab status  ${tab}
	Run Keyword If
	...  "${tab_status}" == "none"  											run keywords
	...  		click element  xpath=(${tab})[${index}]									AND
	...  		loading дочекатись закінчення загрузки сторінки  						ELSE IF
	...  "${tab_status}" == "active" and "${view_status}" == "none"  			run keywords
	...  		click element  xpath=(${tab})[${index}]/following-sibling::*			AND
	...  		loading дочекатись закінчення загрузки сторінки


Перейти за посиланням "Натисніть для переходу"
    ${value}  Get Element Attribute  xpath=//a[contains(text(), 'Натисніть для переходу') and @href]@onclick
    ${href}  evaluate  re.search("[^']+.(?P<href>.+)[']+", "${value}").group("href")  re
	smart go to  ${href}
	[Return]  ${href}


clear input by Backspace
    [Arguments]  ${input}
    :FOR  ${i}  IN RANGE  256
	\   press key  ${input}  \\08
	\   ${get}  get element attribute  ${input}@value
	\   ${get}  set variable  ${get.replace(' ', '')}
	\   exit for loop if   "${get}" == "${EMPTY}" or "${get}" == "+"
	[Return]  ${get}


Вибрати ключ ЕЦП
    ${upload}  set variable  xpath=(//*[@id="eds_placeholder"]//input[@class="upload"])[1]
    Choose File  ${upload}  ${EXECDIR}${/}src${/}robot_tests.broker.smarttender${/}key.dat


Ввести пароль від ключа
    ${pass input}  set variable  //*[@id="eds_placeholder"]//input[@name="password"]
    ${eds_passwod}  set variable  AIRman82692
    Input Password  ${pass input}  ${eds_passwod}


Натиснути кнопку "Підписати"
	Click Element  ${sign btn}
    loading дочекатись закінчення загрузки сторінки