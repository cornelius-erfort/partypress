**********************************
* Replication material for 
* Gessler & Hunger
* "How the refugee crisis and radical right parties shape party competition on immigration"
* PSRM
**********************************


set more off
set scheme s1mono

clear all

cd

* load data
use "stata-replication_rrp.dta" 
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
outreg2 using model1a, ctitle(all) replace label tex dec(2) pdec(2)  alpha(0.001, 0.01, 0.05)
* test for autocorrelation ************************************************************************
estat abond


* AT
xtabond sal sal_rrp L.sal_rrp noref_z polls_ppr refugees_z if countryid == 1, vce(robust) lags(2)
outreg2 using model1a_rrp, ctitle(AT) append  label tex dec(2) pdec(2)  alpha(0.001, 0.01, 0.05)
* DE
xtabond sal sal_rrp L.sal_rrp noref_z polls_ppr refugees_z if countryid == 2, vce(robust) lags(2)
outreg2 using model1a_rrp, ctitle(DE) append  label tex dec(2) pdec(2)  alpha(0.001, 0.01, 0.05)

* CH
*xtabond sal sal_rrp L.sal_rrp noref_z polls_ppr refugees_z if countryid == 3, vce(robust) lags(2)
*outreg2 using model1a_rrp, ctitle(CH) append label tex dec(2) pdec(2)  

* DK
xtabond sal sal_rrp L.sal_rrp noref_z polls_ppr refugees_z if countryid == 4, vce(robust) lags(2)
outreg2 using model1a_rrp, ctitle(DK) append  label tex dec(2) pdec(2)  alpha(0.001, 0.01, 0.05)
* ES
* xtabond sal sal_rrp L.sal_rrp noref_z polls_ppr refugees_z if countryid == 5, vce(robust) lags(2)
* outreg2 using model1a_rrp, ctitle(ES) append  label tex dec(2) pdec(2) 
* IE
* xtabond sal sal_rrp L.sal_rrp noref_z polls_ppr refugees_z if countryid == 6, vce(robust) lags(2)
* outreg2 using model1a_rrp, ctitle(IE) append  label tex dec(2) pdec(2) 
* NL
xtabond sal sal_rrp L.sal_rrp noref_z polls_ppr refugees_z if countryid == 7, vce(robust) lags(2)
outreg2 using model1a_rrp, ctitle(NL) append  label tex dec(2) pdec(2)  alpha(0.001, 0.01, 0.05)
* PL
xtabond sal sal_rrp L.sal_rrp noref_z polls_ppr refugees_z if countryid == 8, vce(robust) lags(2)
outreg2 using model1a_rrp, ctitle(PL) append  label tex dec(2) pdec(2)  alpha(0.001, 0.01, 0.05)
* SE
xtabond sal sal_rrp L.sal_rrp noref_z polls_ppr refugees_z if countryid == 9, vce(robust) lags(2)
outreg2 using model1a_rrp, ctitle(SE) append  label tex dec(2) pdec(2)  alpha(0.001, 0.01, 0.05)
* UK
xtabond sal sal_rrp L.sal_rrp noref_z polls_ppr refugees_z if countryid == 10, vce(robust) lags(2)
outreg2 using model1a_rrp, ctitle(UK) append  label tex dec(2) pdec(2)  alpha(0.001, 0.01, 0.05)




