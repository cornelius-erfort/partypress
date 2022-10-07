**********************************
* Replication material for 
* Gessler & Hunger
* "How the refugee crisis and radical right parties shape party competition on immigration"
* PSRM
**********************************


set more off
set scheme s1mono

clear all


* cd "C:\Users\scripts\Desktop\SCRIPTS\GitHub\scripts-issue-agendas\replicating-gessler-hunger\_backup"
cd "C:\Users\scripts\Desktop\SCRIPTS\GitHub\scripts-issue-agendas\replicating-gessler-hunger"



* load data
* use "replication.dta" 
use "stata-replication.dta" 
drop if sal == .
drop if polling == .

* prepare data
**********************************
* make year-month variable
generate date_m = mofd(date)
format date_m %tm

* encode party, gen(partyid)
* encode parlgov_id, gen(partyid)

gen partyid = parlgov_id

*sort date_m parlgov_id
*quietly by date_m parlgov_id: gen dup = cond(_N==1,0,_n)
*tab dup
*list if dup != 0

xtset partyid date_m

gen countryid = 0
replace countryid = 1 if country == "AT"
replace countryid = 2 if country == "DE"
* replace countryid = 3 if country == "Switzerland"
replace countryid = 4 if country == "DK"
replace countryid = 5 if country == "ES"
replace countryid = 6 if country == "IE"
replace countryid = 7 if country == "NL"
replace countryid = 8 if country == "PL"
replace countryid = 9 if country == "SE"
replace countryid = 10 if country == "UK"


label define countrylab 1 "Austria" 2 "Germany" 3 "Switzerland" 4 "Denmark" 5 "Spain" 6 "Ireland" 7 "Netherlands" 8 "Poland" 9 "Sweden" 10 "United Kingdom"
label values countryid countrylab

* Still needs to be coded
*gen msp = 0
*replace msp = 1 if partfam == "centre right"
*replace msp = 1 if partfam == "centre left"

*encode crisis, gen(crisisid)

* replace missings with zero
* replace sal_rrp = 0 if sal_rrp ==. // this is problematic?

* Still needs to be coded
*replace keyness_predicted_z_rrp = 0 if keyness_predicted_z_rrp == . 
*replace keyness_predicted_rrp = 0 if keyness_predicted_rrp == . 

* Still needs to be coded
* encode party family variable
*encode partfam, gen(partfamid)

* Still needs to be coded
* encode crisis2 var
*encode crisis2, gen(crisis2id)

* label variables in order to the regression tables look nicer
label var sal "salience of immigration"
label var sal_rrp "salience of RRPs"
label var noref_z "number of asylum applications"
*label var keyness_predicted "position on immigration"
*label var keyness_predicted_rrp "RRP's position on immigration"

* Still needs to be coded
* CR DUMMY
* 2) based on expert knowledge 
* i.e. including liberal parties and BDP
*gen CR = 0
*replace CR = 1 if partfamid == 2
*replace CR = 1 if partfamid == 4

*********************************************************************************
* create interactions by hand - SALIENCE
*gen CR_interac = CR*sal_rrp
*gen CR_interac_repl = CR*sal_rrp

* create interactions by hand - POSITION
*gen CR_interac_pos = CR*keyness_predicted_rrp

********************************************************************

*###################################################################
* MAIN MODELS SALIENCE (table 2, main text)
* ##################################################################

* combined model
xtabond sal sal_rrp L.sal_rrp noref_z polls_ppr refugees_z, vce(robust) lags(2)
outreg2 using model1a, ctitle(all) replace label tex dec(2) pdec(2) 
* test for autocorrelation ************************************************************************
estat abond


* AT
xtabond sal sal_rrp L.sal_rrp noref_z polls_ppr refugees_z if countryid == 1, vce(robust) lags(2)
outreg2 using model1a, ctitle(AT) append  label tex dec(2) pdec(2) 
* DE
xtabond sal sal_rrp L.sal_rrp noref_z polls_ppr refugees_z if countryid == 2, vce(robust) lags(2)
outreg2 using model1a, ctitle(DE) append  label tex dec(2) pdec(2) 

* CH
*xtabond sal sal_rrp L.sal_rrp noref_z polls_ppr refugees_z if countryid == 3, vce(robust) lags(2)
*outreg2 using model1a, ctitle(CH) append label tex dec(2) pdec(2)  

* DK
xtabond sal sal_rrp L.sal_rrp noref_z polls_ppr refugees_z if countryid == 4, vce(robust) lags(2)
outreg2 using model1a, ctitle(DK) append  label tex dec(2) pdec(2) 
* ES
* xtabond sal sal_rrp L.sal_rrp noref_z polls_ppr refugees_z if countryid == 5, vce(robust) lags(2)
* outreg2 using model1a, ctitle(ES) append  label tex dec(2) pdec(2) 
* IE
* xtabond sal sal_rrp L.sal_rrp noref_z polls_ppr refugees_z if countryid == 6, vce(robust) lags(2)
* outreg2 using model1a, ctitle(IE) append  label tex dec(2) pdec(2) 
* NL
xtabond sal sal_rrp L.sal_rrp noref_z polls_ppr refugees_z if countryid == 7, vce(robust) lags(2)
outreg2 using model1a, ctitle(NL) append  label tex dec(2) pdec(2) 
* PL
*xtabond sal sal_rrp L.sal_rrp noref_z polls_ppr refugees_z if countryid == 8, vce(robust) lags(2)
*outreg2 using model1a, ctitle(PL) append  label tex dec(2) pdec(2) 
* SE
xtabond sal sal_rrp L.sal_rrp noref_z polls_ppr refugees_z if countryid == 9, vce(robust) lags(2)
outreg2 using model1a, ctitle(SE) append  label tex dec(2) pdec(2) 
* UK
xtabond sal sal_rrp L.sal_rrp noref_z polls_ppr refugees_z if countryid == 10, vce(robust) lags(2)
outreg2 using model1a, ctitle(UK) append  label tex dec(2) pdec(2) 





* before
xtabond sal sal_rrp L.sal_rrp noref_z polls_ppr refugees_z if crisis2id == 2, vce(robust) lags(2)
outreg2 using model1a, ctitle(before) append label tex dec(2) pdec(2) 
* during
xtabond sal sal_rrp L.sal_rrp noref_z polls_ppr refugees_z if crisis2id == 3, vce(robust) lags(2)
outreg2 using model1a, ctitle(during) append label tex dec(2) pdec(2) 
* after
xtabond sal sal_rrp L.sal_rrp noref_z polls_ppr refugees_z if crisis2id == 1, vce(robust) lags(2)
outreg2 using model1a, ctitle(after) append label tex dec(2) pdec(2) 
* center right
xtabond sal sal_rrp L.sal_rrp CR CR_interac L.CR_interac noref_z polls_ppr refugees_z, vce(robust) lags(2)
outreg2 using model1a, ctitle(center-right) append label tex dec(2) pdec(2) 



*###################################################################
* REPLICATION
* ##################################################################

* combined model
xtabond sal_repl sal_rrp_repl L.sal_rrp_repl noref_z polls_ppr refugees_z, vce(robust) lags(2)
outreg2 using model1a_repl, ctitle(all) replace label tex dec(2) pdec(2) 

* test for autocorrelation ************************************************************************
estat abond
* AT
xtabond sal_repl sal_rrp_repl L.sal_rrp_repl noref_z polls_ppr refugees_z if countryid == 1, vce(robust) lags(2)
outreg2 using model1a_repl, ctitle(AT) append  label tex dec(2) pdec(2) 

* DE
xtabond sal_repl sal_rrp_repl L.sal_rrp_repl noref_z polls_ppr refugees_z if countryid == 2, vce(robust) lags(2)
outreg2 using model1a_repl, ctitle(DE) append  label tex dec(2) pdec(2) 

* CH
* xtabond sal_repl sal_rrp_repl L.sal_rrp_repl noref_z polls_ppr refugees_z if countryid == 3, vce(robust) lags(2)
* outreg2 using model1a_repl, ctitle(CH) append label tex dec(2) pdec(2)  

* before
xtabond sal_repl sal_rrp_repl L.sal_rrp_repl noref_z polls_ppr refugees_z if crisis2id == 2, vce(robust) lags(2)
outreg2 using model1a_repl, ctitle(before) append label tex dec(2) pdec(2) 

* during
xtabond sal_repl sal_rrp_repl L.sal_rrp_repl noref_z polls_ppr refugees_z if crisis2id == 3, vce(robust) lags(2)
outreg2 using model1a_repl, ctitle(during) append label tex dec(2) pdec(2) 

* after
xtabond sal_repl sal_rrp L.sal_rrp_repl noref_z polls_ppr refugees_z if crisis2id == 1, vce(robust) lags(2)
outreg2 using model1a_repl, ctitle(after) append label tex dec(2) pdec(2) 

* center right
xtabond sal_repl sal_rrp L.sal_rrp_repl CR CR_interac_repl L.CR_interac_repl noref_z polls_ppr refugees_z, vce(robust) lags(2)
outreg2 using model1a_repl, ctitle(center-right) append label tex dec(2) pdec(2) 


*###################################################################
* MAIN MODELS POSITION (table 3, main text)
* ##################################################################


* combined model 
xtabond keyness_predicted keyness_predicted_rrp L.keyness_predicted_rrp noref_z polls_ppr refugees_z, vce(robust) lags(2)
outreg2 using model2a, ctitle(all) replace label tex dec(2) pdec(2) 
* test for autocorrelation ************************************************************************
estat abond
* AT
xtabond keyness_predicted keyness_predicted_rrp L.keyness_predicted_rrp noref_z polls_ppr refugees_z if countryid == 1, vce(robust) lags(2)
outreg2 using model2a, ctitle(AT) append  label tex dec(2) pdec(2) 
* DE
xtabond keyness_predicted keyness_predicted_rrp L.keyness_predicted_rrp noref_z polls_ppr refugees_z if countryid == 2, vce(robust) lags(2)
outreg2 using model2a, ctitle(DE) append  label tex dec(2) pdec(2) 
* CH
xtabond keyness_predicted keyness_predicted_rrp L.keyness_predicted_rrp noref_z polls_ppr refugees_z if countryid == 3, vce(robust) lags(2)
outreg2 using model2a, ctitle(CH) append label tex dec(2) pdec(2)
* before
xtabond keyness_predicted keyness_predicted_rrp L.keyness_predicted_rrp noref_z polls_ppr refugees_z if crisis2id == 2, vce(robust) lags(2)
outreg2 using model2a, ctitle(before) append label tex dec(2) pdec(2) 
* during
xtabond keyness_predicted keyness_predicted_rrp L.keyness_predicted_rrp noref_z polls_ppr refugees_z if crisis2id == 3, vce(robust) lags(2)
outreg2 using model2a, ctitle(during) append label tex dec(2) pdec(2) 
* after
xtabond keyness_predicted keyness_predicted_rrp L.keyness_predicted_rrp noref_z polls_ppr refugees_z if crisis2id == 1, vce(robust) lags(2)
outreg2 using model2a, ctitle(after) append label tex dec(2) pdec(2) 
* CR
xtabond keyness_predicted keyness_predicted_rrp L.keyness_predicted_rrp CR CR_interac_pos L.CR_interac_pos noref_z polls_ppr refugees_z, vce(robust) lags(2)
outreg2 using model2a, ctitle(center-right) append label tex dec(2) pdec(2)  


********************************************************************************
* MODELS FOR APPENDIX ##########################################################
********************************************************************************


*************************************************************************************************
* MODELS WITH INTERACTION SEPARATELY FOR COUNTRIES

* SALIENCE
* CR - AT
xtabond sal sal_rrp L.sal_rrp CR CR_interac L.CR_interac noref_z polls_ppr refugees_z if countryid == 1, vce(robust) lags(2)
outreg2 using model1b, ctitle(center-right) replace label tex dec(2) pdec(2) 
* CR - DE
xtabond sal sal_rrp L.sal_rrp CR CR_interac L.CR_interac noref_z polls_ppr refugees_z if countryid == 2, vce(robust) lags(2)
outreg2 using model1b, ctitle(center-right) append label tex dec(2) pdec(2) 
* CR - CH
xtabond sal sal_rrp L.sal_rrp CR CR_interac L.CR_interac noref_z polls_ppr refugees_z if countryid == 3, vce(robust) lags(2)
outreg2 using model1b, ctitle(center-right) append label tex dec(2) pdec(2) 

* POSITION
* CR - AT
xtabond keyness_predicted keyness_predicted_rrp L.keyness_predicted_rrp CR CR_interac_pos L.CR_interac_pos noref_z polls_ppr refugees_z if countryid == 1, vce(robust) lags(2)
outreg2 using model2b, ctitle(center-right) replace label tex dec(2) pdec(2)  
* CR - DE
xtabond keyness_predicted keyness_predicted_rrp L.keyness_predicted_rrp CR CR_interac_pos L.CR_interac_pos noref_z polls_ppr refugees_z if countryid == 2, vce(robust) lags(2)
outreg2 using model2b, ctitle(center-right) append label tex dec(2) pdec(2)
* CR - CH
xtabond keyness_predicted keyness_predicted_rrp L.keyness_predicted_rrp CR CR_interac_pos L.CR_interac_pos noref_z polls_ppr refugees_z if countryid == 3, vce(robust) lags(2)
outreg2 using model2b, ctitle(center-right) append label tex dec(2) pdec(2)