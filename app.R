library(shiny)
library(shinythemes)
library(tools)  # For file_path_sans_ext

# Load pre-processed data
sampled_metadata <- readRDS("/Users/stephenyw/Documents/SJTU/Comp/FinalProject/4060_Group10_FinalProject/sampled_metadata_df1.rds")

# Path to folders (change to your actual paths)
resized_folder <- "www/resized"
resnet_outputs_folder <- "www/out"

# Get the list of artist names
artist_names <- unique(sampled_metadata$artist_name)

# Available convolution layers
conv_layers <- c(
  "original", 
  "conv1_relu", 
  "conv2_block3_out", 
  "conv3_block4_out", 
  "conv4_block6_out", 
  "conv5_block3_out"
)

# Function to convert artist names to folder names
convert_artist_to_folder <- function(artist_name, switch) {
  if (artist_name == "Albrecht Durer") {
    if(switch == 1) {
      return("Albrecht_Dürer")
    }
    else{return("Albrecht_Durer")}
    
  }
  gsub(" ", "_", artist_name)  # Replace spaces with underscores
}

# UI
ui <- navbarPage(
  theme = shinytheme("cerulean"),
  title = "Art Explorer with ResNet Features",
  
  # Information Section
  tabPanel(
    "About",
    fluidPage(
      h2("About the Art Explorer App"),
      
      fluidRow(
        column(
          width = 8,
          h3("Data Overview"),
          p("This application uses a dataset of 8,355 paintings by 50 renowned artists. The dataset comes from the ",
            a("Best Artworks of All Time", href = "https://www.kaggle.com/datasets/ikarus777/best-artworks-of-all-time", target = "_blank"),
            " collection on Kaggle. Each image has been resized to 224 × 224 pixels to be compatible with the ResNet50 model, a deep learning convolutional neural network (CNN) pre-trained on ImageNet."
          ),
          
          h3("Purpose"),
          p("The goal of this app is to provide an interactive way to explore and visualize how ResNet50 processes these artworks. By examining different convolutional layers of the network, users can understand how neural networks extract visual features at increasing levels of abstraction."),
          
          h3("Why Visualize Convolutional Layers?"),
          p("In a CNN like ResNet50, each convolutional layer captures different types of features:"),
          tags$ul(
            tags$li(strong("Early Layers (e.g., conv1_relu): "), "Detect basic features like edges, textures, and simple patterns."),
            tags$li(strong("Intermediate Layers (e.g., conv2_block3_out, conv3_block4_out): "), "Capture more complex patterns like shapes and contours."),
            tags$li(strong("Deeper Layers (e.g., conv4_block6_out, conv5_block3_out): "), "Recognize abstract, high-level features like objects, faces, or stylistic elements.")
          ),
          
          p("Visualizing these layers helps to demystify how neural networks 'see' and understand images, making it valuable for art enthusiasts, students, and researchers interested in deep learning."),
          
          h3("How to Use the App"),
          tags$ol(
            tags$li("Select an artist from the dropdown menu in the 'Explore' section."),
            tags$li("View the artist's paintings in the 'Original Artwork' tab."),
            tags$li("In the 'Features' tab, select a painting and a convolutional layer to visualize the network's feature maps for that layer."),
            tags$li("The visualization shows how the network processes the painting at different stages of the model.")
          )
        ),
        
        column(
          width = 4,
          tags$div(
            tags$img(
              src = "resized/William_Turner/William_Turner_18.jpg",
              width = "100%",
              height = "auto",
              style = "display: block; margin: auto; border: 1px solid #ccc;"
            ),
            tags$p("William Turner - Example Artwork", style = "text-align: center; font-style: italic;")
          )
        )
      )
    )
  ),
  
  # Explore Section
  tabPanel(
    "Explore",
    fluidPage(
      sidebarLayout(
        sidebarPanel(
          h3("Controls"),
          selectInput("artistSelect", "Select Artist", choices = artist_names)
        ),
        mainPanel(
          tabsetPanel(
            id = "tabs",
            tabPanel("Original Artwork", uiOutput("artDisplay")),
            tabPanel(
              "Features",
              uiOutput("imageSelectUI"),
              selectInput("convLayerSelect", "Select Convolution Layer", choices = conv_layers),
              uiOutput("featureDisplay")
            )
          )
        )
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Reactive: Filter images based on selected artist
  selectedArtistImages <- reactive({
    req(input$artistSelect)
    subset(sampled_metadata, artist_name == input$artistSelect)
  })
  
  # Display original artworks in 3 columns
  output$artDisplay <- renderUI({
    req(selectedArtistImages())
    artist_data <- selectedArtistImages()
    
    fluidRow(
      lapply(seq_len(min(20, nrow(artist_data))), function(i) {
        # Construct the path to the image in the resized folder
        artist_folder <- convert_artist_to_folder(input$artistSelect, 1)
        img_path <- file.path("resized", artist_folder, artist_data$file_name[i])
        
        # Display the image and filename
        div(
          class = "col-md-3",
          tags$div(
            tags$img(
              src = img_path,
              width = "100%",
              height = "300px"
            ),
            tags$p(artist_data$file_name[i], style = "text-align: center;")
          )
        )
      })
    )
  })
  
  # Dynamic UI for image selection in the Features tab
  output$imageSelectUI <- renderUI({
    req(selectedArtistImages())
    images <- selectedArtistImages()$file_name
    selectInput("imageSelect", "Select Image", choices = images)
  })
  
  # Reactive: Get selected image path for the Features tab
  selectedFeatureImagePath <- reactive({
    req(input$artistSelect, input$imageSelect, input$convLayerSelect)
    
    # Construct the filename based on selections
    artist_folder <- convert_artist_to_folder(input$artistSelect, 2)
    image_base <- file_path_sans_ext(input$imageSelect)  # Remove file extension
    
    # Construct the full path to the selected convolution layer output
    file_name <- paste0(artist_folder, "_", image_base, "_", input$convLayerSelect, ".png")
    file.path(resnet_outputs_folder, file_name)
  })
  
  # Display selected feature visualization
  output$featureDisplay <- renderUI({
    req(input$artistSelect, input$imageSelect, input$convLayerSelect)
    
    # Get the selected image path
    img_path <- selectedFeatureImagePath()
    
    # Verify the file path exists
    if (!file.exists(img_path)) {
      validate(
        need(FALSE, "Selected image or convolution layer visualization not found.")
      )
    }
    img_data <- base64enc::dataURI(file = img_path, mime = "image/png")
    
    tags$div(
      tags$img(
        src = img_data,
        width = "100%",
        height = "auto",
        style = "display: block; margin: auto;"
      )
    )
  })
}

# Run the Shiny app
shinyApp(ui, server)