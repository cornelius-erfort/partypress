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
plot_issue_agenda <- function(data, plot_issue, plot_party, facet = F) {
  if(is.null(data)) break
  
  if(is.null(plot_party)) plot_party <- unique(data[, "party"])
  if(is.null(plot_issue)) plot_party <- unique(data[, "issue_r1"])
  
  filename <- str_c(
                    ifelse(length(plot_issue) == 1, str_c(plot_issue, " - ", unique(data$issue_r1_descr[data$issue_r1 == plot_issue])), "all-issues"), 
                    "_", 
                    ifelse(length(plot_party) == 1,  plot_party %>% str_replace_all("/", "-"), "all-parties"), "_",
                    ifelse(facet, "facet_", ""),
                    deparse(substitute(data)) %>% str_remove("issue_agendas_")
                    )
  
  thisplot <- ggplot(data %>% filter(issue_r1 %in% plot_issue & party %in% plot_party), aes(x = date, y = attention)) +
    
    
    theme(axis.text.x = element_text(angle = 45, hjust=1)) +
    scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
    ylab("Share of press releases per quarter") 
  
  if(!facet & length(plot_party) > 1)  {
    thisplot <- thisplot +
    geom_smooth(method = "loess", formula = "y ~ x", lty = 1, se = F, aes(color = party)) +
    theme(legend.position = "bottom") +
    scale_color_manual(values = party_colors <- c("blue", "green", "black", "purple", "yellow", "red"))
  } else {
    thisplot <- thisplot +
      geom_step() +
      geom_smooth(method = "loess", formula = "y ~ x", color = "dark grey", lty = 2, se = F)
  }
  
  if(facet) thisplot + facet_wrap(~ party)
  
  thisplot +
    ggsave(str_c("plots/pdf/", filename, ".pdf"), device = cairo_pdf, width = 5*2^.5, height = 5) +
    ggsave(str_c("plots/png/", filename, ".png"), width = 5*2^.5, height = 5)
  
}



plot_agg_eval <- function(plot_data, method) ggplot(plot_data, aes(x = truth, y = predicted)) +
  geom_abline(slope = 1, color = "grey") +
  geom_point(shape = "O", aes(color = issue_r1)) +
  geom_text(label = agg_eval$issue_r1 %>% levels %>% str_extract("[:digit:]{1,2}(\\.[:digit:])?"), 
            nudge_x = .001, nudge_y = -.002, hjust = "left", 
            color = "dark grey", size = 3, family = "LM Roman 10") +
  ylim(c(0, .15)) + xlim(c(0, .15)) +
  guides(color = guide_legend(ncol = 1)) +
  labs(color = "Issue category", 
       caption = "The plot shows the mean values from a five-fold cross-validation.") +
  theme(legend.position = "right", # ifelse(method == "supervised", "left", "none"), 
        aspect.ratio = 1, 
        legend.text = element_text(size = 8),
        legend.key.size =  unit(.9,"line")) +
  ggsave(str_c("plots/agg_eval_", method, ".pdf"), 
         device = cairo_pdf, width = 4*2^.5, height = 4) +
  ggsave(str_c("plots/agg_eval_", method, ".png"), 
         width = 4*2^.5, height = 4)  
  