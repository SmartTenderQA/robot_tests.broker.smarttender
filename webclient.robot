*** Variables ***
${active_tab_in_screen}  			//*[@id="pcModalMode_PW-1"]//*[@class="dxtc-content"]/div[@style="" or (not(@style) and @id)]
${milestone_active_row}				xpath=(//*[contains(@class, "rowselected")])[last()]
${milestone_dropdown_list}			//*[@class="dhxcombolist_material" and not(contains(@style, 'display: none;'))]


*** Keywords ***
робочий стіл натиснути на елемент за назвою
	[Arguments]  ${element_name}
	click element  //*[text()="${element_name}"]
	loading дочекатись закінчення загрузки сторінки


header натиснути на елемент за назвою
	[Arguments]  ${button_name}
	${btn locator}  set variable  //*[contains(@title, "${button_name}")]
	Wait Until Element Is Visible  ${btn locator}
	Click Element  ${btn locator}
	loading дочекатись закінчення загрузки сторінки


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
	${formated_date}  convert date  ${date}  result_format=%d.%m.%Y %H:%M  date_format=%Y-%m-%dT%H:%M:%S.%f+03:00
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



заповнити поле description
	[Arguments]  ${text}
	${locator}  set variable  //*[@data-name="DESCRIPT"]//textarea
	заповнити simple input  ${locator}  ${text}



заповнити поле mainProcurementCategory
	[Arguments]  ${text}
	${locator}  set variable  //*[@data-name="IDCATGROUP"]
	заповнити фіксований випадаючий список  ${locator}  ${text}

##################################################
######################ITEMS#######################
##################################################
заповнити поле для item description
	[Arguments]  ${description}
	${locator}  set variable  //*[@data-name="KMAT"]//input
	заповнити simple input  ${locator}  ${description}


заповнити поле для item quantity
	[Arguments]  ${quantity}
	${locator}  set variable  //*[@data-name="QUANTITY"]//input
	заповнити simple input  ${locator}  ${quantity}  check=${False}


заповнити поле для item unit.name
	[Arguments]  ${unit.name}
	${locator}  set variable  //*[@data-name="EDI"]//input
	заповнити simple input  ${locator}  ${unit.name}


заповнити поле для item classification.id
	[Arguments]  ${classification.id}
	${locator}  set variable  //*[@data-name="MAINCLASSIFICATION"]//input
	заповнити simple input  ${locator}  ${classification.id}


заповнити поле для item additionalClassifications.scheme
	[Arguments]  ${additionalClassifications.scheme}
	${locator}  set variable  //*[@data-name="CLASSIFICATIONSCHEME"]
	${dict}  create dictionary  ДКПП=ДКПП (ДК 016:2010)  ДК003=Классификатор профессий (ДК 003:2010)  ДК015=Классификация видов научно-технической деятельности (ДК 015-97)  ДК018=Государственный классификатор зданий и сооружений (ДК 018-2000)  INN=Спеціальні норми та інше
	заповнити фіксований випадаючий список  ${locator}  ${dict[u'${additionalClassifications.scheme}']}


заповнити поле для item additionalClassifications.description
	[Arguments]  ${additionalClassifications.description}
	${locator}  set variable  //*[@data-name="IDCLASSIFICATION"]//input
	заповнити simple input  ${locator}  ${additionalClassifications.description}


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
	заповнити simple input  ${locator}  ${deliveryAddress.locality}


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







вибрати значення з випадаючого списку в гріді
	[Arguments]  ${locator}  ${text}
	wait until keyword succeeds  5x  1s  run keywords
	...  click element  ${locator}  AND
	...  loading дочекатися відображення елемента на сторінці  ${milestone_dropdown_list}  timeout=3  AND
	...  click element  ${milestone_dropdown_list}//*[text()="${text}"]  AND
	...  loading дочекатись закінчення загрузки сторінки


ввести значення в поле в гріді
	[Arguments]  ${locator}  ${text}
	wait until keyword succeeds  5x  1s  run keywords
	...  click element  ${locator}  AND
	...  loading дочекатися відображення елемента на сторінці  ${locator}//input  timeout=3  AND
	...  input text  ${locator}//input  ${text}  AND
	...  press key  //body  \\09  AND
	...  loading дочекатись закінчення загрузки сторінки


заповнити фіксований випадаючий список
    [Arguments]  ${locator}  ${text}
	wait until keyword succeeds  5x  1s  заповнити фіксований випадаючий список continue  ${locator}  ${text}


заповнити фіксований випадаючий список continue
	[Arguments]  ${locator}  ${text}
	click element  ${locator}//td[3]
	input text  ${locator}//td[2]//input  ${text}
#	click screen header
	press key  //body  \\13
	loading дочекатись закінчення загрузки сторінки
	${get}  get element attribute  ${locator}@value
	should be equal  "${get}"  "${text}"



заповнити simple input
	[Arguments]  ${locator}  ${input_text}  ${check}=${True}
	wait until keyword succeeds  5x  1s  заповнити simple input continue  ${locator}  ${input_text}  ${check}


заповнити simple input continue
    [Arguments]  ${locator}  ${input_text}  ${check}
	${input_text}  evaluate  u"""${input_text}"""
	input text  ${locator}  ${input_text}
#	click screen header
	press key  //body  \\13
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


заповнити поле з датою continue
  	[Arguments]  ${locator}  ${date}
	input text  ${locator}  ${date}
	sleep  .5
#	click screen header
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


активувати вкладку умови оплати
	${selector}  set variable  //*[@class="dx-vam" and contains(., "Умови оплати")]
	click element  ${selector}
	loading дочекатись закінчення загрузки сторінки