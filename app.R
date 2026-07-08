rm(list = ls())


####Read in Libraries####
library(shiny)
library(tidyverse)
library(shinythemes)
library(rsconnect)
library(shinyWidgets)
library(lubridate)
library(scales)
library(shinyjs)
library(shinyalert)
library(shiny.i18n)
library(googleLanguageR)
library(here)


####Initialize Translator for Automatic Translation####
i18n <- Translator$new(translation_json_path = here("json", "translation.json"))

##Set default language
i18n$set_translation_language("en")


####Write Decision Tree####
decision_tree <- 
  list(
    list(
      intro = TRUE,
      content_above_buttons =
        tags$div(
          tags$p(strong("Welcome to REFORM Alliance's Virginia Early Termination Tool.")),
          tags$p("This tool is designed to help users understand whether they may be eligible for early termination of probation in Virginia. It only applies to people on probation, not parole. Probation officers are responsible for recommending early termination. While this tool will help you understand whether you are eligible, you should speak with your probation officer directly about your specific case."),
          tags$p("This tool can be used by anyone, but is specifically designed to be used by people on probation. To begin using the tool, please click on the START button below.")
        ),
      next_question = "initial_questions",
      question_id = "intro_page"
    ),
    list(
      question =
        tags$div(
          tags$p(strong("First we need to ask you a few basic questions about your probation to determine what you are eligible for."))
        ),
      question_list = 
        list("q1" = 
               tags$p(
                 "Were you sentenced to a period of supervised probation for more than 1 year?  If you do not know, you can look it up ",
                 tags$a(href='https://eapps.courts.state.va.us/ocis/landing', target='_blank', class='external-link', "here"),
                 "."
               ),
             "q2" = 
               tags$p("Have you been on probation for at least one year?"),
             "q3" = tags$p("Are you supervised by the Virginia  Department of Corrections (VADOC)? If you answer “yes” to this, this means you are not supervised by a local community-based services agency. Please ask your probation officer if you are not sure about the answer to this question.")),
      choices = c("Yes", "No"),
      question_id = "initial_questions",
      next_question = list(
        "Yes" = "eligibility_questions",
        "No" = "first_early_term_result"
      )
    ), 
    list(
      question = 
        tags$div(
          tags$p(strong("Next we need to ask you some questions about your time on probation. The answers to these questions will determine what you may be eligible for."))
        ),
      question_list = 
        list("q1" = tags$p("Have you complied with all court-ordered conditions?"), 
             "q2" = tags$p("Have you followed your probation officer's individual case plan?"), 
             "q3" = tags$p("Has your Probation Officer determined that you pose minimal risk to the community?")),
      # note_text =
      #   tags$p(
      #     "If you do not know the answer to any of these questions, please discuss them with your probation officer. If you need help reaching your probation officer, please ",
      #     actionLink("go_to_resource", "click here"), "."
      #   ),
      
      note_text = tags$p(
        i18n$t("If you do not know the answer to any of these questions, please discuss them with your probation officer. If you need help reaching your probation officer, please"),
        " ",
        actionLink("go_to_resource", i18n$t("click here")),
        "."
      ),
      choices = c("Yes", "No"),
      question_id = "eligibility_questions", 
      next_question = list(
        "Yes" = "nature_of_sentence", 
        "No" = "first_early_term_result"
      )
    ), 
    list(
      question = 
        tags$div(
          tags$p(strong("Next we need to ask you about the nature of your sentence. This helps determine what you may be eligible for.")),
          tags$p("Were you convicted of any of the following offenses?"), 
          tags$ul(
            tags$li("Rape of a child under 13, under ", 
                    tags$a(href='https://law.lis.virginia.gov/vacode/18.2-61/', target='_blank', class='external-link', "section 18.2-61"), 
                    "(A)(iii)"),
            tags$li("Forcible sodomy, under ", 
                    tags$a(href='https://law.lis.virginia.gov/vacode/18.2-67.1/', target='_blank', class='external-link', "section 18.2-67.1(A)(1)")), 
            tags$li("Object sexual penetration, under ", 
                    tags$a(href='https://law.lis.virginia.gov/vacode/18.2-67.1/', target='_blank', class='external-link', "section 18.2-67.1(A)(1)"))
          )
        ),
      choices = c("Yes", "No"),
      question_id = "nature_of_sentence", 
      next_question = list(
        "Yes" = "first_early_term_result",
        "No" = "restitution_question"
      )
    ), 
    list(
      question = 
        tags$div(
          tags$p("Finally, do you still owe any restitution? This does not include fines, fees, or costs.")
        ),
      choices = c("Yes", "No"), 
      question_id = "restitution_question", 
      next_question = list(
        "Yes" = "second_early_term_result", 
        "No" = "third_early_term_result"
      )
    ), 
    list(result = 
           tags$div(
             tags$p("You can ask a judge to terminate your probation early! There is no automatic process to make this happen, you will need to file a motion with a court, but this is permitted at any time under ",
                    tags$a(href='https://law.lis.virginia.gov/vacode/title19.2/chapter18/section19.2-304/', target='_blank', class='external-link', "Virginia Code 19.2-304"))
           ),
         question_id = "first_early_term_result"),
    list(result = 
           tags$div(
             tags$p(strong("Congratulations, your probation officer is legally required to file for your early termination!")),
             tags$p("However, this is not the end of the process. At this point, the court is required to hold a hearing and provide notice to you and the prosecutor. At this hearing, the judge has discretion to decide whether or not to grant you early termination. It may be helpful to discuss how to best present your case to the judge with your probation officer or your attorney.")
           ),
         question_id = "second_early_term_result"),
    list(result = 
           tags$div(
             tags$p(strong("Congratulations, your probation officer is legally required to file for your early termination!")), 
             tags$p("However, this is not the end of the process. At this pont, the judge has discretion to decide whether or not to grant you early termination, with or without a hearing. It may be helpful to discuss how to best present your case to the judge with your probation officer or your attorney.")
           ),
         question_id = "third_early_term_result"),
    list(question = 
           tags$div(
             tags$p("Do you know your probation officer’s first and last name? If you are unsure, you can call Virginia DOC at (804) 674-3000."),
             tags$p("If you know their name, you can email your PO and ask them about your case. All probation officer emails in Virginia are their first name, then a period, then their last name @vadoc.virginia.gov. For example, a probation officer named David Johnson would have an email of David.Johnson@vadoc.virginia.gov.")
           ),
         question_id = "resource_question"),
    list(
      result =
        tags$div(
          tags$h2(strong("Thank you for using REFORM Alliance's Virginia Early Termination Tool!")),
          tags$p("We hope this tool has been helpful in understanding your potential eligibility for early termination in Virginia.")
        ),
      question_id = "finished_page"
    )
  ) 
    

####Create App####
ui <- fluidPage(
  usei18n(i18n),
  # title = uiOutput("app_title"),
  title = "Virginia Early Termination Tool",
  useShinyjs(),
  theme = shinytheme("flatly"),
  tags$head(
    tags$style(HTML(
      "
      .question-text{ font-size: 20px; margin-bottom: 30px; margin-top: 30px}
      .result-text{ font-size: 20px; font-weight: bold; color: #28a745; margin-top: 20px; }
      .shiny-input-container{ margin-bottom: 10px; }
      .btn-container{ margin-top: 20px; }
      .logo-container{ text-align: center; margin-bottom: 40px; margin-top: 10px;}/* Added margin-top */
      .logo{ max-width: 200px; height: auto; }
      /* Custom button styling */
      #violation-buttons .btn{
        margin-right: 10px;
        margin-bottom: 10px; /* Add bottom margin for spacing */
        border: 1px solid #ccc;
        padding: 10px 15px;
        font-size: 16px;
        min-width: 200px; /* Adjust as needed */
        text-align: center;
      }
      #violation-buttons .btn.active{
        border-color: #007bff;
        box-shadow: 0 0 5px rgba(0, 123, 255, 0.5);
      }
      #violation-buttons .btn-danger{
        background-color: #dc3545;
        color: white;
      }
      #violation-buttons .btn-success{
        background-color: #28a745;
        color: white;
        min-width: 250px;
        height: 60px;
        padding: 0 20px;     /* Horizontal padding only */
        font-size: 18px;
        line-height: 60px;
        text-align: center;
      }

      #start_button{
        font-size: 24px; /* Increase font size */
        padding: 15px 30px; /* Increase padding */
        min-width: 280px; /* Adjust width as needed */
        height: 70px;    /* Adjust height as needed */
        display: flex;        /* Enable flexbox */
        justify-content: center; /* Center horizontally */
        align-items: center;    /* Center vertically */
      }
      "
    )),
    
    tags$script(HTML("
    $(document).on('click', 'a.external-link', function(e){
      e.preventDefault();
      var $this = $(this);
      var href = $this.attr('href');
      $this.data('href-backup', href); // Backup the href
      Shiny.setInputValue('js_href', href);
    });
    Shiny.addCustomMessageHandler('open_url', function(message){
      window.open(message, '_blank');
      // No need to restore here, navigation happens
    });
    Shiny.addCustomMessageHandler('remove_href', function(href){
      $('a.external-link[data-href-backup=\"' + href + '\"]').each(function(){
        $(this).removeAttr('href'); // Temporarily remove href
      });
    });
    Shiny.addCustomMessageHandler('restore_href', function(href){
      $('a.external-link[data-href-backup=\"' + href + '\"]').each(function(){
        $(this).attr('href', $(this).data('href-backup'));
        $(this).removeData('href-backup');
      });
    });
    ")),
    
    tags$script(HTML("
    Shiny.addCustomMessageHandler('update-title', function(message){
      document.title = message;
    });
    "))
  ),
  
  div(class = "logo-container",
      img(src = "reform-logo-charcoal.png", class = "logo")
  ),
  
  div(strong(uiOutput("main_app_title")),
      style = "font-size: 40px; margin-top: 60px; margin-bottom: 40px; text-align: center;"
  ),
  
  div(
    class = "language-picker-container",
    pickerInput(
      inputId = "selected_language",
      label = i18n$t("Change Language"),
      choices = c("en", "es"),
      selected = i18n$get_translation_language(),
      choicesOpt = list(
        content = c(
          paste0("<i class='flag-icon flag-icon-us'></i> ", i18n$t("English")),
          paste0("<i class='flag-icon flag-icon-es'></i> ", i18n$t("Español"))
        )
      ),
      options = list(
        style = "btn-primary", 
        `live-search` = FALSE, 
        `selected-text-format` = "count > 2", 
        width = "180px"
      )
    )
  ),
  
  uiOutput("quiz_ui"),
  div(class = "btn-container",
      uiOutput("button_ui")
  )
)


####Server####
server <- function(input, output, session){
  i18n_r <- reactive({
    selected <- input$selected_language
    if(length(selected) > 0 && selected %in% i18n$get_languages()){
      i18n$set_translation_language(selected)
    }
    i18n
  })
  
  get_english_key <- function(translated_answer_from_input, current_lang_code){
    if(is.null(translated_answer_from_input) || nchar(translated_answer_from_input) == 0){
      return(NULL)
    }
    
    if(current_lang_code == "en"){
      return(translated_answer_from_input)
    }else if(current_lang_code == "es"){
      translation <- 
        as.data.frame(i18n_r()$get_translations()) %>% 
        rownames_to_column("en") %>% 
        filter(es == translated_answer_from_input) %>% 
        pull(en)
      return(translation)
    }
  }
  
  output$app_title <- renderText({
    i18n_r()$t("Virginia Early Termination Tool")
  })
  
  output$main_app_title <- renderText({
    i18n_r()$t("Virginia Early Termination Tool")
  })
  
  history <- reactiveVal(c(1))
  selected_answer <- reactiveVal(NULL)
  answer_selected <- reactiveVal(FALSE)
  stored_answers <- reactiveValues()
  
  observeEvent(input$js_href, {
    href <- input$js_href
    
    shinyalert(
      title = i18n_r()$t("Leaving Application"),
      text = i18n_r()$t("This will take you to a new website."),
      type = "info",
      showCancelButton = TRUE,
      confirmButtonText = i18n_r()$t("Continue"),
      callbackR = function(x){
        if(isTRUE(x)){
          session$sendCustomMessage("open_url", href)
          session$sendCustomMessage("remove_href", href)
        }else{
          session$sendCustomMessage("restore_href", href)
        }
      }
    )
  }, ignoreInit = TRUE)
  
  ##Translate UI Recursive Function
  translate_ui_recursive <- function(element, translator_reactive){
    if(is.character(element)){
      return(translator_reactive()$t(element))
    }else if(inherits(element, "shiny.tag") || inherits(element, "htmltools.tag")){
      if(element$name == "a" && !is.null(element$children)){
        element$children <- lapply(element$children, translate_ui_recursive, translator_reactive)
      }else if(!is.null(element$children)){
        element$children <- lapply(element$children, translate_ui_recursive, translator_reactive)
      }
      if(!is.null(element$attribs)){
        if(!is.null(element$attribs$placeholder)){
          element$attribs$placeholder <- translator_reactive()$t(element$attribs$placeholder)
        }
        if(element$name %in% c("strong", "b") && !is.null(element$children) && is.character(element$children[[1]])){
          element$children[[1]] <- translator_reactive()$t(element$children[[1]])
        }
      }
      return(element)
    }else if(is.list(element)){
      return(lapply(element, translate_ui_recursive, translator_reactive))
    }
    return(element)
  }
  
  ##Quiz UI
  output$quiz_ui <- renderUI({
    current_index <- tail(history(), 1)
    current_question <- decision_tree[[current_index]]
    
    if(length(current_question$intro) > 0){
      tagList(
        translate_ui_recursive(current_question$content_above_buttons, i18n_r),
        uiOutput("intro_buttons"),
        translate_ui_recursive(current_question$content_below_buttons, i18n_r)
      )
    }else if("question" %in% names(current_question) &&
             length(current_question$question_list) == 0){
      tagList(
        translate_ui_recursive(current_question$question, i18n_r),
        if("choices" %in% names(current_question) &&
           length(current_question$choices) > 0){
          stored <- stored_answers[[current_question$question_id]]
          radioButtons("answer", NULL,
                       selected = if(!is.null(stored)) i18n_r()$t(stored) else character(0),
                       choices = lapply(current_question$choices, function(x) i18n_r()$t(x)))
        }
      )
    }else if("question" %in% names(current_question) &&
              length(current_question$question_list) > 0){
      tagList(
        translate_ui_recursive(current_question$question, i18n_r),
        current_question %>%
          pluck("question_list") %>%
          enframe() %>%
          pmap(
            ~tagList(
              div(tags$div(tags$p(translate_ui_recursive(.y, i18n_r)))), 
              radioButtons(
                inputId = paste0("answer_", .x),
                selected = {
                  stored <- stored_answers[[paste0(current_question$question_id, "___answer_", .x)]]
                  if(!is.null(stored)) i18n_r()$t(stored) else character(0)
                },
                label = NULL,
                choices = lapply(c("Yes", "No"), function(x) i18n_r()$t(x)) 
              )
            )
          ),
        if(!is.null(current_question$note_text)){
          translate_ui_recursive(current_question$note_text, i18n_r)
        }
      )
    }else if("result" %in% names(current_question)){
      translate_ui_recursive(current_question$result, i18n_r)
    }
  })
  
  output$intro_buttons <- renderUI({
    div(
      actionButton("start_button", i18n_r()$t("Start"), class = "btn btn-success")
    )
  })
  
  output$button_ui <- renderUI({
    current_index <- tail(history(), 1)
    current_question <- decision_tree[[current_index]]
    buttons <- list()
    
    if(current_question$question_id == "resource_question"){
      buttons <- list(actionButton("back_button", i18n_r()$t("Go Back to Previous Question"), class = "btn btn-warning"))
    }else{
      if(length(history()) > 1 & current_question$question_id != "intro_page"){
        buttons <- append(buttons, list(actionButton("back_button", i18n_r()$t("Back"), class = "btn btn-warning")))
      }
      
      if(current_question$question_id == "finished_page"){
        buttons <- append(buttons, list(actionButton("start_over_button", i18n_r()$t("Start Over"), class = "btn btn-success")))
      }else if(is.null(current_question$next_question)){
        buttons <- append(buttons, list(actionButton("finish_button", i18n_r()$t("Finish"), class = "btn btn-danger")))
      }else if(length(current_question$intro) == 0){
        buttons <- append(buttons, list(actionButton("next_button", i18n_r()$t("Next"), class = "btn btn-primary")))
      }
    }
    
    do.call(fluidRow, buttons)
  })
  
  observeEvent(input$answer, {
    current_index <- tail(history(), 1)
    current_question <- decision_tree[[current_index]]
    
    answer_selected(FALSE)
    
    current_lang_code <- input$selected_language 
    
    if(length(current_question$question_list) == 0 && "choices" %in% names(current_question)){
      req(input$answer) 
      english_key_to_store <- get_english_key(input$answer, current_lang_code)
      
      ifelse(is.null(english_key_to_store) == FALSE, answer_selected(TRUE), answer_selected(FALSE))
      selected_answer(english_key_to_store)
      if(!is.null(english_key_to_store)){
        stored_answers[[current_question$question_id]] <- english_key_to_store   # <-- new
      }
    }else if(length(current_question$question_list) > 0){
      # answer_ids <- names(input)[grepl("^answer_q", names(input))]
      answer_ids <- paste0("answer_", names(current_question$question_list))
      
      responses <- sapply(answer_ids, function(id) get_english_key(input[[id]], current_lang_code))  
      for(id in answer_ids){                                                     # <-- new
        val <- get_english_key(input[[id]], current_lang_code)
        if(!is.null(val) && nchar(val) > 0){
          stored_answers[[paste0(current_question$question_id, "___", id)]] <- val
        }
      }
      null_responses <- 
        responses %>% 
        map(~is.null(.x)) %>% 
        unlist() %>% 
        any()
      if(null_responses == FALSE){
        answer_selected(TRUE)
      }else if(null_responses == TRUE){
        answer_selected(FALSE)
      }
      
      answer_selected_val = answer_selected()
      
      if(answer_selected_val == TRUE){
        if("Yes" %in% responses){
          selected_answer("Yes")
        }else{
          selected_answer("No")
        }
      }
    }
  })
  
  observe({
    answer_selected_val = answer_selected()
    if(!is.null(answer_selected_val) & answer_selected_val == TRUE){
      shinyjs::enable("next_button")
    }else{
      shinyjs::disable("next_button")
    }
  })
  
  observe({
    current_index <- tail(history(), 1)
    current_question <- decision_tree[[current_index]]
    current_lang_code <- input$selected_language 
    
    if(length(current_question$question_list) > 0){
      # answer_ids <- names(input)[grepl("^answer_q", names(input))]
      answer_ids <- paste0("answer_", names(current_question$question_list))
      
      responses <- sapply(answer_ids, function(id) get_english_key(input[[id]], current_lang_code))  
      null_responses <- 
        responses %>% 
        map(~is.null(.x)) %>% 
        unlist() %>% 
        any()
      if(null_responses == FALSE){
        answer_selected(TRUE)
      }else if(null_responses == TRUE){
        answer_selected(FALSE)
      }
      
      answer_selected_val = answer_selected()
      
      if(answer_selected_val == TRUE){
        if("Yes" %in% responses){
          selected_answer("Yes")
        }else{
          selected_answer("No")
        }
      }
    }
  })
  
  observeEvent(input$go_to_resource, {
    resource_index <- which(map_chr(decision_tree, "question_id") == "resource_question")
    history(c(history(), resource_index))
  })
  
  observeEvent(input$start_button, {
    current_question <- decision_tree[[1]]
    next_id <- current_question$next_question
    next_index <- which(map_chr(decision_tree, "question_id") == next_id)
    history(c(history(), next_index))
  })
  
  observeEvent(input$next_button, {
    current_index <- tail(history(), 1)
    current_question <- decision_tree[[current_index]]
    answer_selected_val <- answer_selected()
    if(answer_selected_val == FALSE && !("result" %in% names(current_question)) && !(length(current_question$next_question) == 1 && !("choices" %in% names(current_question)))){
      shinyalert(
        title = i18n_r()$t("Missing answer"),
        text = i18n_r()$t("Please select an answer before clicking Next"),
        type = "warning"
      )
      return()
    }
    
    if("choices" %in% names(current_question)){
      req(selected_answer()) 
      next_id <- switch(selected_answer(),
                        "Yes" = current_question$next_question[["Yes"]],
                        "No" = current_question$next_question[["No"]]
      )
    }else{ 
      next_id <- current_question$next_question
    }
    
    req(next_id)
    
    next_index <- which(map_chr(decision_tree, "question_id") == next_id)
    history(c(history(), next_index))
    answer_selected(FALSE) 
    selected_answer(NULL) 
  })
  
  observeEvent(input$back_button, {
    answer_selected(FALSE)
    selected_answer(NULL)
    if(length(history()) > 1){
      history(history()[1:(length(history()) - 1)])
      answer_selected(FALSE)
      selected_answer(NULL)
    }
  })
  
  observeEvent(input$start_over_button, {
    history(c(1))
    answer_selected(FALSE)
  })
  
  observeEvent(input$finish_button, {
    finished_page_index <- which(map_chr(decision_tree, "question_id") == "finished_page")
    history(c(history(), finished_page_index))
  })
}

##Deploy App
shinyApp(ui = ui, server = server)