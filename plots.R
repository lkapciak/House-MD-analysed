library(tidyverse)
library(tidytext)
library(stringi)
library(tm)
library(png)

library(wordcloud)
library(wordcloud2)
library(RColorBrewer)
library(gganatogram)

# Using "todo" frame from data_cleaning.R for the anatogram
todo = read_csv("data/house_md_data.csv")

# Using house_episodes and house_imdb for the rest of the plots
encoding = "UTF-8"
house_episodes = read_csv("data/house_episodes.csv", locale = locale(encoding = encoding))
house_imdb = read_csv("data/house_imdb.csv", locale = locale(encoding = encoding))


seasons_list = list()
for (i in 1:8) {
  file_name = paste0("data/season", i, ".csv.xls")
  season_data =
    read_csv(file_name, locale = locale(encoding = encoding))

  season_data = season_data %>%
    mutate(season = i)
  
  seasons_list[[i]] = season_data
}

all_seasons = do.call(rbind, seasons_list)

# IMDb ratings heatmap ----

heat_map =
  ggplot(house_imdb, aes(y = season,
                         x = episode_num,
                         fill = cut(
                           imdb_rating,
                           breaks = c(0, 8, 8.5, 9, 9.5, 10),
                           include.lowest = TRUE))) +
  geom_tile() +
  scale_fill_manual(
    values = c("#9497f1","#8b84f3", "#7e6df6","#6149fa", "#2b19fe"),
    labels = c(
      "< 8",
      "[8, 8.5)",
      "[8.5, 9)",
      "[9, 9.5)",
      "≥ 9.5"
    )
  ) +
  geom_text(aes(label = round(imdb_rating, 1)), color = "white", size = 5.5) +
  labs(fill = "",
       x = "",
       y = "",
       title = "") +
  scale_y_continuous(expand = c(0, 0), breaks = 1:8) +
  scale_x_continuous(breaks = 1:25, expand = c(0, 0)) +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = NA),
    panel.background = element_rect(fill='transparent'), 
    plot.background = element_rect(fill='transparent'),  
    legend.background = element_rect(fill='transparent'), 
    legend.box.background = element_rect(fill='transparent', color = "transparent"),
    axis.text.x = element_text(color = "white", size = 15),  
    axis.text.y = element_text(color = "white", size = 15),
    panel.border = element_blank(),
    legend.text = element_text(color = "white", size = 15),
    legend.key.size = unit(1, "cm")
  )

heat_map

ggsave('plots/heatmap.png', heat_map, bg='transparent', width = 13, height = 8)

# Viewers per episode ----

# viewers_plot = house_episodes %>%
#   group_by(season) %>%
#   summarise(n = sum(us_viewers)) %>%
#   ggplot(aes(x = season, 
#              y = n / 10^6)) + 
#   geom_col() +
#   scale_y_continuous(expand = c(0, 0), breaks = seq(0, 500, by = 100)) +
#   scale_x_continuous(breaks = 1:8, expand = c(0, 0)) +
#   labs(x = "Season", 
#        y = "US viewers in milions", 
#        title = "How many US viewers has every season had?") +
#   theme(panel.background = element_rect(fill = '#CCDBDC', colour = '#CCDBDC')) +
#   theme(plot.background = element_rect(fill = '#CCDBDC', colour = '#CCDBDC')) +
#   theme(legend.background = element_rect(fill = '#CCDBDC', colour = '#CCDBDC')) +
#   theme(
#     panel.grid.major = element_blank(),
#     panel.grid.minor = element_blank(),
#     panel.background = element_blank(),
#     axis.line = element_line(colour = "black")
#   )
# 
# viewers_plot

# This plot turned out to be less interesting than we thought - we chose to use
# a line plot for each episode as it represents the changes better.




viewers_plot <- house_episodes %>%
  ggplot(aes(x = episode_num_overall, 
             y = us_viewers/10^6)) + 
  geom_line(color = "white") +
  scale_y_continuous() +
  scale_x_continuous(expand = c(0,0), 
                     breaks = c(22.5, 46.5, 70.5, 86.5, 110.5, 132.5, 155.5),
                     labels = NULL) +
  labs(x = NULL, 
       y = "", 
       title = "") +
  theme(
    panel.background = element_rect(fill = 'transparent'),
    plot.background = element_rect(fill = 'transparent'),
    legend.background = element_rect(fill = 'transparent'),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = NA),
    panel.border = element_blank(),
    axis.text.x = element_text(color = "white", size = 15),  # Zmieniamy kolor liczb na osi X na biały
    axis.text.y = element_text(color = "white", size = 15),
    legend.text = element_text(color = "black", family = "times new roman", size = 12)# Usunięcie ramki wokół wykresu
  ) +
  geom_vline(xintercept = c(22.5, 46.5, 70.5, 86.5, 110.5, 132.5, 155.5),
             linetype = 'dashed',
             linewidth = 0.25, color = "white") +
  geom_point(aes(x = 172, y = us_viewers/10^6), size = 4.5, shape = 21, fill = "white", data = house_episodes[172,]) +
  geom_point(aes(x = 81, y = us_viewers/10^6), size = 4.5, shape = 21, fill = "white", data = house_episodes[81,]) 

viewers_plot

ggsave('plots/viewers_plot.png', viewers_plot, bg='transparent', width = 12, height = 8)



# 'Moron' and 'idiot' barplot ----

search_for = c("idiot", "Idiot", "moron", "Moron")

all_seasons_wo_brackets <- all_seasons %>%
  mutate(line = str_replace(line, "\\[.*?\\]", "")) %>%
  mutate(name = str_remove_all(name, "\\s+"))


idiot_or_moron = all_seasons_wo_brackets %>%
  filter(name == "House" &
           str_detect(line, paste(search_for, collapse = "|"))) %>%
  mutate(matched_word = str_extract_all(line, paste(search_for, collapse = "|"))) %>%
  unnest(matched_word) %>%
  mutate(matched_word = tolower(matched_word)) %>%  
  group_by(season, matched_word) %>%
  summarise(n = n()) %>%
  mutate(
    matched_word = if_else(matched_word == "moron", "Moron", matched_word),
    # Convert "moron" to "Moron"
    matched_word = if_else(matched_word == "idiot", "Idiot", matched_word)
  )  # Convert "idiot" to "Idiot"



idiot_plot <- idiot_or_moron %>%
  ggplot() +
  geom_col(aes(x = season, y = n, fill = matched_word), position = "dodge") +
  labs(x = "", y = "") +
  theme_bw() +
  scale_fill_manual(values = c("Idiot" = "#7e6df6", "Moron" = "#2b19fe")) +
  scale_y_continuous(
    expand = c(0, 0),
    limits = c(0, 40),
    breaks = seq(0, 40, by = 5)
  ) +
  scale_x_continuous(breaks = 1:8, expand = c(0, 0)) +
  labs(fill = "", title = "") +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = 'transparent', color = 'transparent'), 
    plot.background = element_rect(fill = 'transparent'), 
    legend.background = element_rect(fill = 'transparent', color = 'transparent'), 
    legend.box.background = element_rect(fill = 'transparent', color = 'transparent'),
    axis.text.x = element_text(color = "white", size = 15),  
    axis.text.y = element_text(color = "white", size = 15),
    panel.border = element_blank(), 
    axis.line = element_line(colour = "transparent"),
    legend.key.size = unit(1.5, "cm")
  )


idiot_plot

ggsave('plots/idiot_plot.png', idiot_plot, bg='transparent', width = 10, height = 11)


# Wordcloud ----
# We decided not to use it in the final poster.

# word_count = all_seasons %>%
#   mutate(line = str_replace(line, "\\[.*?\\]", "")) %>% #removing text in [brackets]
#   group_by(line) %>%
#   unnest_tokens(word, line) %>% #packages tidytext
#   group_by(word) %>%
#   summarise(how_many = n()) %>%
#   arrange(-how_many)
# 
# keep_those = c(
#   108,110,114,117,130,144,
#   145,154,156,173,179,207,
#   215,222,231,234,238,239,
#   241,253,265,274,284,290,
#   301,302,314,319,320,328,
#   329,330,338,345,348,352,
#   358,361,367,370
# )
# 
# filtered_word_count = word_count %>%
#   slice(keep_those)
# 
# 
# pill_wordcloud = wordcloud2(
#   filtered_word_count,
#   figPath = "data/pill.jpg",
#   color = "#2C7DA0",
#   size = 0.35,
#   backgroundColor = "#012A4A")
# 
# pill_wordcloud

# Anatogram ----
# The order is necessary for the gganatogram() function to work properly;
# if not added, the order will be alphabetical and the graph will be drawn improperly

# devtools::install_github("jespermaag/gganatogram")

organs_order = data.frame(organ = c('heart','breast', 'lung', 'nasal_pharynx', 'urinary_bladder', 'bone', 
                                    'stomach', 'spleen', 'liver',  'colon', 'leukocyte', 'kidney', 'nerve', 
                                    'bronchus', 'bone_marrow', 'brain', 'lymph_node',  
                                    'nose', 'placenta', 'pancreas', 'skeletal_muscle', 'skin',
                                    'thyroid_gland'),
                          organs_order = 1:23) 


organs_frequency = todo %>% 
  filter(!is.na(organs_affected)) %>% 
  separate_rows(organs_affected, sep = ", ") %>% 
  group_by(organs_affected) %>% 
  summarize(value = n()) %>%
  rename(organ = organs_affected) %>% 
  left_join(organs_order) %>% 
  filter(value >= 5) # although we lose some data, we gain a clearer image

anatogram = gganatogram(
  data = arrange(organs_frequency, desc(organs_order)), # first rows are drawn first
  organism = "human",
  sex = "female",
  fill = "value") +
  theme_void() +
  scale_fill_gradient(low = "lightblue", high = "blue") +
  theme(
    panel.background = element_rect(fill='transparent', color = NA), #transparent panel bg
    plot.background = element_rect(fill='transparent', color=NA), #transparent plot bg
    panel.grid.major = element_blank(), #remove major gridlines
    panel.grid.minor = element_blank(), #remove minor gridlines
    legend.background = element_rect(fill='transparent', color = NA), #transparent legend bg
    legend.box.background = element_rect(fill='transparent', color = NA), 
    legend.text = element_text(color = "white"))+ #transparent legend panel
  labs(fill = "")

anatogram

ggsave('plots/anatogram.png', anatogram, bg='transparent', width = 8, height = 12)






