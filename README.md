## Annotation UI 
Each study design and analysis requires a unique set of samples or data. In order to both search and access the correct set of samples and ensure proper downstream evaluations annotations are required. Annotations are metadata that provide some information related to the sample and/or data file of interest (ex. 01 tag on a file name represents samples containing solid tumor tissue). Standardizing annotations enables all researchers, including your future self or organization to access and extract data easily. 
 
With a manifest, we can organize the relation between a data file or sample and its associated annotations in our projects.  A manifest is structured as a matrix. The first column is dedicated to a file's unique id on synapse, which allows for each row to represent a unique file. The remaining fields are named by an informative category (ex. Organ) and the entries of that field are filled with values defining a subcategory related to its data file content (ex. brain). 

To create this manifest, a predefined set of annotations is encouraged. 

Over the course of organizing projects at Sage Bionetworks, our scientists have created project specific annotations that are stored as json files on [github](https://github.com/Sage-Bionetworks/synapseAnnotations). This allows for Sage Bionetworks scientists to meet each week, create, and change a consensus vocabulary with proper sources to organize theirs and users projects while versioning the changes. 

To allow for collaboration and common use of vocabularies with other organizations, each week Sage Bionetwork’s json file’s annotations are systematically normalized into a large [melted table or matrix](https://www.jstatsoft.org/article/view/v059i10). This data is then stored on a synapse table. Although the synapse table has strong features, for ease of use, this shiny app pulls the annotation data and creates a table with search, project selection, addition of user specific annotations, and finally manifest creation and download features. 

Given the heterogeneous processes of each organization, in order to join user specific annotations with this data we ask for a minimal standard input: 

### Standard user-input

The schema to capture the one-to-one pairwise key-value relations is defined as: 
 

 key |description| columnType | maximumSize | value | valueDescription | source | project
--- | --- | --- | --- | --- | --- | --- | --- 

The minimum required fields/columns to hold this relation are  

key |value 
--- | ---

The meta-data columnType ,maximumSize, ensures the schema is compatible with synapse. The key and value description and source of description fields ensures common understating of the terminology definitions. 

The app could parse inputs with having one row per unique value (one to one relations with repeating keys) ex.  

key |value 
--- | ---
diagnosis | AML / Acute Myeloid Leukemia 
diagnosis | SecAML / Secondary AML 
diagnosis | CML / Chronic Myeloid Leukemia

or one row per unique keys and a comma separated list of values (one to many relations) ex.

key |value 
--- | ---
diagnosis | AML / Acute Myeloid Leukemia , SecAML / Secondary AML , CML / Chronic Myeloid Leukemia


### Data release information 
[Sage Bionetworks annotations release versions](https://github.com/Sage-Bionetworks/synapseAnnotations/releases)

[Version format and use](https://github.com/Sage-Bionetworks/synapseAnnotations/blob/master/README.md)

### Use-case documentation 
`vignettes` folder contains an R markdown with instructive tutorials demonstrating practical uses of the annotationUI shiny app. 

### How to use on a different server 
Replacing the **dat** variable in `global.R` would allow for users to re-define the annotations given the same schema defined as above. 
You can clone or fork this repo and host the app on a private or [shiny server](https://www.rstudio.com/products/shiny/shiny-server/)

### Modular agile flow 
<img src="https://github.com/Sage-Bionetworks/annotationUI/blob/master/img/agile-flow.png" width="500px" height="400px" />

1. Define consensus annotations with definitions and source meta data (Format = versioned json files). 

2. Build your projects’ manifest using a User Interface (UI).

3. Annotate your files on synapse using annotation utils functions (update or audit annotations). 

repeat ...
### Run the app locally  

First

1. Register to synapse and create your username and password 
2. Download synapse 
3. Cache your login credentials

See http://docs.synapse.org/articles/getting_started.html for detailed instructions. 

Then you can run 

```R
if (!require('shiny')) install.packages("shiny")
shiny::runGitHub('Sage-Bionetworks/annotationUI')
```
Given the list of dependencies below. 

## Dependendencies 
#### Session info 
------------------------------------------------------------------------------------------
 setting  value                       
 version  R version 3.3.2 (2016-10-31)
 system   x86_64, darwin13.4.0        
 ui       RStudio (1.0.136)           
 language (EN)                        
 collate  en_US.UTF-8                 
 tz       America/Los_Angeles                          

#### Packages 
----------------------------------------------------------------------------------------------
 package        * version  date       source                                          
 assertthat       0.2.0    2017-04-11 CRAN (R 3.3.2)                                  
 base           * 3.3.2    2016-10-31 local                                           
 bindr            0.1      2016-11-13 CRAN (R 3.3.2)                                  
 bindrcpp         0.2      2017-06-17 CRAN (R 3.3.2)                                  
 bitops           1.0-6    2013-08-17 CRAN (R 3.3.0)                                  
 colorspace       1.3-2    2016-12-14 CRAN (R 3.3.2)                                  
 data.table     * 1.10.4   2017-02-01 CRAN (R 3.3.2)                                  
 datasets       * 3.3.2    2016-10-31 local                                           
 devtools       * 1.13.2   2017-06-02 CRAN (R 3.3.2)                                  
 digest           0.6.12   2017-01-27 CRAN (R 3.3.2)                                  
 dplyr          * 0.7.1    2017-06-22 CRAN (R 3.3.2)                                  
 ggplot2        * 2.2.1    2016-12-30 CRAN (R 3.3.2)                                  
 glue             1.1.1    2017-06-21 CRAN (R 3.3.2)                                  
 graphics       * 3.3.2    2016-10-31 local                                           
 grDevices      * 3.3.2    2016-10-31 local                                           
 grid             3.3.2    2016-10-31 local                                           
 gtable           0.2.0    2016-02-26 CRAN (R 3.3.0)                                  
 htmltools        0.3.6    2017-04-28 CRAN (R 3.3.2)                                  
 httpuv           1.3.5    2017-07-04 CRAN (R 3.3.2)                                  
 jsonlite         1.5      2017-06-01 CRAN (R 3.3.2)                                  
 lazyeval         0.2.0    2016-06-12 CRAN (R 3.3.0)                                  
 magrittr         1.5      2014-11-22 CRAN (R 3.3.0)                                  
 memoise          1.1.0    2017-04-21 CRAN (R 3.3.2)                                  
 methods        * 3.3.2    2016-10-31 local                                           
 mime             0.5      2016-07-07 cran (@0.5)                                     
 munsell          0.4.3    2016-02-13 CRAN (R 3.3.0)                                  
 openxlsx       * 4.0.17   2017-03-23 CRAN (R 3.3.2)                                  
 pkgconfig        2.0.1    2017-03-21 CRAN (R 3.3.2)                                  
 plyr             1.8.4    2016-06-08 CRAN (R 3.3.0)                                  
 R6               2.2.2    2017-06-17 CRAN (R 3.3.2)                                  
 Rcpp             0.12.12  2017-07-15 CRAN (R 3.3.2)                                  
 RCurl            1.95-4.8 2016-03-01 CRAN (R 3.3.0)                                  
 rjson            0.2.15   2014-11-03 CRAN (R 3.3.0)                                  
 rlang            0.1.1    2017-05-18 CRAN (R 3.3.2)                                  
 scales           0.4.1    2016-11-09 CRAN (R 3.3.2)                                  
 shiny          * 1.0.3    2017-04-26 CRAN (R 3.3.2)                                  
 shinyBS        * 0.61     2015-03-31 CRAN (R 3.3.0)                                  
 shinydashboard * 0.6.1    2017-06-14 CRAN (R 3.3.2)                                  
 stats          * 3.3.2    2016-10-31 local                                           
 synapseClient  * 1.15-0   2017-05-25 Github (Sage-Bionetworks/rSynapseClient@2be9324)
 tibble           1.3.3    2017-05-28 CRAN (R 3.3.2)                                  
 tidyr          * 0.6.3    2017-05-15 CRAN (R 3.3.2)                                  
 tools            3.3.2    2016-10-31 local                                           
 utils          * 3.3.2    2016-10-31 local                                           
 withr            1.0.2    2016-06-20 CRAN (R 3.3.0)                                  
 xtable           1.8-2    2016-02-05 CRAN (R 3.3.0)   
