************ Set it up ************
* Put the Stata .do file and the .dta data file in the same folder

set more off
global graph_set "ylabel(, nogrid) scheme(s2mono) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))"
global graph_set_by "legend(off) scheme(s2mono)  by(, note("") title(, size(medium)) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))) by(, imargin(medium)) subtitle(, nobox) plotregion(margin(zero))"
global combine_set "scheme(s2mono) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))"

use "ExperimentData_beforeClean.dta", clear

************ Generate relevant variables ************

//"COC Treatment" stands for the CC treatment; "COP Treatment" stands for the CP treatment
label define experiment 1 "COC Treatment" 2 "COP Treatment", replace
label values experiment experiment

// 'payoff_dollar' contains total payoffs in dollars
cap drop payoff_dollar
gen payoff_dollar = totalpayoff/20 + 0.01
sum payoff_dollar

// sex variable
cap drop male
gen male = 1 if gender == 1
replace male = 0 if gender == 2
sum male age payoff_dollar

// calculate duration of the experiment 
cap drop totaltime_sec totaltime_min
global timelist time_welcome time_instructions_0 time_instruct_stage1 time_instruct_stage2a time_instruct_stage2b time_instruct_example time_quiz_stage1 time_stage1start time_decisionstageone time_stage2_a time_stage2_b time_stage2_c time_quizstage2 time_stage2start time_stage2decisionscreen1 time_stage2decisionscreen2 time_decisionstage2_2 time_decisionstage2_3 time_decisionstage2_4 time_decisionstage2_5 time_decisionstage2_6 time_decisionstage2_7 time_decisionstage2_8 time_decisionstage2_9 time_decisionstage2_10 time_questionnaire
egen totaltime_sec = rowtotal($timelist) if others10!=.
gen totaltime_min = totaltime_sec/60 // in minutes 
sum totaltime_min

// identify observations with all decisions data in the variable of 'complete'
cap drop complete
gen complete = 1 if others0!=. & others1!=. & others2!=. & others3!=. & others4!=. & others5!=.  ///
					& others6!=. & others7!=. & others8!=. & others9!=. & others10!=. & stageone!=.
					
// drop those who dropped out beforing finishing the experimental game
keep if complete ==1
count


* --- classify participants into different punishment types based on their punishment strategies in Stage 2 of the game
cap drop punish_type
// 0. non-punishers
gen punish_type = 0 if others0==0 & others1==0 & others2==0 & others3==0 & others4==0 ///
				& others5==0 & others6==0 & others7==0 & others8==0 & others9==0 & others10==0 & complete == 1
// 1. independent punishers
replace punish_type = 1 if others10!=. & punish_type==. & others0 == others1 & others0==others2 & others0==others3 & others0==others4 ///
				& others0==others5 & others0==others6 & others0==others7 & others0==others8 & others0==others9 & others0==others10  & complete == 1
// 2. norm enforcers
replace punish_type = 2 if others10!=. & punish_type==. & others0 <= others1 & others1<=others2 & others2<=others3 & others3<=others4  ///
				& others4<=others5 & others5<=others6 & others6<=others7 & others7<=others8 & others8<=others9 & others9<=others10  & complete == 1
// 3. conformist punishers
replace punish_type = 3 if others10!=. & punish_type==. & others0 >= others1 & others1>=others2 & others2>=others3 & others3>=others4  ///
				& others4>=others5 & others5>=others6 & others6>=others7 & others7>=others8 & others8>=others9 & others9>=others10  & complete == 1	
// 4. the rest
replace punish_type = 4 if punish_type==. & complete == 1

label define punish_type 0 "Never punish" 1 "Independent" 2 "Increasing" 3  "Decreasing" 4 "Others", replace
label values punish_type punish_type

sort punish_type others0
gen id = _n

bysort experiment: tab punish_type 
bysort experiment: tab experiment_session

* We have two waves of data: one collected in 2017 Semptember; one in 2019 Semptember.
//'session19' = 1 for the 2019 data, and 0 for the 2017 data.
cap drop session19
gen session19 = (session > 4 & experiment == 2) | (session > 7 & experiment == 1)

bysort experiment: tab punish_type session19,  column chi2 exact // no statiscally significant differences

* Display percentages for different punishment types
bysort experiment: tab  punish_type if punish_type>0


*********** Examine Quiz Fails ************

// 'quizfailALL' sums up the numbers of all failed attempts for the control questions
cap drop quizfailALL
egen quizfailALL = rowtotal(quiz1_fail quiz2_fail quiz3_fail quiz4_fail quizstage2_1d_fail quizstage2_1e_fail quizstage2_1a_fail quizstage2_1c_fail quizstage2_1b_fail quizfail)

sum quizfailALL
bysort experiment punish_type: sum quizfailALL
by experiment: tab punish_type if quizfailALL < 10


*********** Examine Cooperation Decision in Stage 1 of the Game ************

// 'Coop' = 1 if cooperated in stage 1
cap drop Coop
gen Coop = (stageone == 1) 
tab Coop 
tab Coop experiment,  column chi2 exact


***********  Transform Data form WIDE to LONG for Regressions *********** 

reshape long others, i(id) j(other_punish)
gen punish = others
bysort punish_type: sum punish
cap drop reference_act
gen reference_act = other_punish
codebook reference_act

***********  Regressions ***********  

cap drop male
gen male = (gender == 1 )
cap drop Coop
cap drop prop_Coop  
cap drop prop_Punish  
cap drop prop_C_X_self
cap drop prop_P_X_selfC
cap drop prop_C_X_p50
gen prop_Coop = reference_act if experiment == 1
gen prop_Punish = reference_act if experiment == 2


gen Coop = (stageone == 1) 
gen prop_C_X_self = prop_Coop* Coop if experiment == 1
gen prop_P_X_selfC = prop_Punish* Coop if experiment == 2


** Regressions i-vii in Table S1 in Supplementary Information

eststo clear
*(i)
 eststo: reg punish prop_Coop if experiment == 1 & punish_type!=., cluster(id)
test prop_Coop

tab punish_type if prop_Coop!=.

*(ii)
quietly eststo: reg punish prop_Coop Coop age male if experiment == 1& punish_type!=., cluster(id)
test prop_Coop
test Coop

*(iii)
quietly eststo: reg punish prop_Coop Coop prop_C_X_self age male if experiment == 1& punish_type!=., cluster(id)
test prop_Coop
test Coop
test prop_C_X_self

*(iv)
quietly eststo: reg punish prop_Punish if experiment == 2& punish_type!=., cluster(id)
test prop_Punish

*(v)
quietly eststo: reg punish prop_Punish Coop  age male if experiment == 2& punish_type!=., cluster(id)
test prop_Punish
test Coop

*(vi)
quietly eststo: reg punish prop_Punish Coop prop_P_X_selfC age male if experiment == 2& punish_type!=., cluster(id)
test prop_Punish
test Coop
test prop_P_X_selfC

esttab, b(3) se(3) scalars(N r2) compress star(* 0.05 ** 0.01 *** 0.001) ///
		keep(prop_Coop prop_C_X_self prop_Punish prop_P_X_selfC Coop male age  _cons )
eststo clear

*(vii)
eststo clear
cap drop reference_X_exp 
cap drop punish_exp
gen punish_exp = experiment - 1
gen reference_X_exp = reference_act * punish_exp

quietly eststo: reg punish reference_act reference_X_exp punish_exp Coop male age  if punish_type!=., cluster(id)
test reference_act
esttab, b(3) se(3) scalars(N r2) compress star(* 0.05 ** 0.01 *** 0.001) ///
		keep(reference_act reference_X_exp punish_exp Coop male age _cons )



