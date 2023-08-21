## ---- echo = FALSE, message = FALSE, warning=FALSE, error=FALSE---------------
knitr::opts_chunk$set(collapse = T, comment = "#>")
options(tibble.print_min = 4, tibble.print_max = 4)

## ----makequery, message = FALSE, warning=FALSE, error=FALSE-------------------
library(eurlex)
library(dplyr)

query_dir <- elx_make_query(resource_type = "directive")

## ----precompute, include=FALSE------------------------------------------------
dirs <- elx_make_query(resource_type = "directive", include_date = TRUE, include_force = TRUE) %>% 
  elx_run_query()

results <- dirs %>% select(-force,-date)

## -----------------------------------------------------------------------------
query_dir %>% 
  cat()

elx_make_query(resource_type = "caselaw") %>% 
  cat()

elx_make_query(resource_type = "manual", manual_type = "SWD") %>% 
  cat()


## -----------------------------------------------------------------------------
elx_make_query(resource_type = "directive", include_date = TRUE, include_force = TRUE) %>% 
  cat()

# minimal query: elx_make_query(resource_type = "directive")

elx_make_query(resource_type = "recommendation", include_date = TRUE, include_lbs = TRUE) %>% 
  cat()

# minimal query: elx_make_query(resource_type = "recommendation")


## -----------------------------------------------------------------------------
# request documents from directory 18 ("Common Foreign and Security Policy")
# and sector 3 ("Legal acts")

elx_make_query(resource_type = "any",
               directory = "18",
               sector = 3) %>% 
  cat()

## ----runquery, eval=FALSE-----------------------------------------------------
#  results <- elx_run_query(query = query_dir)
#  
#  # the functions are compatible with piping
#  #
#  # elx_make_query("directive") %>%
#  #   elx_run_query()

## -----------------------------------------------------------------------------
as_tibble(results)

## -----------------------------------------------------------------------------
head(results$type,5)

results %>% 
  distinct(type)

## ----eurovoc------------------------------------------------------------------

rec_eurovoc <- elx_make_query("recommendation", include_eurovoc = TRUE, limit = 10) %>% 
  elx_run_query() # truncated results for sake of the example

rec_eurovoc %>% 
  select(celex, eurovoc)


## ----eurovoctable-------------------------------------------------------------
eurovoc_lookup <- elx_label_eurovoc(uri_eurovoc = rec_eurovoc$eurovoc)

print(eurovoc_lookup)

## ----appendlabs---------------------------------------------------------------
rec_eurovoc %>% 
  left_join(eurovoc_lookup)

## -----------------------------------------------------------------------------
eurovoc_lookup <- elx_label_eurovoc(uri_eurovoc = rec_eurovoc$eurovoc,
                                    alt_labels = TRUE,
                                    language = "sk")

rec_eurovoc %>% 
  left_join(eurovoc_lookup) %>% 
  select(celex, eurovoc, labels)

## ----getdatapur, message = FALSE, warning=FALSE, error=FALSE------------------
# the function is not vectorized by default
# elx_fetch_data(url = results$work[1], type = "title")

# we can use purrr::map() to play that role
library(purrr)

# wrapping in possibly() would catch errors in case there is a server issue
dir_titles <- results[1:5,] %>% # take the first 5 directives only to save time
  mutate(work = paste("http://publications.europa.eu/resource/cellar/", work, sep = "")) |> 
  mutate(title = map_chr(work, possibly(elx_fetch_data, otherwise = NA_character_),
                         "title")) %>% 
  as_tibble() %>% 
  select(celex, title)

print(dir_titles)


## ----dirsdata, eval=FALSE-----------------------------------------------------
#  dirs <- elx_make_query(resource_type = "directive", include_date = TRUE, include_force = TRUE) %>%
#    elx_run_query()

## ----firstplot, message = FALSE, warning=FALSE, error=FALSE-------------------
library(ggplot2)

dirs %>% 
  count(force) %>% 
  ggplot(aes(x = force, y = n)) +
  geom_col()

## ----dirforce-----------------------------------------------------------------
dirs %>% 
  filter(!is.na(force)) %>% 
  mutate(date = as.Date(date)) %>% 
  ggplot(aes(x = date, y = celex)) +
  geom_point(aes(color = force), alpha = 0.1) +
  theme(axis.text.y = element_blank(),
        axis.line.y = element_blank(),
        axis.ticks.y = element_blank())

## ----dirtitles----------------------------------------------------------------
dirs_1970_title <- dirs %>% 
  filter(between(as.Date(date), as.Date("1970-01-01"), as.Date("1973-01-01")),
         force == "true") %>% 
  mutate(work = paste("http://publications.europa.eu/resource/cellar/", work, sep = "")) |> 
  mutate(title = map_chr(work, possibly(elx_fetch_data, otherwise = NA_character_),
                         "title")) %>%  
  as_tibble()

print(dirs_1970_title)

## ----wordcloud, message = FALSE, warning=FALSE, error=FALSE-------------------
library(tidytext)
library(wordcloud)

# wordcloud
dirs_1970_title %>% 
  select(celex,title) %>% 
  unnest_tokens(word, title) %>% 
  count(celex, word, sort = TRUE) %>% 
  filter(!grepl("\\d", word)) %>% 
  bind_tf_idf(word, celex, n) %>% 
  with(wordcloud(word, tf_idf, max.words = 40))

