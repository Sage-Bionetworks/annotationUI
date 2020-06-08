#-------------------------------------------------------------
# Server function assembles input and outputs from ui object 
# and renders *in from and *out of a web page
# inputs can be toggled by user 
# outputs are information displays 
#-------------------------------------------------------------
server <- function(input, output, session) {
  # use the same name from output functions in ui
  # render function creates the type of output
  observe({
    updateCheckboxGroupInput(
      session, 'cat', choices = categories,
      selected = if (!input$allNone) categories 
    )
  })
  
  dataOut <- reactive({
    
    if (length(input$cat) > 0) {
      # filter by user-defined project category 
      dat[which(dat$module %in% input$cat),]
    }else{
      if (length(input$cat) == 0) {
        shiny::validate(
          need(length(input$cat) != 0, "Select a Sage Bionetworks module.\n\n You may also upload your annotations to download a manifest. \n\n ")
        )
      }else{
        dat
      }
    }
  })
  
  userData <- reactive({
    
    file <- input$userAnnot
    
    # check if file exists 
    # shiny::validate(
    #   need(file, "Your csv file can't be located. Please try again! \n\n ")
    # )
    
    user.project <- input$projectName
    
    # check if project name exists 
    # shiny::validate(
    #   need(user.project, "Please enter your module name. \n\n ")
    # )
    
    # Trim whitespaces in project name
    user.project <- trimws(user.project)
    
    # Upload user annotaions 
    # Use fread function to catch user defined formats, handle large files, and execute correct errors as needed
    user.dat <-  data.table::fread(file$datapath, encoding = "UTF-8", fill = TRUE, blank.lines.skip = TRUE, na.strings = c("",NA,"NULL") , data.table = FALSE)
    
    # then check for standard input columns 
    # shiny::validate(
    #   need(c("key", "value") %in% colnames(user.dat), "Please provide key and value fields in your csv")
    # )
    
    standard.sage.colnames <- c("description", "columnType", "maximumSize", "valueDescription", "source", "module")
    columns <- which(colnames(user.dat) %in% standard.sage.colnames)

    # Keep key and value column first, then other Sage columns
    user.dat <- user.dat[, c("key", "value", colnames(user.dat)[columns])]
    
    # Remove rows with empty string in key column or NAs in all columns
    user.dat <- user.dat[user.dat$key != "", ]
    user.dat <- user.dat[rowSums(is.na(user.dat)) < ncol(user.dat), ]
    
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
      final.dat[,c("description", "columnType", "maximumSize", "valueDescription", "source")] <- NA
    }
    
    if (length(columns) > 0) {
      
      missing.columns <- standard.sage.colnames[which(!c(c("key", "value"), columns) %in% standard.sage.colnames)]
      # build standard schema
      final.dat[ ,missing.columns] <- NA
    }
    
    # pass in projects name
    final.dat[ ,"module"] <- user.project
    
    if (length(input$cat) != 0) {
      final.dat <- rbind(dataOut(), final.dat)
      final.dat
    }else{
      final.dat
    }
    
  })
  
  output$annotationTable <- DT::renderDataTable({
    
    if (!is.null(input$userAnnot)) {
      table <- userData()
    }else{
      table <- dataOut() 
    }
    table
    
  }, options = list(pageLength = 10, lengthMenu = c(10, 25, 50, 100, 1000), style = 'overflow-x: auto'), rownames = FALSE, server = FALSE, filter = "bottom") 
  
  output$downloadSchema <- downloadHandler(
    filename <- function() {'annotations_manifest.xlsx'},
    content <- function(filename) {
      
      # get user-defined table to download 
      if (!is.null(input$userAnnot)) {
        user.table <- userData()
        
      }else{
        user.table <- dataOut() 
      }
      
      # extract a unique key to define the manifest columns
      if (length(input$annotationTable_rows_selected)) {
        
        user.cols <- unique(user.table[input$annotationTable_rows_selected, 'key'])
        user.table <- user.table[which(user.table$key %in% user.cols), ]
        
      }else{
        
        user.cols <- unique(user.table[["key"]])
      }
      
      # create the manifest schema 
      schema <- generate_manifest_template(user.cols)
      
      # create the key and key-value description dataframes
      key.description <- generate_key_description(user.table)
      value.description <- generate_value_description(user.table)
      # create three sheets including: 
      #     1. manifest columns       #     2. key descriptions 
      #     3. value descriptions (key-value)
      sheets <- list(manifest = schema , keyDescription = key.description, keyValueDescription = value.description)
      write_manifest(sheets, filename)
    }
  )
  
  output$keyDescription <- DT::renderDataTable({
    
    if (!is.null(input$userAnnot)) {
      selected.table <- userData()
    }else{
      selected.table <- dataOut() 
    }
    
    
    # create the key description dataframes
    key.description <- generate_key_description(selected.table)
    key.description
    
  }, options = list(pageLength = 10, lengthMenu = c(10, 25, 50, 100, 1000), style = 'overflow-x: auto'), rownames = FALSE, server = FALSE, filter = "bottom")
  
  output$valueDescription <- DT::renderDataTable({
    
    if (!is.null(input$userAnnot)) {
      selected.table <- userData()
    }else{
      selected.table <- dataOut() 
    }
    
    value.description <- generate_value_description(selected.table)
    value.description
    
  }, options = list(pageLength = 10, lengthMenu = c(10, 25, 50, 100, 1000), style = 'overflow-x: auto'), rownames = FALSE, server = FALSE, filter = "bottom")
  
  output$downloadJSON <- downloadHandler(
    
    filename <- function() {'annotations.json'},
    
    content <- function(filename) {
      
      # get user-defined table to download 
      if (!is.null(input$userAnnot)) {
        user.table <- userData()
      }else{
        user.table <- dataOut() 
      }
      
      # extract selected rows keys to slice the dataframe
      if (length(input$annotationTable_rows_selected)) {
        
        user.cols <- unique(user.table[input$annotationTable_rows_selected, 'key'])
        user.table <- user.table[which(user.table$key %in% user.cols), ]
        
      }
      
      user.table <- as.data.frame(user.table, stringsAsFactors = F)
      nested.list  <- lapply(unique(user.table$module), function(m){
        
        this.module <- user.table[which(user.table$module %in% m),]
        
        each.key.slice <- lapply(unique(this.module$key), function(k){
          this.key <- user.table[which(user.table$key %in% k),]
          return(this.key)
        })
        
        nested.value.list <- lapply(each.key.slice, function(v){
          # replace NA's with empty string
          v[is.na(v)] <- ""
          
          # select the value metadata columns
          enumValues <- dplyr::select(v, value, valueDescription, source)
          names(enumValues)[2] <- "description"
          # removes _row 
          rownames(enumValues) <- NULL
          enumValues.json <- toJSON(enumValues, pretty = T)
          
          # select the key metadata columns
          key <- dplyr::select(v, key, description, columnType, maximumSize)
          # replace key with name to match json
          names(key)[1] <- "name"
          # only need one unique key row
          key <- key[1, ]
          
          if (key$columnType == "BOOLEAN") {
            enumValues$value <- as.logical(enumValues$value)
          }
          
          # remove all empty enumvalues 
          enumValues <- enumValues[!(enumValues$value == "" & enumValues$description == "" & enumValues$source == ""), ]
          
          key$enumValues <- list(enumValues)
          # removes _row 
          rownames(key) <- NULL
          return(key)
        })
        nv <- do.call(rbind, nested.value.list)
        return(nv)
      })
      
      all.modules <- do.call(rbind, nested.list)
      all.modules.json <- jsonlite::toJSON(all.modules , pretty = T)
      writeLines(all.modules.json, filename)
    }
  )
  
  # allow refresh to run locally without a server 
  # session$allowReconnect("force")
  
  # automatically stop the app session after closing the browser tab
  session$onSessionEnded(stopApp)
}
