# Google Mobility Data for India

![trends](https://raw.githubusercontent.com/advaitmoharir/google_mob/main/3_clean/trends.jpg)

This repo consists of Google's Community 19 Mobility Report data for India at the district level, daily over the period 15th February 2020 to 15th October 2022. The data is publicly available [here](https://www.google.com/covid19/mobility/data_documentation.html?hl=en). My small contribution here is to match the districts to the local government directory (LGD codes), which allows for easy merging with datasets to conduct any empirical analysis at the district level!

## Repo Structure

You will find the following folders above

- `1_raw`: TRaw csvs, lgd keys and handmatched district data
- `2_code`: do file needed to clean and produce the matched data
- `3_clean`: Final cleaned dataset

## Cleaning Instructions

In case you want to generate the dataset from scratch, follow the steps below:

1. Open `google_mob.stpr`
2. From within the Stata project, open `2_code/clean.do` and run the file.
3. This generate `google_mobility_data.dta` and `google_mobility_data.csv`

![trends](https://raw.githubusercontent.com/advaitmoharir/google_mob/main/3_clean/heatmap.jpg)
