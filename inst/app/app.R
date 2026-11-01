library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(overdue)

# Setup
metrics <- plv_metric_labels()
years <- levels(plv_services$financial_year)
metric_choices <- setNames(metrics$metric, metrics$label)
label_of <- function(key) metrics$label[metrics$metric == key]

# Palette (one place, used by the theme and the charts)

green_dark <- "#264638"
green_mid <- "#5E8C6A"
accent <- "#D08C2D"
muted <- "#B9C4BD"
panel_bg <- "#F4F7F5"

app_theme <- bs_theme(
  version = 5,
  bg = "#FFFFFF",
  fg = "#1E2A24",
  primary = green_dark,
  secondary = green_mid,
  base_font = font_google("Montserrat", local = FALSE),
  heading_font = font_google("Montserrat", local = FALSE),
  font_scale = 0.95,
  "border-radius" = "0.5rem"
)

# UI

ui <- navbarPage(
  title = "Library rankings explorer",
  id = "page",
  theme = app_theme,
  header = tags$style(HTML(sprintf(
    "
    /* Dark green navbar with white text */
    .navbar { background-color: %1$s !important; }
    .navbar .navbar-brand,
    .navbar .nav-link { color: #FFFFFF !important; }
    .navbar .nav-link.active { border-bottom: 3px solid %3$s; }

    h2, h3 { color: %1$s; font-weight: 600; }
    h3 { margin-top: 1.6rem; }

    /* Sidebar panel */
    .well { background-color: %4$s; border: none; }

    /* 'How to read this' boxes */
    .how-to-read {
      background: %4$s;
      border-left: 4px solid %1$s;
      border-radius: 6px;
      padding: 12px 16px;
      margin: 12px 0 24px;
    }
    .how-to-read p:last-child { margin-bottom: 0; }
    .well .how-to-read { background: #FFFFFF; margin-top: 20px; }

    /* Missing-services and correlation notes */
    .note { color: #5A4A2A; background: #FBF3E6; border-radius: 6px;
            padding: 8px 12px; margin: 8px 0; }

    a { color: %2$s; }
  ",
    green_dark,
    green_mid,
    accent,
    panel_bg
  ))),

  # Page 1: Start here
  tabPanel(
    "Start here",
    div(
      style = "max-width: 900px; margin: 0 auto; padding-top: 1rem;",
      h2("Does the busiest library depend on how you measure it?"),

      h3("Who this app is for"),
      p(
        "People learning data analysis, particularly those exploring how the ",
        "choice of metric can change a conclusion. The data is real, and the ",
        "app portrays it from multiple angles, allowing exploration on a basic, ",
        "single criterion, and then again in a more complex, comparative format."
      ),

      h3("The question"),
      p(strong(
        "Does the ranking of Victorian public library services change ",
        "depending on how library usage is measured?"
      )),
      p(
        "\u201cWhich library is busiest?\u201d sounds like it has one answer. ",
        "However, total visits mostly reflect how many people live in a service's area, ",
        "while visits per resident reveal which libraries carry more visits than their population would suggest. ",
        "Borrowing, digital loans and website traffic tell different stories again. ",
        "This app shows you how much the answer moves depending on how you measure 'busy'."
      ),

      h3("How to use the controls"),
      p(
        "Open ",
        em("Explore the rankings"),
        " in the top bar. The controls on the left are:"
      ),
      tags$ul(
        tags$li(
          strong("Metric A: "),
          "the measure ranked in ",
          em("One metric"),
          ", and the horizontal axis in ",
          em("Compare two metrics"),
          "."
        ),
        tags$li(
          strong("Metric B: "),
          "a second measure, used only in ",
          em("Compare two metrics"),
          " (vertical axis). Choose a different metric from A."
        ),
        tags$li(
          strong("Year: "),
          "the financial year, from 2022-23 to 2024-25. Both metrics use the same year."
        )
      ),

      h3("Suggested first steps"),
      tags$ol(
        tags$li(
          "In ",
          em("One metric"),
          ", look at the top five for ",
          em("Branch visits (total)"),
          ", then switch Metric A to ",
          em("Branch visits per resident"),
          ". Who takes the lead?"
        ),
        tags$li(
          "In ",
          em("Compare two metrics"),
          ", keep those two metrics and read ",
          "the rank correlation above the chart. Then try other pairs: which ",
          "pairs agree strongly, and which barely agree at all?"
        ),
        tags$li(
          "Change the year. Do the patterns hold, or do they shift? Are libraries getting more popular over time?"
        )
      ),

      h3("What each metric means"),
      tableOutput("metric_table"),

      h3("What the data covers"),
      tags$ul(
        tags$li(
          "50 municipal library services, from the Public Libraries Victoria ",
          "Annual Statistical Survey, 2022-23 to 2024-25."
        ),
        tags$li(
          "Some services cover more than one council. For example, ",
          strong("Your Library"),
          " (formerly the Eastern Regional Libraries Corporation) runs the ",
          "libraries for Knox, Maroondah and Yarra Ranges, serving about 443,000 ",
          "residents. Shared services like this have large totals partly because ",
          "they serve several councils' populations."
        ),
        tags$li(
          "The Victorian total and Vision Australia (a statewide service with no ",
          "municipal population) are excluded from rankings."
        ),
        tags$li(
          "Visits and website visits count events, not people: one person ",
          "visiting ten times counts ten times."
        ),
        tags$li(
          "Services that didn't report a measure are left out of its ranking, ",
          "and the app names them (for example, set ",
          strong("Metric A"),
          " to ",
          em("Website visits per resident"),
          " with Year ",
          em("2024-25"),
          ")."
        )
      )
    )
  ),

  # Page 2: the charts, with the controls
  tabPanel(
    "Explore the rankings",
    sidebarLayout(
      sidebarPanel(
        width = 4,
        selectInput(
          "metric",
          "Metric A",
          choices = metric_choices,
          selected = "branch_visits"
        ),
        selectInput(
          "metric_b",
          "Metric B (for comparison)",
          choices = metric_choices,
          selected = "visits_per_person"
        ),
        selectInput("year", "Year", choices = years, selected = "2024-25"),

        # Help text follows whichever chart tab is open
        conditionalPanel(
          condition = "input.view == 'One metric'",
          uiOutput("rank_help")
        ),
        conditionalPanel(
          condition = "input.view == 'Compare two metrics'",
          uiOutput("scatter_help")
        )
      ),
      mainPanel(
        width = 8,
        tabsetPanel(
          id = "view",
          tabPanel(
            "One metric",
            uiOutput("missing_note"),
            plotOutput("rank_plot", height = "950px")
          ),
          tabPanel(
            "Compare two metrics",
            uiOutput("compare_note"),
            plotOutput("scatter_plot", height = "650px")
          )
        )
      )
    )
  )
)

# Server

server <- function(input, output, session) {
  # One reactive per metric: each re-runs plv_metric() only when its own
  # metric or the year changes
  result <- reactive(plv_metric(input$metric, input$year))
  result_b <- reactive(plv_metric(input$metric_b, input$year))

  # Shared chart styling
  theme_app <- function() {
    theme_minimal(base_size = 14) +
      theme(
        panel.grid.minor = element_blank(),
        axis.title = element_text(colour = "grey30"),
        axis.text = element_text(colour = "grey20"),
        plot.margin = margin(10, 20, 10, 10)
      )
  }

  # Start here

  # Built from plv_metric_labels(), so it always matches the package docs
  output$metric_table <- renderTable(
    metrics |>
      select(Metric = label, Definition = definition),
    striped = TRUE,
    bordered = TRUE,
    width = "100%"
  )

  # Explore one metric

  output$missing_note <- renderUI({
    missing <- attr(result(), "missing_services")
    if (length(missing) == 0) {
      return(NULL)
    }
    p(
      class = "note",
      sprintf(
        "%d services aren't ranked because they didn't report this measure: %s.",
        length(missing),
        paste(missing, collapse = ", ")
      )
    )
  })

  output$rank_plot <- renderPlot(
    {
      d <- result() |> filter(!is.na(value))
      validate(need(
        nrow(d) > 0,
        "No services reported this measure in the chosen year."
      ))
      bench <- attr(result(), "benchmark")

      ggplot(d, aes(value, reorder(service, value))) +
        geom_col(fill = green_dark, width = 0.75) +
        geom_vline(
          xintercept = bench,
          linetype = "dashed",
          colour = accent,
          linewidth = 0.9
        ) +
        annotate(
          "text",
          x = bench,
          y = -Inf, 
          label = "Benchmark",
          hjust = -0.08,
          vjust = -0.6, 
          colour = accent,
          fontface = "bold",
          size = 4.2
        ) +
        scale_x_continuous(
          labels = scales::label_comma(),
          expand = expansion(mult = c(0, 0.05))
        ) +
        labs(x = label_of(input$metric), y = NULL) +
        theme_app() +
        theme(
          panel.grid.major.y = element_blank(),
          axis.text.y = element_text(size = 12, colour = "grey15")
        )
    },
    res = 96
  )

  # Compare two metrics

  # Join the two results, keep services with a value under both metrics,
  # and re-rank within that shared set so the ranks are comparable
  comparison <- reactive({
    validate(need(
      input$metric != input$metric_b,
      "Metric A and Metric B are the same. Choose two different metrics to compare."
    ))
    inner_join(
      result() |> select(service, value_a = value, rank_a = rank),
      result_b() |> select(service, value_b = value, rank_b = rank),
      by = "service"
    ) |>
      filter(!is.na(value_a), !is.na(value_b)) |>
      mutate(
        rank_a = min_rank(desc(value_a)),
        rank_b = min_rank(desc(value_b)),
        shift = rank_a - rank_b
      )
  })

  output$compare_note <- renderUI({
    d <- comparison()
    dropped <- union(
      attr(result(), "missing_services"),
      attr(result_b(), "missing_services")
    )
    rho <- cor(d$rank_a, d$rank_b, method = "spearman")
    agreement <- if (rho >= 0.7) {
      "strongly"
    } else if (rho >= 0.4) {
      "moderately"
    } else {
      "weakly"
    }

    tagList(
      p(
        strong(sprintf("Rank correlation: %.2f.", rho)),
        sprintf(
          "The two metrics agree %s on which services rank highest.",
          agreement
        )
      ),
      if (length(dropped) > 0) {
        p(
          class = "note",
          sprintf(
            "Not compared (missing a value for one of the metrics): %s.",
            paste(dropped, collapse = ", ")
          )
        )
      }
    )
  })

  output$scatter_plot <- renderPlot(
    {
      d <- comparison()
      validate(need(
        nrow(d) >= 3,
        "Fewer than three services have values for both metrics, so there is nothing meaningful to compare."
      ))

      la <- label_of(input$metric)
      lb <- label_of(input$metric_b)
      bench_a <- attr(result(), "benchmark")
      bench_b <- attr(result_b(), "benchmark")

      # Label the eight services whose rank differs most between the metrics
      movers <- d |>
        slice_max(abs(shift), n = 8, with_ties = FALSE) |>
        pull(service)
      d <- d |> mutate(mover = service %in% movers)

      # Total visits spans about 4k to 1.7m, so use a log scale for that metric only
      axis_scale <- function(key, axis) {
        if (key == "branch_visits") {
          if (axis == "x") {
            scale_x_log10(labels = scales::label_comma())
          } else {
            scale_y_log10(labels = scales::label_comma())
          }
        } else {
          if (axis == "x") {
            scale_x_continuous()
          } else {
            scale_y_continuous()
          }
        }
      }

      # Quadrant labels in the four corners of the panel.
      # I() places them as fractions of the panel, so they work on any scale.
      corners <- data.frame(
        x = I(c(0.98, 0.02, 0.98, 0.02)),
        y = I(c(0.98, 0.98, 0.02, 0.02)),
        hjust = c(1, 0, 1, 0),
        vjust = c(1, 1, 0, 0),
        label = c(
          "High on both",
          "High on B only",
          "High on A only",
          "Low on both"
        )
      )

      ggplot(d, aes(value_a, value_b)) +
        geom_vline(
          xintercept = bench_a,
          linetype = "dashed",
          colour = accent,
          linewidth = 0.8
        ) +
        geom_hline(
          yintercept = bench_b,
          linetype = "dashed",
          colour = accent,
          linewidth = 0.8
        ) +
        geom_text(
          data = corners,
          aes(x, y, label = label, hjust = hjust, vjust = vjust),
          inherit.aes = FALSE,
          colour = "grey45",
          fontface = "italic",
          size = 4
        ) +
        geom_point(aes(colour = mover), size = 3.2, alpha = 0.9) +
        geom_text(
          data = filter(d, mover),
          aes(label = service),
          vjust = -0.9,
          size = 3.8,
          colour = green_dark,
          fontface = "bold"
        ) +
        axis_scale(input$metric, "x") +
        axis_scale(input$metric_b, "y") +
        scale_colour_manual(
          values = c(`FALSE` = muted, `TRUE` = green_dark),
          guide = "none"
        ) +
        labs(x = paste("Metric A:", la), y = paste("Metric B:", lb)) +
        theme_app()
    },
    res = 96
  )

  # How to read this

  how_to_read <- function(...) {
    div(class = "how-to-read", p(strong("How to read this")), ...)
  }

  output$rank_help <- renderUI({
    bench <- attr(result(), "benchmark")
    is_total <- input$metric == "branch_visits"

    how_to_read(
      p(
        "Each bar is one library service, ranked from highest to lowest on ",
        em(label_of(input$metric)),
        " in ",
        input$year,
        "."
      ),
      p(
        "The dashed amber line is the municipal benchmark: ",
        if (is_total) {
          sprintf(
            "the average service (%s visits).",
            format(round(bench), big.mark = ",")
          )
        } else {
          sprintf(
            "the value for all municipal services combined (%.2f).",
            bench
          )
        },
        " Bars reaching past it are above the benchmark; shorter bars are below it."
      ),
      p(
        if (is_total) {
          "Raw totals largely reflect how many people a service covers, so large metropolitan and regional services dominate. Switch Metric A to a per-resident metric to see whether they are still the busiest once size is accounted for."
        } else {
          "This metric adjusts for size, so small services can rank highly. Compare the leaders here with those for total branch visits to see how much the answer to \u201cwhich library is busiest?\u201d changes."
        }
      ),
      p(
        "The ranking shows which services score higher on this measure, not why. It can't tell you whether a library is better run, better funded or just better located."
      )
    )
  })

  output$scatter_help <- renderUI({
    req(input$metric != input$metric_b)
    d <- comparison()
    req(nrow(d) >= 3)
    rho <- cor(d$rank_a, d$rank_b, method = "spearman")

    how_to_read(
      p(
        "Each dot is one library service, placed by its value on Metric A (across) ",
        "and Metric B (up). The dashed amber lines are each metric's municipal benchmark, ",
        "which split the chart into four quadrants:"
      ),
      tags$ul(
        tags$li(strong("High on both: "), "busy whichever way you measure it."),
        tags$li(
          strong("High on A only / High on B only: "),
          "services whose standing depends on the metric chosen. These are the ",
          "cases that answer the app's question."
        ),
        tags$li(
          strong("Low on both: "),
          "below the benchmark on both measures."
        )
      ),
      p(
        "The labelled dark green dots are the eight services whose rank changes most ",
        "between the two metrics."
      ),
      p(
        sprintf(
          "The rank correlation of %.2f summarises the whole chart. ",
          rho
        ),
        "Close to 1 means the two metrics rank services almost the same way. Close to 0 ",
        "means a service's rank on one tells you little about its rank on the other, so ",
        "\u201cbusiest\u201d depends on which metric you choose."
      ),
      p(
        "Visits and website visits count events, not people, and services that didn't ",
        "report a measure are left out. The chart shows association, not cause."
      )
    )
  })
}

shinyApp(ui, server)
