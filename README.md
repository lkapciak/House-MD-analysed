# House MD analysed
## Aim
The primary aim of this project was to create a poster containing visualization based on *House MD*. However, after looking for datasets long enough, we found out that there really are no `.csv` files containing diagnoses from the series. 
Therefore, we created this repository for all of *House MD* and data science enthusiasts.
Below you can find multiple datasets containing different information about the series. Moreover, `house_md_data.csv` contains most of it within a single file. Finally, you can find our poster with visualization of the data.

## Special thanks 

## Datasets used
|File name|Description|
| --- | --- |
|`house_md_data.csv`|Complete dataset, created in the process of creating the poster from data frame `todo`. Contains almost all of the data about each episode from the other files.|
|`house_imdb.csv`| Dataset containing infomation about episodes from IMDB. Obtained from: https://www.kaggle.com/code/bcruise/house-md-episodes-data-analysis.|
|`house_episodes.csv`|Contains data about each episode's title, creators, air date and number of viewers in the US. Obtained from: https://www.kaggle.com/code/bcruise/house-md-episodes-data-analysis.|
|`seasoni.csv.xls`| 8 datasets containing transcripts from each season. Obtained from: https://www.kaggle.com/datasets/kunalbhar/house-md-transcripts.|
|`icd_codes.csv`|Set containing disease names and their ICD-10 codes. Obtained from: |
|`icd_categories.csv`|Contains disease code and category. Obtained from: and partially manually completed, as some diseases from `icd_codes` did not have a category in `icd_categories`.|
|`icd_categories_raw.csv`| The unprocessed version of `icd_categories`.|
|`diagnoses.xlsm`| List of diagnoses in each of the episodes. Obtained from https://house.fandom.com/wiki/List_of_medical_diagnoses.|
|`diagnosesi.csv`| `diagnoses.xlsm` divided into 8 files; for $i \in [8]$, each file contains diagnoses in each season. These have been then manually corrected, so as to match the ICD names from `icd_codes`.|
|`organs.csv`| Manually created. Contains ICD code, name and organs affected by each diagnosed disease, matching those in `hgFemale_list` from `gganatogram`. IMPORTANT: be aware that this file encoding (unlike UTF-8 used in the other files) is UTF-16 (due to problems with names such as Behçet's disease).|
