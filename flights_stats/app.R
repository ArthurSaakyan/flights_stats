require(shiny)
require(lubridate)
require(nycflights13)
require(dplyr)
require(viridis)
require(plotly)


##### Load data #####

x_dep <- flights %>% 
    select(month, carrier) %>% 
    group_by(month, carrier) %>%
    mutate(month = lubridate::month(month, label = T, abbr = F)) %>% 
    summarise(count = n(), .groups = 'drop') #%>% 
    #left_join(airlines, by = "carrier")

x2_dep <- 
    x_dep %>% 
    group_by(carrier) %>%                               # for each carrier
    summarise(month = 'Все',                            # combine month
              count = sum(count)) %>%                   # get sum of count
    bind_rows(x_dep, .)                                     # add everything after your original dataset (rows)

#x2_dep <- as.data.frame(x2_dep) # ???

x_plane <- 
    flights %>% 
    select(month, carrier, tailnum) %>% 
    left_join(planes[, c(1,4)], by = "tailnum") %>% 
    group_by(month, carrier, manufacturer) %>% 
    mutate(month = lubridate::month(month, label = T, abbr = F)) %>% 
    summarise(count = n())

x2_plane <- 
    x_plane %>% 
    group_by(carrier, manufacturer) %>%                 # for each carrier
    summarise(month = 'Все',                               # combine month
              count = sum(count)) %>%                   # get sum of count
    bind_rows(x_plane, .)


##### UI #####

ui <- fluidPage(

    # titlePanel("Airline stats for all flights departing NYC in 2013"),
    titlePanel("Статистика авиакомпаний с вылетом из Нью-Йорка в 2013 году"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
        selectInput(inputId = "month", label = "Месяц",
                        choices = unique(x2_dep$month))
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("distGraph"), # plotlyOutput
           plotOutput("distGraph2")
           #plotOutput("Planes")
        )
    )
)

##### Server #####

server <- function(input, output) {
    
        blank_theme <- theme_minimal() +
            theme(
                #axis.title.x = element_blank(), # скрывает название координата X
                axis.title.y = element_blank(), # скрывает название координата y
                axis.title.x = element_text(face="italic"), # устанавливает настройки для названия координата X
                #axis.title.y = element_text(face="italic"), # устанавливает настройки для названия координата Y
                #panel.border = element_blank(),
                panel.grid=element_blank(),
                legend.position =  "none",   # убирает легенду
                #axis.ticks = element_blank(),
                #axis.text.x = element_blank(),
                #axis.text.x = element_text(angle = 90), # устанавливает настройки для значения на X
                plot.caption = element_text(hjust = 0),
                plot.title = element_text(size=14, face="italic", hjust = .5), # устанавливает настройки для названия графика
                #plot.subtitle = element_text(size = 8)  # устанавливает настройки для подзаголовка графика
            )
    
        output$distGraph <- renderPlot({
        
        bins2 <- input$month
        
        #bins_ap <- input$airports
        
        ggplot(subset(x2_dep, month == bins2), aes(carrier)) +
            geom_bar(aes(weight = count, fill = carrier)) +
            scale_fill_viridis(discrete = T, option = 'D') +
            geom_text(aes(y = count, label = count, vjust = -0.5)) +
            #geom_label(aes(y = count, label = count)) +
            ggtitle("Количество вылетов") +
            xlab("Авиакомпании") +
            labs(caption = "9E - Endeavor Air Inc.\nAA - American Airlines Inc.\nAS - Alaska Airlines Inc.") +
            #labs(caption = name) +
            blank_theme
        
        # plot_ly(
        #     x = subset(x_dep, month == bins2)$carrier,
        #     y = subset(x_dep, month == bins2)$count,
        #     name = "SF Zoo",
        #     type = "bar")
        })
        
        output$distGraph2 <- renderPlot({
            
            bins2 <- input$month
        
        ggplot(subset(x2_plane, month == bins2), aes(carrier)) +
            geom_bar(aes(weight = count, fill = manufacturer), position="fill")
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
