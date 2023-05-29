library(bvq)
library(tidyverse)
library(brms)
library(ggplot2)
library(tidybayes)
library(patchwork)

# set global options -----------------------------------------------------------

options(brms.backend = "cmdstanr",
        brms.file_refit = "on_change")

# get data ---------------------------------------------------------------------

participants <- bvq_participants()
responses <- bvq_responses(participants)
logs <- bvq_logs(participants, responses) |> 
    filter(grepl("Lockdown|Short", version)) 
vocabulary <- bvq_vocabulary(participants,
                             responses,
                             .scale = "count")

dataset <- vocabulary |> 
    inner_join(select(logs, id, age, time, lp),
               by = join_by(id, time)) |> 
    select(id, age, time, lp, total_count, l1_count) |> 
    filter(lp != "Other",
           between(age, 10, 32)) |> 
    drop_na()

saveRDS(dataset, "data/vocab_data.rds")

# visualise data ---------------------------------------------------------------

dataset |> 
    ggplot(aes(age, total_count,
               colour = lp, 
               fill = lp)) +
    geom_point(alpha = 1/5) +
    geom_smooth() +
    
    dataset |> 
    ggplot(aes(age, l1_count,
               colour = lp, 
               fill = lp)) +
    geom_point(alpha = 1/5) +
    geom_smooth() +
    theme(axis.title.y = element_blank(),
          axis.text.y = element_blank()) +
    
    plot_layout(nrow = 1,
                guides = "collect") &
    theme(legend.position = "top")


# fit models -------------------------------------------------------------------

fit_total <- brm(total_count ~ age * lp,
                 data = dataset,
                 family = poisson(),
                 file = "results/vocab_total.rds"
)

preds_total <- expand_grid(age = seq(10, 34, length.out = 100),
                           lp = c("Monolingual", "Bilingual")) |> 
    add_epred_draws(fit_total) 


fit_l1 <- brm(l1_count ~ age * lp,
              data = dataset,
              family = poisson(),
              file = "results/vocab_l1.rds"
)

preds_l1 <- expand_grid(age = seq(10, 34, length.out = 100),
                        lp = c("Monolingual", "Bilingual")) |> 
    add_epred_draws(fit_l1) 

vocab_preds <- bind_rows(Total = preds_total, 
                         L1 = preds_l1,
                         .id = ".type")

saveRDS(vocab_preds, "results/vocab_preds.rds")



