library(shiny)
library(corrplot)
library(tidyverse)
library(ggrepel)
library(wordcloud)

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
                  ),
                  tabPanel("Analysis of title text",
                      fluidRow(column(6,h4("Sentiment distribution of article titles")),
                               column(6,h4("Topic distribution of all titles"))),
                      fluidRow(column(6,imageOutput("sentiments")),
                               column(6,imageOutput("topicmodels",width = "100px",height = "100px"))),
                      fluidRow(column(6,h4("Top words by frequency(min. frequency = 700)")),
                               column(6,h4("Word cloud of popular words(min. frequency = 200)"))),
                      fluidRow(column(6,imageOutput("topwords700")),
                               column(6,imageOutput("wordcloud200"))))))

server <- function(input, output) {
            mash_work_train <- read.csv("Final train full.csv",header = TRUE)
            rmse_list <- read.csv("RMSEs.csv",header = TRUE)
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
              
            output$sentiments <- renderImage({
              filename <- normalizePath(file.path("./images/Sentiments.png"))
              list(src = filename, alt = "Sentiment distribution")
            }, deleteFile = FALSE)
            
            output$topicmodels <- renderImage({
              filename <- normalizePath(file.path("./images/Topic Models.png"))
              list(src = filename, alt = "Topic distribution of titles")
            }, deleteFile = FALSE)
            
            output$topwords700 <- renderImage({
              filename <- normalizePath(file.path("./images/Top words more than 700.png"))
              list(src = filename, alt = "Top words by frequency")
            }, deleteFile = FALSE)
            
            output$wordcloud200 <- renderImage({
              filename <- normalizePath(file.path("./images/Wordcloud_min 200.png"))
              list(src = filename, alt = "Wordcloud of most frequent words")
            }, deleteFile = FALSE)
              
            
}

 
shinyApp(ui = ui, server = server)

