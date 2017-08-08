# UI component  -----------------------------------------------
# UI component generates the HTML 
# HTML: hypertext markup language 
# •	Hypertext: Interactive text or overcoming the constrains of text. 
# •	Markup: Is marking up different sections of a page as lists, links, 
#   or even specifying its attributes or changing font size
# HTML language is written by “tags” while its content is 
# preserved inside the opening and closing tags.  
# Different web browsers (ex. Firefox, Chrome,…) read .html files and 
# display it (idea is to be consistent and similar)
#-------------------------------------------------------------
# https://rstudio.github.io/shinydashboard/structure.html
body <- dashboardBody(
  fluidRow(
      shiny::dataTableOutput('annotationTable'), 
      downloadButton('downloadSchema', 'Download Manifest')
  )
)

sidebar <- dashboardSidebar(
  sidebarMenu(id = "projectCategory",
              
    # menuItem("Project Category", tabName = "Project Category", icon = icon("info")),
    checkboxGroupInput("cat", "Annotation Modules",
                       choiceNames = categories,
                       choiceValues = categories, 
                       selected = categories),
    bsTooltip("projectCategory", "Select the modules \\ that contain the annotations \\ required for your project",
              "right"),
    tags$hr()
  ),
  # Long list requires scrolling or CSS widgets to controll the length 
  # possible collisions with category 
  # sidebarMenu(id = "valueCategory",
  #   checkboxGroupInput("keyCat", "Values",
  #                       choiceNames = value,
  #                       choiceValues = value,
  #                       selected = value),
  #   tags$hr()
  # ),
  sidebarMenu(id = "upload",
    # menuItem("Upload annotations", tabName = "Upload annotations", icon = icon("info")),
    p(strong("Upload Your Annotation's Module"), align = "center"), 
    textInput("projectName", "Module Name"),
    # TODO: introduce size in bytes for the uploaded files  
    fileInput("userAnnot", "Module CSV File",
              accept = c("csv", "comma-separated-values",".csv")),
    bsTooltip("upload", "Write your module's name  \\ then upload the csv file containing \\ your projects annotations with the minimal key and value(s) fields (syntax is described on docs)",
              "right"), 
    tags$hr()
    # actionButton("removeUserDat", "Remove your annotations")
  )
)

mainPage <- dashboardPage(
  dashboardHeader(title = paste0("Annotation UI ", release.version)),
  sidebar,
  body
)

ui <- shinyUI(
  mainPage
)