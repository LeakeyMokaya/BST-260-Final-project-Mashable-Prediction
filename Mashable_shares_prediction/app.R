library(shiny)
library(corrplot)
library(tidyverse)
library(ggrepel)
mash_work_train <- read.csv("Final train full.csv",header = TRUE)
rmse_list <- read.csv("RMSEs.csv",header = TRUE)

ui <- fluidPage(titlePanel("Mashable Article Analysis"),
                tabsetPanel(
                  tabPanel("Correlation and trend analysis",
                    fluidRow(column(6,h4("Correlations")),column(6,h4("Scatter plots"))),
                    fluidRow(
                      column(6,
                        wellPanel(
                          sliderInput(inputId = "corrthreshold",
                                          label = "Choose the threshold for minimum correlation", min = -1, max = 1, 
                                          value = -1,step = 0.1, animate = TRUE, width = "600px"))),
                      column(6,
                        wellPanel(
                          selectInput(inputId = "xvar",label = "Choose the variable on the X-axis",
                                      selected = "average_token_length", 
                                      choices = colnames(mash_work_train[,!sapply(mash_work_train,is.character)])),
                          selectInput(inputId = "yvar",label = "Choose the variable on the Y-axis",
                                      selected = "shares", 
                                      choices = colnames(mash_work_train[,!sapply(mash_work_train,is.character)]))))
                      ),
                      fluidRow(
                        column(6, mainPanel(plotOutput("corrs", width = "700px", height = "700px"))),
                        column(6,mainPanel(plotOutput("scatter", width = "500px", height = "500px")))
                        )
                      ),
                  tabPanel("RMSE progression",
                      fluidRow(column(6,h4("RMSE table")),column(6,h4("RMSE plot"))),
                      fluidRow(
                        column(6, mainPanel(tableOutput("rmsetable"))),
                        column(6,mainPanel(plotOutput("rmseplot", width = "500px", height = "500px")))
                      )
                     )
                    )
                  )
                  

server <- function(input, output) {
            m <- cor(mash_work_train[,sapply(mash_work_train,is.numeric)])
            tmp = m
            msmall <- reactive({
              tmp[tmp < input$corrthreshold] = 0
              return(tmp)
            })
            output$corrs <- renderPlot({
              corrplot(msmall())
            })
            
            output$scatter <- renderPlot({
              mash_work_train %>% ggplot(aes(x=get(input$xvar),y=get(input$yvar))) + 
                geom_point() + 
                xlab(input$xvar) + 
                ylab(input$yvar) +
                theme_bw()
            })
            
            output$rmsetable <- renderTable({
              rmse_list
            })
            
            output$rmseplot <- renderPlot({
              rmse_list %>% ggplot(aes(x=nos,y=rmse)) + 
                geom_point() +
                geom_line(color = "darkgreen",alpha=0.4) +
                geom_text_repel(aes(label=algos)) +
                theme_bw() + 
                xlab("nth major method") + 
                ylab("RMSE value")
              
            })
}

 
shinyApp(ui = ui, server = server)

