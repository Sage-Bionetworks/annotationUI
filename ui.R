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
  sidebarMenu(
    checkboxGroupInput("cat", "Project Category",
                       choiceNames = categories,
                       choiceValues = categories, 
                       selected = categories),
    bsTooltip("cat", "Select the projects containing the annotations that you need",
              "right")

  ),
  sidebarMenu(
    tags$hr(),
    textInput("projectName", "Project Name"),
    fileInput('userAnnot', 'Annotations CSV File',
              accept = c('csv', 'comma-separated-values','.csv')),
    tags$hr()
  )
)

y <- dashboardPage(
  dashboardHeader(title = "How-TO's"),
  dashboardSidebar(disable = TRUE),
  dashboardBody()
)

x <- dashboardPage(
  dashboardHeader(title = paste0("Annotation UI ", release.version)),
  sidebar,
  body
)

ui <- shinyUI(
  x
)