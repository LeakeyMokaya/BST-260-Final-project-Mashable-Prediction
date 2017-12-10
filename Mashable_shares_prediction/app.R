library(shiny)
library(corrplot)
library(tidyverse)
library(ggrepel)
library(wordcloud)
library(grid)

mash_work_train <- read.csv("Final train full.csv",header = TRUE)
mae_list <- read.csv("MAEs.csv",header = TRUE)
time_list <- read.csv("times.csv",header = TRUE)
mae_time <- read.csv("mae_time.csv",header = TRUE)
pareto <- read.csv("Pareto.csv",header = TRUE)
ae_list <- read.csv("AE_list.csv",header = TRUE)

ui <- fluidPage(titlePanel("Mashable Article Analysis"),
                tabsetPanel(
                  tabPanel("Correlation and trend analysis",
                    fluidRow(column(6, align = "center",h4("Correlations")),column(6, align = "center",
                                                                                   h4("Scatter plots"))),
                    fluidRow(
                      column(6,
                        wellPanel(
                          sliderInput(inputId = "corrthreshold",
                                          label = "Choose the threshold for absolute value of minimum correlation", 
                                          min = 0, max = 1, value = 0.5,step = 0.1, animate = TRUE, width = "600px"))),
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
                        column(6, align="left", mainPanel(plotOutput("corrs", width = "700px", height = "700px"))),
                        column(6,mainPanel(plotOutput("scatter", width = "500px", height = "500px")))
                        ),
                      fluidRow(column(12, align = "center", h4("Pareto plot of variable importance"))),
                      fluidRow(
                      column(12, align = "right", 
                             mainPanel(plotOutput("paretoplot", width = "700px", height = "700px")))
                    )
                      ),
                  tabPanel("MAE and Time analysis",
                      fluidRow(column(6,h4("MAE table")),column(6,h4("MAE plot"))),
                      fluidRow(
                        column(6, mainPanel(tableOutput("maetable"))),
                        column(6,mainPanel(plotOutput("maeplot", width = "500px", height = "500px")))
                      ),
                      fluidRow(column(6,h4("Time table")),column(6,h4("Time plot"))),
                      fluidRow(
                        column(6, mainPanel(tableOutput("timetable"))),
                        column(6,mainPanel(plotOutput("timeplot", width = "500px", height = "500px")))
                      ),
                      fluidRow(column(6,h4("MAE gain per time table")),column(6,h4("MAE gain per time plot"))),
                      fluidRow(
                        column(6, mainPanel(tableOutput("maetimetable"))),
                        column(6,mainPanel(plotOutput("maetimeplot", width = "500px", height = "500px")))
                      ),
                      fluidRow(column(12,align = "center",h4("Absolute Error variation across share values(0-1000)"))),
                      fluidRow(column(12,
                             wellPanel(
                               selectInput(inputId = "aemodel",label = "Choose the model to view AE trend",
                                           selected = "Mean", 
                                           choices = list("Mean","Mean + Author effect","Mean + topword effect",
                                                       "Base Linear Regression","Step-wise Forward Regression",
                                                       "Decision Tree","Regression using top variables",
                                                       "Random Forest","Gradient Boosted Trees"))
                               ))),
                      fluidRow(
                        column(12, align = "right",
                               mainPanel(plotOutput("aemodelplot",width = "500px", height = "500px"))))
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
            m <- cor(mash_work_train[,sapply(mash_work_train,is.numeric)])
            tmp = m[-1,-1]
            msmall <- reactive({
              tmp[abs(tmp) < input$corrthreshold] = 0
              return(tmp)
            })
            output$corrs <- renderPlot({
              corrplot(msmall(),type = "upper",mar = c(0,0,0,0))
            })
            
            output$scatter <- renderPlot({
              mash_work_train %>% ggplot(aes(x=get(input$xvar),y=get(input$yvar))) + 
                geom_point() + 
                xlab(input$xvar) + 
                ylab(input$yvar) +
                theme_bw()
            })
            
            output$paretoplot <- renderPlot({
              pareto %>% 
                ggplot(aes(factor(Variables, levels = Variables[order(-Overall)]), Overall, group = 1)) + 
                geom_bar(stat = "identity") +
                geom_line(aes(Variables, Cumulative), color='darkgreen', alpha = 0.4) +
                scale_y_continuous(limits = c(0, 0.04)) +
                xlab("Top Variables") +
                ylab("Variable Importance") +
                scale_y_continuous(sec.axis = sec_axis(~.*100/0.036, name = "Percent of Total")) +
                theme_bw() +
                theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
                theme(plot.margin=unit(c(0,0,0,0),"mm"))
            })
            
            output$maetable <- renderTable({
              mae_list
            })
            
            output$maeplot <- renderPlot({
              mae_list %>% ggplot(aes(x=nos,y=mae)) + 
                geom_point() +
                geom_line(color = "darkgreen",alpha=0.4) +
                geom_text_repel(aes(label=algos)) +
                theme_bw() + 
                xlab("nth major method") + 
                ylab("MAE value")
              
            })
            
            output$timetable <- renderTable({
              time_list
            })
            
            output$timeplot <- renderPlot({
              time_list %>% ggplot(aes(x=nos,y=time)) + 
                geom_point() +
                geom_line(color = "darkgreen",alpha=0.4) +
                geom_text_repel(aes(label=algos)) +
                theme_bw() + 
                xlab("nth major method") + 
                ylab("Time elapsed(s)")
              
            })
            
            output$maetimetable <- renderTable({
              mae_time
            })
            
            output$maetimeplot <- renderPlot({
              mae_time %>% ggplot(aes(x=nos,y=mae_gain_time)) + 
                geom_point() +
                geom_line(color = "darkgreen",alpha=0.4) +
                geom_text_repel(aes(label=algos)) +
                theme_bw() + 
                xlab("nth major method") + 
                ylab("MAE gain per unit time")
              
            })
            
            aemodelvar <- reactive({
              mod = ifelse(input$aemodel == "Mean","ae_mean",
                           ifelse(input$aemodel == "Mean + Author effect","ae_mean_author",
                                  ifelse(input$aemodel == "Mean + topword effect","ae_mean_topword",
                                         ifelse(input$aemodel == "Base Linear Regression","ae_reg",
                                                ifelse(input$aemodel == "Step-wise Forward Regression","ae_fwd_reg",
                                                       ifelse(input$aemodel == "Decision Tree","ae_tree",
                                                              ifelse(input$aemodel == "Regression using top variables","ae_reg_top",
                                                                     ifelse(input$aemodel == "Random Forest","ae_rf",
                                                                            ifelse(input$aemodel == "Gradient Boosted Trees","ae_xgb"
                                                                                   )))))))
                           ))
                           
              return(mod)
            })
            
            output$aemodelplot <- renderPlot({
              ae_list %>% ggplot(aes_string(x="shares",y=aemodelvar())) + 
                geom_line(color = "darkgreen") +
                theme_bw() + 
                scale_x_continuous(limits = c(0,1000)) + 
                scale_y_continuous(limits = c(0,10000)) + 
                theme_bw() +
                xlab("shares") + 
                ylab("Absolute Error variation")
              
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

