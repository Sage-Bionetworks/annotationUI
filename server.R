#-------------------------------------------------------------
# Server function assembles input and outputs from ui object 
# and renders *in from and *out of a web page
# inputs can be toggled by user 
# outputs are information displays 
#-------------------------------------------------------------
server <- function(input, output, session) {
  # use the same name from output functions in ui
  # render function creates the type of output
  dataOut <- reactive({
    
    validate(
      need(length(input$cat) != 0, "Select a Sage Bionetworks project.\n\n You may also upload your annotations to download a manifest. \n\n ")
    )
    
    if (length(input$cat) > 0) {
      # filter by user-defined project category 
      data.output <- dat[which(dat$project %in% input$cat),]
      data.output
    }
    else{
      data.output
    }
  })
  ?reactive
  userData <- reactive({
    
    file <- input$userAnnot
    
    # check if file exists 
    validate(
      need(file, "Your csv file can't be located. Please try again! \n\n ")
    )
    
    user.project <- input$projectName
 
    # check if project name exists 
    validate(
      need(user.project, "Please enter your projects name. \n\n ")
    )
    
    # Trim whitespaces in project name
    user.project <- trimws(user.project)
    
    # Upload user annotaions 
    # Use fread function to catch user defined formats, handle large files, and execute correct errors as needed
    user.dat <-  fread(file$datapath, encoding = "UTF-8", fill = TRUE, blank.lines.skip = TRUE, na.strings = c("",NA,"NULL") , data.table = FALSE)
    
    # then check for standard input columns 
    validate(
      need(c("key", "value") %in% colnames(user.dat), "Please provide key and value fields in your csv")
    )
    
    standard.sage.colnames <- c("description", "columnType", "maximumSize", "valueDescription", "valueSource", "project")
    columns <- which(colnames(user.dat) %in% standard.sage.colnames)
    
    if (length(columns) == 0) {
      
      # extract only key and value columns 
      user.dat <- user.dat[,c("key", "value")]
      user.dat <- user.dat[which(!user.dat == ""), ]
      user.dat <- user.dat[rowSums(is.na(user.dat)) != 2, ]
      
    }
    
    if (length(columns) > 0) {
      
      # extract key, value, and standard sage columns
      n <- length(c(c("key", "value"), columns))
      user.dat <- user.dat[ ,c(c("key", "value"), columns)]
      user.dat <- user.dat[which(!user.dat == ""),]
      user.dat <- user.dat[rowSums(is.na(user.dat)) != n, ]
      
    }
    
    # extract complete cases of values or keys     
    value <- user.dat$value[!is.na(user.dat$value)]
    key.values <- user.dat$key[!is.na(user.dat$value)]
    many.values <- as.data.frame(cbind(key.values, value))
    
    # check if user provided list of comma seperated values  
    if (any(grepl(",", user.dat$value))) {
      
      # seperate values by , and make one-to-one relation between key-values
      values <- strsplit(many.values$value, "[,]")
      
      # unnest or normalize each value to key relation 
      normalized <- lapply(seq_along(many.values$key.values), function(i){
        df <- lapply(seq_along(values[[i]]), function(j){
          cbind(many.values$key.values[[i]], values[[i]][[j]])
        })
        df <- do.call(rbind, df)
        return(df)
      })
      
      normalized <- as.data.frame(do.call(rbind, normalized), stringsAsFactors = F)
      names(normalized) <- c("key", "value")
      
      # extract keys without pre-defined values (ex. patientID where it could be left as NA due to privacy or timing)
      only.keys <- as.data.frame(user.dat$key[!is.na(user.dat$key)][which(!user.dat$key[!is.na(user.dat$key)] %in% unique(normalized$key))], stringsAsFactors = F)
      
      if (length(only.keys) == 0) {
        
        names(only.keys) <- "key"
        only.keys[ ,"value"] <- NA
        final.dat <- rbind(only.keys, normalized)
        
      }else{
        
        final.dat <- normalized
      }
      
    }else{
      
      final.dat <- user.dat
    }
    
    if (length(columns) == 0) {
      
      # build standard schema
      final.dat[,c("description", "columnType", "maximumSize", "valueDescription", "valueSource")] <- NA
    }
    
    if (length(columns) > 0) {
      
      missing.columns <- standard.sage.colnames[which(!c(c("key", "value"), columns) %in% standard.sage.colnames)]
      # build standard schema
      final.dat[ ,missing.columns] <- NA
    }
    
    # pass in projects name
    final.dat[ ,"project"] <- user.project
    
    if (length(input$cat) != 0) {
      final.dat <- rbind(dataOut(), final.dat)
      final.dat
    }else{
      final.dat
    }
    
  })

  output$annotationTable <- shiny::renderDataTable({
  
    dataOut() 
  
  },options = list(lengthMenu = c(2, 5, 10, 50, 100, 1000), pageLength = 5, scrollX = TRUE, style = 'overflow-x: auto'))
  
  
  output$downloadSchema <- downloadHandler(
    filename <- function() {'annotations_manifest.xlsx'},
    content <- function(file) {
      
      # get user-defined table to download 
      user.table <- userData()
      
      # add columns for synapse projects 
      first.cols <- c("synapseId", "fileName")
      
      # extract a unique key to deine the manifest columns
      user.cols <- unique(user.table[["key"]])
      
      # create the manifest schema 
      columns <- append(c("synapseId", "fileName"), user.cols)
      schema <- data.frame(matrix(ncol = length(columns), nrow = 0))
      colnames(schema) <- columns
      
      # create the key and key-value description dataframes
      key.description <- user.table[,c("key", "description", "columnType", "project")]
      value.description <- user.table[,c("key", "value", "valueDescription", "valueSource", "project")]
      
      # create three sheets including: 
      #     1. manifest columns 
      #     2. key descriptions 
      #     3. value descriptions (key-value)
      sheets <- list(manifest = schema , keyDescription = key.description, keyValueDescription = value.description)
      openxlsx::write.xlsx(sheets, file)
    }
  )
  
  # allow refresh to run locally without a server 
  # session$allowReconnect("force")
  
  # automatically stop the app session after closing the browser tab
  session$onSessionEnded(stopApp)
}
