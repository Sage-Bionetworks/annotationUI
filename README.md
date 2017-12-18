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
diagnosis | Acute Myeloid Leukemia 
diagnosis | Secondary AML 
diagnosis | Chronic Myeloid Leukemia

or one row per unique keys and a comma separated list of values (one to many relations) ex.

key |value 
--- | ---
diagnosis | Acute Myeloid Leukemia , Secondary AML , Chronic Myeloid Leukemia


### Data release information 
[Sage Bionetworks annotations release versions](https://github.com/Sage-Bionetworks/synapseAnnotations/releases)

[Version format and use](https://github.com/Sage-Bionetworks/synapseAnnotations/blob/master/README.md)

### Use-case documentation 
#### simple steps 
1. Use the global search box to search the entire table for the desired keywords. This will find results in all columns.
2. Select the modules that you need to subset data and get the desired final annotation table.
3. Add your own projects' annotations, given the same schema or with the minimum columns `key` and `value`. See detailed instuctions in `vignettes`
4. You may expand the table view by selecting higher number of rows to be shown.
5. Select/highlight a row with the keys that you'd like. You don't have to select all the rows. Just one row with the desired key would do the trick.
6. Finally, download the manifest or Json structure of the filtered annotations. 

#### detailed steps
`vignettes` folder contains an R markdown with instructive tutorials demonstrating practical uses of the annotationUI shiny app. 

### How to use on a different server 
Replacing the **dat** variable in `global.R` would allow for users to re-define the annotations given the same schema defined as above. 
You can clone or fork this repo and host the app on a private or [shiny server](https://www.rstudio.com/products/shiny/shiny-server/)

### Modular agile flow 
<img src="https://github.com/Sage-Bionetworks/annotationUI/blob/master/img/agile-flow.png" width="450px" height="400px" />

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
```R
R version 3.4.3 (2017-11-30)
Running under: macOS Sierra 10.12.6

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] bindrcpp_0.2         synapseClient_1.15-3 shinyBS_0.61         devtools_1.13.4     
 [5] DT_0.2               data.table_1.10.4-3  jsonlite_1.5         shinydashboard_0.6.1
 [9] openxlsx_4.0.17      ggplot2_2.2.1        tidyr_0.7.2          dplyr_0.7.4         
[13] shiny_1.0.5                            
```
