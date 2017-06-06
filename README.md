## Annotation UI 
Each study design and analysis requires a unique set of samples or data. In order to both search and access the correct set of samples and ensure proper downstream evaluations annotations are required. Annotations are metadata that provide some information related to the sample and/or data file of interest (ex. 01 tag on a file name represents samples containing solid tumor tissue). Standardizing annotations enables all researchers, including your future self or organization to access and extract data easily. 
 
With a manifest, we can organize the relation between an annotation and sample.  A manifest is structured as a matrix. The first column is dedicated to a file's unique id, which allows for each row to represent a unique file. The remaining fields are named by an informative category (ex. organ) and the entries of that field are filled with values defining a subcategory associated to its data file content (ex. blood). This information can easily be stored as a dictionary of key (field/column names) and value(s). 

### Standard user-input
The schema to capture the one-to-one pairwise key-value relations is defined as: 
 
 key |description| columnType | maximumSize | value | valueDescription | valueSource | project
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

### Use-case documentation 
`vignettes` folder contains an R markdown and knitted html file with instructive tutorials demonstrating practical uses of the annotationUI shiny app. 

### How to use on a different server 
