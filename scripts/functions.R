# Word vector loading function
proc_pretrained_vec <- function(p_vec) {
  
  # initialize space for values and the names of each word in vocab
  vals <- vector(mode = "list", length(p_vec))
  names <- character(length(p_vec))
  
  # loop through to gather values and names of each word
  for(i in 1:length(p_vec)) {
    if(i %% 1000 == 0) {print(i)}
    this_vec <- p_vec[i]
    this_vec_unlisted <- unlist(strsplit(this_vec, " "))
    this_vec_values <- as.numeric(this_vec_unlisted[-1])  # this needs testing, does it become numeric?
    this_vec_name <- this_vec_unlisted[1]
    
    vals[[i]] <- this_vec_values
    names[[i]] <- this_vec_name
  }
  
  # convert lists to data.frame and attach the names
  glove <- data.frame(vals)
  names(glove) <- names
  
  return(glove)
  

}



###########
# Plotting
###########

# Function for plotting parties' issue attention over time
plot_issue_agenda <- function(plot_data, plot_issue, plot_party, facet = F) {
  if(is.null(data)) break
  
  if(is.null(plot_party)) plot_party <- unique(plot_data[, "party"])
  if(is.null(plot_issue)) plot_party <- unique(plot_data[, "issue"])
  
  methodname <- deparse(substitute(plot_data)) %>% str_extract("(supervised_lag)|(readme_lag)|(supervised)|(readme)") %>% str_replace("_", "-")
  
  filename <- str_c(
                    ifelse(length(plot_issue) == 1, str_c(plot_issue, " - ", unique(plot_data$issue_descr[plot_data$issue == plot_issue])), "all-issues"), 
                    "_", 
                    ifelse(length(plot_party) == 1,  plot_party %>% str_replace_all("/", "-"), "all-parties"), "_",
                    ifelse(facet, "facet", ""),
                    ifelse("method" %in% names(plot_data), "compare", ""),
                    ifelse(!is.na(methodname), methodname, "")
                    )
  
  print(filename)

  thisplot <- ggplot(plot_data %>% filter(issue %in% plot_issue & party %in% plot_party), aes(x = date, y = attention)) +
    
    
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          text = element_text(size = 16)) +
    scale_x_date(date_breaks = "2 years", date_labels = "%Y", limits = c(plot_data$date %>% min, plot_data$date %>% max)
) +
    ylab("Share of press releases per quarter")
  
  if(min(plot_data$attention) >= 0) thisplot <- thisplot + ylim(c(0, NA))
  
  if(plot_issue == 9) {
    
    thisplot <- thisplot +
      geom_vline(xintercept = ymd("2015-08-31"), color = "dark grey", lty = 2)
    
    if(!facet) {
      thisplot <- thisplot +
        geom_text(color = "grey", y = 0, x = ymd("2015-06-30"), 
                  label = c('"Wir schaffen das"'), 
                  hjust = "left",
                  family = "LM Roman 10",
                  angle = 90)
    }
    
  }
  
  if(plot_issue == 7) {
    thisplot <- thisplot +
      geom_vline(xintercept = c( ymd("2018-08-20")), color = "dark grey", lty = 2) 
      
    if(!facet) {
      thisplot <- thisplot +
        geom_text(color = "grey", y = 0, x = ymd("2018-06-20"), 
                  label = c("Fridays for Future"),
                  family = "LM Roman 10",
                  angle = 90, hjust = "left")
    }

  }
  
  if(!facet & length(plot_party) > 1)  {
    thisplot <- thisplot +
    # geom_smooth(method = "loess", formula = "y ~ x", lty = 1, se = F, aes(color = party), alpha = .3) +
    geom_line(stat="smooth", method = "loess", formula = "y ~ x",
                size = .5,
                linetype ="dashed",
                alpha = 0.5,
                se = F, aes(color = party)) +
    theme(legend.position = "bottom") +
    scale_color_manual(values = c("blue", "green", "black", "purple", "yellow", "red"))
  } else {
    if(!("method" %in% names(plot_data))) {
      thisplot <- thisplot +
        geom_step(color = "dark grey", alpha = .8) +
        #geom_smooth(method = "loess", formula = "y ~ x", color = "dark grey", lty = 2, se = F, alpha = .3)
        geom_line(stat="smooth", method = "loess", formula = "y ~ x",
                size = .7,
                linetype ="dashed",
                alpha = 0.8, color = "black",
                se = F)
      
      
    } else 
      thisplot <- thisplot +
        geom_step(aes(color = method, lty = method), alpha = .8) +
        theme(legend.position = "bottom")
  }
  
  if(facet) thisplot <- thisplot + facet_wrap(~ party)
  
  thisplot
    ggsave(str_c("plots/", filename, ".pdf"), device = cairo_pdf, width = 5*2^.5, height = 5)
    ggsave(str_c("plots/", filename, ".png"), width = 5*2^.5, height = 5)
  
}



plot_agg_eval <- function(plot_data, method) { ggplot(plot_data, aes(x = truth, y = predicted)) +
  geom_abline(slope = 1, color = "grey") +
  geom_point(shape = "O", aes(color = issue)) +
  geom_text(label = agg_eval$issue %>% levels %>% str_extract("[:digit:]{1,2}(\\.[:digit:])?"), 
            nudge_x = .001, nudge_y = -.002, hjust = "left", 
            color = "dark grey", size = 3, family = "LM Roman 10") +
  ylim(c(0, .2)) + xlim(c(0, .2)) +
  guides(color = guide_legend(ncol = 1)) +
  labs(color = "Issue category", 
       caption = "The plot shows the mean values from a five-fold cross-validation.") +
  theme(legend.position = "right", # ifelse(method == "supervised", "left", "none"), 
        aspect.ratio = 1, 
        legend.text = element_text(size = 8),
        legend.key.size =  unit(.9,"line")) 
  ggsave(str_c("plots/agg_eval_", method, ".pdf"), 
         device = cairo_pdf, width = 4*2^.5, height = 4) 
  ggsave(str_c("plots/agg_eval_", method, ".png"), 
         width = 4*2^.5, height = 4)  

}

  