
library(shiny)
library(tibble)
library(ggplot2)
library(ggthemes)
library(ggrepel)

letter_grades <- tribble(
  ~breakpoints, ~letter,
  97,"A+",
  92,"A",
  90,"A-",
  87,"B+",
  82,"B",
  80,"B-",
  77,"C+",
  72,"C",
  70,"C-",
  67,"D+",
  62,"D",
  60,"D-",
  0,"F")

lg_plot = head(letter_grades, n = -1)

# Define UI for slider demo app ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Speculator"),
  
  p("This calculator is completely informational, hypothetical, 
    and is in no way official. It is offered with no warranty or 
    guarantee of accuracy or completeness. ", strong("Use at your own risk.") ),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar to demonstrate various slider options ----
    sidebarPanel(
      
      # Input: test one ----
      sliderInput("t1", "Test One",
                  min = 0, max = 100,
                  value = 83, step = 0.1),
      
      # Input: test two ----
      sliderInput("t2", "Test Two",
                  min = 0, max = 100,
                  value = 71, step = 0.1),
      
      # Input: test three ----
      sliderInput("t3", "Test Three",
                  min = 0, max = 100,
                  value = 89, step = 0.1),
      
      # Input: test four ----
      sliderInput("t4", "Test Four",
                  min = 0, max = 100,
                  value = 97, step = 0.1),
      
      
      # Input: homeworks ----
      sliderInput("homeworks", "Homeworks",
                  min = 0, max = 100,
                  value = 83, step = 0.1),
      
      # Input: final ----
      sliderInput("final", "Final",
                  min = 0, max = 100,
                  value = 88, step = 0.1)
      
      # # Input: Animation with custom interval (in ms) ----
      # # to control speed, plus looping
      # sliderInput("animation", "Looping Animation:",
      #             min = 1, max = 2000,
      #             value = 1, step = 10,
      #             animate =
      #               animationOptions(interval = 300, loop = TRUE))
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      plotOutput("radioPlot"),
      # Output: Table summarizing the values entered ----
      h4("Summary"),
      tableOutput("values")
      
      
    )
  )
  )

# Define server logic for slider examples ----
server <- function(input, output) {
  
  
  
  # Reactive expression to create data frame of all input values ----
  sliderValues <- reactive({
    
    t = c(input$t1, input$t2, input$t3, input$t4)
    dropped = (sum(t) - min(t))/(length(t)-1)
    replaced = (sum(c(t,input$final)) - min(c(t,input$final)))/(length(t))
    tests = max(dropped, replaced)
    
    overall = 0.25*(input$final + input$homeworks) + 0.5*tests
    overall_letter = dplyr::filter(letter_grades, floor(overall+0.5) >= breakpoints)[1,"letter"]
    
    tibble(
      Name = c("Raw tests avg",
               "dropped",
               "replaced",
               "TESTS",
               "GRADE",
               "letter"),
      Label = c("mean: all tests",
                "mean: lowest test dropped",
                "mean: lowest test replaced by final",
                "composite test score",
                "overall score",
                "letter grade"),
      Value = as.character(c(floor(
        c(mean(t),
          dropped,
          replaced,
          tests,
          overall)*1000+0.5)/1000,
        overall_letter))
    )
  })
  
  # your_grade <- reactive({
  #   tribble(
  #     ~score, ~letter,
  #     sliderValues()["GRADE","Value"], sliderValues()["letter",2]
  #   )
  # })
  
  # Show the values in an HTML table ----
  output$values <- renderTable(colnames = FALSE,{
    sliderValues()[,2:3]
  })
  
  output$radioPlot <- renderPlot({
    myOverall <- as.double(sliderValues()[5,3])
    myGrade <- as.character(sliderValues()[6,3])
    y_scale_breaks = c(lg_plot$breakpoints, myOverall)
    y_scale_breaks_labels = as.character(y_scale_breaks)
    y_scale_breaks_colors = c(rep("black",each=length(y_scale_breaks)-1),"red")
    y_scale_breaks_size = c(rep(14,each=length(y_scale_breaks)-1),10)
    myLine <- tribble(~xx, ~yy,
                      2.0, myOverall,
                      3.0, myOverall)
    # print(y_scale_breaks)
    # print(y_scale_breaks_colors)
    ggplot(lg_plot) +
      # geom_point(aes(0.5,myOverall), color="#428bca",size=2) +
      geom_rug(aes(0.5,myOverall), sides="l", color="red") +
      # geom_text(hjust=0.5, aes(0.5,myOverall, label=myOverall)) +
      # geom_text(aes(1,myOverall, label=myGrade)) +
      # geom_hline(aes(yintercept = myOverall) ) +
      # geom_line(data=myLine, aes(xx,yy),color="red") +
      geom_text(size=5, hjust="left", aes(x = 0, y = lg_plot$breakpoints, label=lg_plot$letter)) +
      # geom_text(size=5, hjust="right", aes(x = 0, y = lg_plot$breakpoints, label=lg_plot$breakpoints)) +
      # scale_y_continuous(position = "right") +
      scale_y_continuous(breaks = y_scale_breaks, labels = y_scale_breaks_labels
                         # sec.axis = dup_axis(label=lg_plot$letter)
      ) +
      # scale_y_continuous(breaks = myOverall
      #                    # sec.axis = dup_axis(label=lg_plot$letter)
      #                   ) +
      
      # xlim(0,0.1) +
      xlab(NULL) +
      ylab(NULL) +
      theme_tufte() +
      theme(
        # aspect.ratio=1/1,
        legend.position="none",
        axis.text.y = element_text(colour=y_scale_breaks_colors, size=y_scale_breaks_size, 
                                   family="sans" ),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.ticks.y = element_line(colour=y_scale_breaks_colors),
        # legend.justification = "top",
        plot.margin = unit(c(0,0,0,0), "pt")
      )
    
  })
  
}

# Create Shiny app ----
shinyApp(ui, server)
