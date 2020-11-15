# Calculating Reproduction Number Using R
A guide for estimating reproduction number targeted towards epidemiologists with a beginner-level understanding of R

## For whom is this guide? Epidemiologists who...
* Do not have access to proprietary statistical software such as SAS and Stata
* Do not have any background in any statistical programming language
* Understand the calculation behind reproduction number but do not know how to execute the calculation programmatically
  * If you wish to learn more about the **theory behind the reproduction number**, please refer to the following reference: [Annunziato A. and Asikainen T. (2020). *Effective Reproduction Number Estimation from Data Series*. European Commission Joint Research Centre Technical Report.](https://publications.jrc.ec.europa.eu/repository/bitstream/JRC121343/r0_technical_note_v3.4.pdf)
* Work collaboratively in the context of an ongoing infectious disease outbreak

## Getting started with R
* We need to first install the open-source programming language and environment R, together with RStudio, an integrated development environment (IDE) for R.
* [TechVidVan has a great starter guide on how to install R and RStudio meant for beginners on all types of operating systems](https://techvidvan.com/tutorials/install-r/)
* On its own, R doesn't really do much. This is where packages come in. [DataCamp has a great guide to understanding what R packages are, formatted like Frequently Asked Questions (FAQs)](https://www.datacamp.com/community/tutorials/r-packages-guide)
* Opening RStudio for the first time may be overwhelming. [Antoine Soetewey's Stats and R blog has a beginner-level introduction to the RStudio interface]( https://www.statsandr.com/blog/how-to-install-r-and-rstudio/#the-main-components-of-rstudio)
* Finally, hbctraining has an [excellent beginner's guide to the R syntax and data structures](https://hbctraining.github.io/Intro-to-R/lessons/02_introR-syntax-and-data-structures.html).

## Tidy Data Principles
Often, the data we have as part of routine surveillance activities may not be the version ready for any type of statistical analysis. This raw data MUST be processed into tidy data. At the basic level, tidy data MUST HAVE:
* Each row = one observation representing the unit of analysis
* Each column = one variable
* Each cell = standard data format, usually defined by a coding manual
* If there are going to be multiple tables, there should be an identifying (ID) variable linking tables together.

Tidy data MUST NOT HAVE:
* Any blanks, unless these are true missing data
* Minimizes the use of special characters
* Have merged cells ANYWHERE - merged cells are good visually but not for analysis
* colors to identify variables - these must be defined as a new column (variable), as colors cannot be read into analysis

For example, say we have five COVID-19 confirmed cases, and our raw data looks something like this on a spreadsheet:

![Raw data from surveillance example](https://i.ibb.co/xMHy3T9/RawData.png)

This raw data file:
* Does not have a standard format for the cells - the dates are all encoded inconsistently
* Has merged cells horizontally and vertically
* "Flattens" the tests together with the cases
* Has colored cells but no explanation - in this case, the yellow ones were the latest reported cases (in this hypothetical case, it is Oct 2) and then the rest of the rows have no indication of when they were reported

We should split the data into two tables: one where each row is a case, another where each row is a test. The two tables are linked by a common, static ID. A tidy data version of the file above could look something like this instead:

The first table (each row = confirmed case)

| ID   | DateOnset  | Municipality | Community      | DateReport |
| ---: | ---:       | :---         | :---           | --:        |
| 1    | 2020-09-27 | Funky Town   | Highland Z     | 2020-10-01 |
| 2    | 2020-09-26 | Funky Town   | Highland Y     | 2020-10-01 |
| 3    | 2020-09-28 | Providence   | People Village | 2020-10-02 |
| 4    | 2020-09-25 | Border Town  | Crescent Hill  | 2020-09-30 |
| 5    | 2020-09-30 | New Horizons | Block A1       | 2020-10-02 |

The second table (each row = test)

| ID   | DateTest   | Result   |
| ---: | ---:       | :---     |
| 1    | 2020-09-30 | Positive |
| 2    | 2020-09-30 | Positive |
| 2    | 2020-10-02 | Positive |
| 3    | 2020-10-01 | Positive |
| 4    | 2020-09-29 | Positive |
| 4    | 2020-10-03 | Negative |
| 5    | 2020-10-01 | Positive |

Additionally, there should be some sort of coding manual. For example:
* ID: Unique ID assigned to each confirmed case (when a case has been assigned two ID numbers, discard the latest ID number and move on - DO NOT shift ID numbers upward)
* DateOnset: Date of symptom onset as reported by the patient (format: YYYY-MM-DD)
* Municipality: Municipality indicated in the current address reported by the patient (Names according to official geographic listing of national statistical authority)
* Community: Community indicated in the current address reported by the patient (Names according to official geographic listing of national statistical authority)
* DateReport: Date when case was officially reported to the surveillance system (format: YYYY-MM-DD)
* DateTest: Date when case was swabbed for confirmatory testing (format: YYYY-MM-DD)
* Result: Result of test conducted (Positive, Negative, Equivocal, Invalid)

You may prepare the tidy data using a spreadsheet program, which may be familiar to most, but it is much better to prepare the tidy data using R by feeding the raw data as is, although this requires some basic knowledge of data cleaning in R and takes quite a big of trial and error when doing it for the first time. It would even be better if the data structure of the raw data itself would be revised to make it more analysis-friendly.

To learn more about tidy data, refer to the following reference by Hadley Wickham [(Paper)](http://vita.had.co.nz/papers/tidy-data.pdf) [(Video)](http://vimeo.com/33727555)

## Packages to Install
You only need to install packages once in R. An internet connection is required.

We will need five packages:
* The data analysis package `tidyverse`
* The data cleaning package `janitor`
* The reproduction number package `R0`
* The incidence package `incidence`
* The Excel spreadsheet exporter package `writexl`

To install packages for the first time, go to the `Console` window (bottom right by default) and type the code `install.packages("package")`, replace package inside the quotes with each of the four packages above. Specifically, and do this one at a time:
* `install.packages("tidyverse")`
* `install.packages("janitor")`
* `install.packages("R0")`
* `install.packages("incidence")`
* `install.packages("writexl")`

When prompted for a server, choose the server nearest to your current location for the fastest possible download. You will know when any command in R is done running when you see the `>` symbol show up on the bottommost part of the `Console` window again.

The actual commands for estimating reproduction number will be in the [Reproduction Number Code guide](https://neljasonhaw.github.io/ReproductionNumber/Reproduction-Number-Code.html).
