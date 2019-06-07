*** Variables ***
${active_tab_in_screen}  			//*[@id="pcModalMode_PW-1"]//*[@class="dxtc-content"]/div[@style="" or (not(@style) and @id)]
${milestone_active_row}				xpath=(//*[contains(@class, "rowselected")])[last()]
${milestone_dropdown_list}			//*[@class="dhxcombolist_material" and not(contains(@style, 'display: none;'))]
${screen_root_selector}             //*[(@id="pcCustomDialog_PW-1" or @id="pcModalMode_PW-1") and contains(@style, "visibility: visible;")]
${locator_for_click_tab_tbsk}	    //*[contains(@class, "dxtc-tab")]
${row_sitfp}						//tr[contains(@class,"Row")]
${grid}								//*[@data-type="GridView"]
${active_view}						//*[contains(@class, "active-dxtc-frame")]


*** Keywords ***
заповнити поле enquiryPeriod.startDate
	[Arguments]  ${date}
	${date_input}  set variable  //*[@data-name="DDM"]//input
	${formated_date}  convert date  ${date}  result_format=%d.%m.%Y %H:%M  date_format=%Y-%m-%dT%H:%M:%S.%f+03:00
	заповнити поле з датою  ${date_input}  ${formated_date}


заповнити поле tenderPeriod.startDate
	[Arguments]  ${date}
	${date_input}  set variable  //*[@data-name="D_SCH"]//input
	${formated_date}  convert date  ${date}  result_format=%d.%m.%Y %H:%M  date_format=%Y-%m-%dT%H:%M:%S.%f+03:00
	заповнити поле з датою  ${date_input}  ${formated_date}


заповнити поле tenderPeriod.endDate
	[Arguments]  ${date}
	${date_input}  set variable  //*[@data-name="D_SROK"]//input
	${status}  ${formated_date}  run keyword and ignore error  convert date  ${date}  result_format=%d.%m.%Y %H:%M  date_format=%Y-%m-%dT%H:%M:%S.%f+03:00
	${formated_date}  run keyword if  '${status}' == 'FAIL'  convert date  ${date}  result_format=%d.%m.%Y %H:%M  date_format=%Y-%m-%dT%H:%M:%S+03:00  ELSE  set variable  ${formated_date}
	заповнити поле з датою  ${date_input}  ${formated_date}


заповнити поле value.amount
	[Arguments]  ${amount}
	${input}  set variable  //*[@data-name="INITAMOUNT"]//input
	заповнити simple input  ${input}  ${amount}  check=${False}


заповнити поле minimalStep.amount
	[Arguments]  ${amount}
	${input}  set variable  //*[@data-name="MINSTEP"]//input
	заповнити simple input  ${input}  ${amount}  check=${False}


заповнити поле value.valueAddedTaxIncluded
	[Arguments]  ${bool}
	${locator}  set variable  //*[@data-name="WITHVAT"]//input
	операція над чекбоксом  ${bool}  ${locator}



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


заповнити поле mainProcurementCategory
	[Arguments]  ${text}
	${locator}  set variable  //*[@data-name="IDCATGROUP"]
	${dict}  create dictionary
	...  goods=Товари
	...  services=Послуги
	...  works=Роботи
	заповнити фіксований випадаючий список  ${locator}  ${dict['${text}']}


##################################################
######################LOTS#######################
##################################################
заповнити поле для lot title
	[Arguments]  ${title}
	${locator}  set variable  //*[@data-name="LOT_TITLE"]//input
	заповнити simple input  ${locator}  ${title}


заповнити поле для lot description
	[Arguments]  ${description}
	${locator}  set variable  //*[@data-name="LOT_DESCRIPTION"]//textarea
	заповнити simple input  ${locator}  ${description}


заповнити поле для lot value.amount
	[Arguments]  ${amount}
	${locator}  set variable  //*[@data-name="LOT_INITAMOUNT"]//input
	заповнити simple input  ${locator}  ${amount}  check=${False}



заповнити поле для lot minimalStep.amount
	[Arguments]  ${minimalStep}
	${locator}  set variable  //*[@data-name="LOT_MINSTEP"]//input
	заповнити simple input  ${locator}  ${minimalStep}  check=${False}


заповнити поле для lot value.valueAddedTaxIncluded
	[Arguments]  ${bool}
	${locator}  set variable  //*[@data-name="WITHVAT"]//input
	операція над чекбоксом  ${bool}  ${locator}


##################################################
######################ITEMS#######################
##################################################
заповнити поле для item description
	[Arguments]  ${description}
	${locator}  set variable  //*[@data-name="KMAT"]//input
	заповнити simple input  ${locator}  ${description}


заповнити поле для item description_en
	[Arguments]  ${description}
	${locator}  set variable  //*[@data-name="RESOURSENAME_EN"]//input
	заповнити simple input  ${locator}  ${description}


заповнити поле для item quantity
	[Arguments]  ${quantity}
	${locator}  set variable  //*[@data-name="QUANTITY"]//input
	заповнити simple input  ${locator}  ${quantity}  check=${False}


заповнити поле для item unit.name
	[Arguments]  ${unit.name}
	${locator}  set variable  //*[@data-name="EDI"]//input
	заповнити autocomplete field  ${locator}  ${unit.name}


заповнити поле для item classification.id
	[Arguments]  ${classification.id}
	${locator}  set variable  //*[@data-name="MAINCLASSIFICATION"]//input
	заповнити autocomplete field  ${locator}  ${classification.id}  check=${False}


заповнити поле для item additionalClassifications.scheme
	[Arguments]  ${additionalClassifications.scheme}
	${locator}  set variable  //*[@data-name="CLASSIFICATIONSCHEME"]
	${dict}  create dictionary  ДКПП=ДКПП (ДК 016:2010)  ДК003=Классификатор профессий (ДК 003:2010)  ДК015=Классификация видов научно-технической деятельности (ДК 015-97)  ДК018=Государственный классификатор зданий и сооружений (ДК 018-2000)  INN=Спеціальні норми та інше
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
	заповнити autocomplete field  ${locator}  ${deliveryAddress.locality}  check=${False}


заповнити поле для item deliveryDate.startDate
	[Arguments]  ${deliveryDate.startDate}
	${locator}  set variable  //*[@data-name="DDATEFROM"]//input
	${formated_date}  convert date  ${deliveryDate.startDate}  result_format=%d.%m.%Y  date_format=%Y-%m-%dT%H:%M:%S+03:00
	заповнити поле з датою  ${locator}  ${formated_date}


заповнити поле для item deliveryDate.endDate
	[Arguments]  ${deliveryDate.endDate}
	${locator}  set variable  //*[@data-name="DDATETO"]//input
	${formated_date}  convert date  ${deliveryDate.endDate}  result_format=%d.%m.%Y  date_format=%Y-%m-%dT%H:%M:%S+03:00
	заповнити поле з датою  ${locator}  ${formated_date}


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
	заповнити simple input  ${amount_input}  '${fieldvalue}'  check=${False}


заповнити поле для угоди value.amount
	[Arguments]  ${fieldvalue}
	${amount_input}  set variable  //div/*[text()='Сума за договором, грн.:']/following-sibling::table//input
	заповнити simple input  ${amount_input}  '${fieldvalue}'  check=${False}


заповнити поле для угоди id
	[Arguments]  ${fieldvalue}
	${amount_input}  set variable  //div/*[text()='Номер договору']/following-sibling::table//input
	заповнити simple input  ${amount_input}  ${fieldvalue}  check=${False}


заповнити поле для угоди date
	[Arguments]  ${fieldvalue}
	${amount_input}  set variable  //div/*[text()='Дата підписання']/following-sibling::table//input
	заповнити поле з датою  ${amount_input}  ${fieldvalue}






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
	${locator}  set variable  xpath=(//*[contains(@class, "rowselected")]/td/a)[1]
	${UAID}  get text  ${locator}
	[Return]  ${UAID}


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
	choose file  //*[@id="pcModalMode_PW-1"]//input  ${file_path}
	loading дочекатись закінчення загрузки сторінки
	click element  //*[@id="pcModalMode_PW-1"]//*[text()="ОК"]
	loading дочекатись закінчення загрузки сторінки


знайти тендер у webclient
	[Arguments]  ${tender_uaid}
	${location}  get location
	${grid_search_field}  set variable  xpath=((//*[@data-type="GridView"])[1]//td//input)[4]
	run keyword if  '/webclient/' not in '${location}'  run keywords
	...  go to  http://test.smarttender.biz/webclient/?testmode=1&proj=it_uk&tz=3  AND
	...  loading дочекатись закінчення загрузки сторінки  AND
	...  webclient.робочий стіл натиснути на елемент за назвою  Публічні закупівлі (тестові)  AND
	...  webclient.header натиснути на елемент за назвою  Очистити  AND
	...  webclient.header натиснути на елемент за назвою  OK  AND
	...  loading дочекатися відображення елемента на сторінці  ${grid_search_field}  AND
	...  input text  ${grid_search_field}  ${tender_uaid}  AND
	...  press key  ${grid_search_field}  \\13  AND
	...  loading дочекатись закінчення загрузки сторінки


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


screen заголовок повинен містити
	[Arguments]  ${text}
	${selector}  set variable  ${screen_root_selector}//*[@id="pcModalMode_PWH-1T" or @id="pcCustomDialog_PWH-1T"]
	loading дочекатися відображення елемента на сторінці  ${selector}
	${title}  get text  ${selector}
	should contain  ${title}  ${text}


dialog box натиснути кнопку
	[Arguments]  ${text}
	${locator}  set variable  //*[@class='message-box']//*[text()="${text}"]
	loading дочекатися відображення елемента на сторінці  ${locator}
	click element  ${locator}
	loading дочекатись закінчення загрузки сторінки


dialog box заголовок повинен містити
	[Arguments]  ${text}
	${locator}  set variable  //*[@id="IMMessageBox_PWH-1"]//*[@class="dxpc-headerContent"]
	${title}  get text  ${locator}
	should contain  ${title}  ${text}


вибрати значення з випадаючого списку в гріді
	[Arguments]  ${locator}  ${text}
	wait until keyword succeeds  10x  1s  run keywords
	...  click element  ${locator}  AND
	...  sleep  .5  AND
	...  click element  ${locator}  AND
#	...  loading дочекатися відображення елемента на сторінці  ${milestone_dropdown_list}  timeout=1s  AND
	...  click element  ${milestone_dropdown_list}//*[text()="${text}"]  AND
	...  loading дочекатись закінчення загрузки сторінки


ввести значення в поле в гріді
	[Arguments]  ${locator}  ${text}
	wait until keyword succeeds  10x  1s  run keywords
	...  click element  ${locator}  AND
	...  click element  ${locator}  AND
#	...  loading дочекатися відображення елемента на сторінці  ${locator}//input  timeout=1s  AND
	...  input text  ${locator}//input  ${text}  AND
	...  press key  //body  \\09  AND
	...  loading дочекатись закінчення загрузки сторінки


вибрати значення з випадаючого списку
	[Arguments]  ${locator}  ${text}
	${dropdown_table_locator}  set variable  //*[contains(@class,"dxpcDropDown_DevEx") and contains(@style,"visibility: visible")]
	wait until keyword succeeds  10x  1s  run keywords
	...  click element  ${locator}  AND
	...  wait until element is visible  ${dropdown_table_locator}  AND
	...  click element  ${dropdown_table_locator}//*[text()="${text}"]  AND
	...  loading дочекатись закінчення загрузки сторінки


заповнити фіксований випадаючий список
    [Arguments]  ${locator}  ${text}
	wait until keyword succeeds  5x  1s  заповнити фіксований випадаючий список continue  ${locator}  ${text}


заповнити фіксований випадаючий список continue
	[Arguments]  ${locator}  ${text}
	click element  ${locator}//td[3]
	input text  ${locator}//td[2]//input  ${text}
	click screen header
	loading дочекатись закінчення загрузки сторінки
	${get}  get element attribute  ${locator}//td[2]//input@value
	should be equal  "${get}"  "${text}"


заповнити simple input
	[Arguments]  ${locator}  ${input_text}  ${check}=${True}
	wait until keyword succeeds  5x  1s  заповнити simple input continue  ${locator}  ${input_text}  ${check}


заповнити simple input continue
    [Arguments]  ${locator}  ${input_text}  ${check}
	${input_text}  evaluate  u"""${input_text}"""
	clear input by JS  ${locator}
	Clear Element Text  ${locator}
	sleep  1
	input text  ${locator}  ${input_text}
	press key  ${locator}  \\13
	loading дочекатись закінчення загрузки сторінки
	${get}  get element attribute  ${locator}@value
	${get}  set variable  ${get.replace('\n', '')}
	run keyword if  ${check}  should be equal  "${get}"  "${input_text}"


заповнити autocomplete field
	[Arguments]  ${locator}  ${input_text}  ${check}=${True}
	wait until keyword succeeds  5x  1s  заповнити autocomplete field continue  ${locator}  ${input_text}  ${check}


заповнити autocomplete field continue
	[Arguments]  ${locator}  ${input_text}  ${check}
	${dropdown_list}  set variable  //*[@class="ade-list-back" and contains(@style, "left")]
	${item_in_dropdown_list}  set variable  //*[@class="dhxcombo_option dhxcombo_option_selected"]
	${input_text}  evaluate  u"""${input_text}"""
	input text  ${locator}  ${input_text}
	press key  //body  \\13
	${dropdown_status}  run keyword and return status  loading дочекатися відображення елемента на сторінці  ${dropdown_list}${item_in_dropdown_list}  timeout=1
	run keyword if  ${dropdown_status}  click element  ${dropdown_list}${item_in_dropdown_list}
	loading дочекатись закінчення загрузки сторінки
	${get}  get element attribute  ${locator}@value
	run keyword if  ${check}  should be equal  "${get}"  "${input_text}"


операція над чекбоксом
	[Arguments]  ${bool}  ${locator}
	${class}  get element attribute  ${locator}/../..@class
	run keyword if  'Unchecked' in '${class}' and ${bool} or 'checked' in '${class}' and '${bool}' == '${False}'
	...  click element  ${locator}/../..


заповнити поле з датою
	[Arguments]  ${locator}  ${date}
	wait until keyword succeeds  5x  1s  заповнити поле з датою continue  ${locator}  ${date}
	#Capture Page Screenshot


заповнити поле з датою continue
  	[Arguments]  ${locator}  ${date}
	clear input by JS  ${locator}
	input text  ${locator}  ${date}
	sleep  .5
	press key  //body  \\13
	loading дочекатись закінчення загрузки сторінки
	${get}  get element attribute  ${locator}@value
	should be equal  "${get}"  "${date}"


click screen header
	click element  //*[@id="pcModalMode_PWH-1"]


додати item бланк
	[Arguments]  ${index}=1
	${locator}  set variable  xpath=(${active_tab_in_screen}//*[@data-type="GridView"]//*[@class="dxr-group mygroup"]//*[@title="Додати"])[${index}]
	click element  ${locator}
	loading дочекатись закінчення загрузки сторінки


активувати вкладку
	[Arguments]  ${tab_name}
	[Documentation]  Активирует вкладку по содержащую _tab_name_ в имени.
	${tab}  webclient.get tab selector by name  ${tab_name}
	${view_status}  webclient.get view status  ${tab}
	${tab_status}  webclient.get tab status  ${tab}
	Run Keyword If
	...  "${tab_status}" == "none"  											run keywords
	...  		click element  ${tab}											AND
	...  		loading дочекатись закінчення загрузки сторінки  						ELSE IF
	...  "${tab_status}" == "active" and "${view_status}" == "none"  			run keywords
	...  		click element  ${tab}/following-sibling::*						AND
	...  		loading дочекатись закінчення загрузки сторінки
