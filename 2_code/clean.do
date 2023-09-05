/*---------------------------------
File: clean.do
Purpose: Cleaning google mobility data and matching with lgd codes
Authors: Advait Moharir
Status: Complete
--------------------------------------*/

/*-------------------------------------
SECTION 0: Setup
--------------------------------------*/


here, set

// Set globals and locals

global raw "1_raw"
global code "2_code"
global clean "3_clean"



/*-------------------------------------
SECTION 1: Cleanup Google Mobility Data csvs
--------------------------------------*/

foreach i in 2020 2021 2022{
	import delimited using "$raw/google_mobility_`i'.csv", clear
	keep sub_region* date  *percent* place_id
	
	// Generating relevant time vars
	
	gen date1=date(date, "YMD")
	drop date
	rename date1 date
	
	gen mnth=mofd(date)
	gen year=yofd(date)
	
	format mnth %tmMon
	format date %td
	
	
	
	// Rename vars
	
	rename sub_region_1 state
	rename sub_region_2 district
	rename retail_and_recreation_percent_ch retail_rec
	rename grocery_and_pharmacy_percent_cha grocery_pharm	
	rename parks_percent_change_from_baseli parks
	rename transit_stations_percent_change_ transit	
	rename workplaces_percent_change_from_b	workplaces
	rename residential_percent_change_from_ residential

	//Label vars
	
	la var state "State name"
	la var district "District name"
	la var retail_rec "Retail and recreation (% change from baseline)"
	la var grocery_pharm "Grocery and pharmacy (%change from baseline)"
	la var parks "Parks (% change from baseline)"
	la var transit "Transit (% change from baseline)"
	la var workplaces "Workplaces (% change from baseline)"
	la var residential "Residential (% change from baseline)"
	la var date "Date"
	la var mnth "Month"
	la var year "Year"
	
	
	
	//Save yearwise data as tempfiles
	
	drop if mi(state)|mi(district) // Drop all India vars
	tempfile google_`i'
	save `google_`i'', replace

}

// Append 2020 and 2021 tempfiles

append using `google_2021', force
append using `google_2020', force


// Save complete dataset as tempfile

tempfile google
save `google', replace

/*-------------------------------------
SECTION 2: District handmatching
--------------------------------------*/

// Collapse at district level for handmatching

collapse retail_rec, by(district state)
drop retail_rec

// Cleanup lgd_key 

preserve
use "$raw/lgd_key.dta", clear
replace state=strproper(state)
replace district=strproper(district)
tempfile lgd
save `lgd', replace
restore


// merge on text

merge 1:1 state district using `lgd',force
drop if _merge==2  // Drop districts that Google has no data for.

// Pull out unmatched districts as csv for hand matching

preserve
keep if _merge==1
keep state district
export delimited using "$raw/unmatched_districts_google.csv", replace
restore

// Merge back with matched districts

preserve
import delimited using "$raw/handmatched_dist.csv", clear
drop district
rename district_google district
save "$raw/handmatched_dist.dta", replace
restore

// Append corrected data

append using "$raw/handmatched_dist.dta"
drop if mi(lgd_distcode) // Drops the redundant rows prior to corrections

drop _merge // No need for merge variable

/*-------------------------------------
SECTION 3: Final dataset + some exhibits
--------------------------------------*/


// Merge back with google dataset

merge 1:m state district using `google', force nogen keep(3)
drop if mi(lgd_distcode)



sort mnth year date state district
order date mnth year state district

save "$clean/google_mobility_data.dta", replace

/*

// Simple visualization of trends (Uncomment to reproduce)

collapse (mean) retail_rec-residential, by(mnth year)

format mnth %tmMon-ccyy

graph twoway (line retail_rec mnth) || (line grocery_pharm mnth) || (line parks mnth) || (line transit mnth) || (line workplace mnth) || (line residential mnth), legend(label(1 "Retail/Recreation") label(2 "Grocery/Pharm") label(3 "Parks") label(4 "Transit") label(5 "Workplace") label(6 "Residential"))

graph export "$clean/trends.pdf", replace

// Correlation heatmap

correlate retail_rec-residential
return list
matrix corrmat=r(C)

heatplot corrmat, values(format(%4.3f) size(medium)) legend(off) color(hcl diverging, intensity(.7))

graph export "$clean/heatmap.pdf", replace

*/