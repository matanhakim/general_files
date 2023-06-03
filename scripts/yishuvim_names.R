# Load libraries
library(tidyverse)
library(readxl)

# Yishuvim from the CBS file, both Hebrew and English
yishuvim <- read_excel("data/bycode2021.xlsx", col_types = "text")

yishuvim <- yishuvim %>% 
  select(
    yishuv_id = 2,
    yishuv_name = 1,
    yishuv_name_eng_1 = 25
  ) %>% 
  mutate(
    yishuv_id = str_pad(yishuv_id, width = 4, side = "left", pad = "0"),
    yishuv_name_eng_2 = str_to_lower(yishuv_name_eng_1),
    yishuv_name_eng_3 = str_to_upper(yishuv_name_eng_1),
    yishuv_name_eng_4 = str_to_sentence(yishuv_name_eng_1),
    yishuv_name_eng_5 = str_to_title(yishuv_name_eng_1)
  ) |> 
  pivot_longer(!yishuv_id, names_to = "name", values_to = "yishuv_name") |> 
  select(!name)

# Yishuvim as municipalities from CBS municipalities list, education ministry and tax authority using my own data file
yishuvim_3 <- read_csv("muni_ids.csv")

yishuvim_3 <- yishuvim_3 %>% 
  filter(str_length(cbs_id) > 2) %>% 
  select(!c(edu_id, tax_id)) %>% 
  pivot_longer(!cbs_id, names_to = "var", values_to = "yishuv_name") %>% 
  rename(yishuv_id = cbs_id) %>%
  select(!var) %>% 
  distinct(yishuv_name, .keep_all = TRUE)

# Yishuvim from the list of regitered amutot from Guidestar.
# These id's were chosen by hand for each yishuv that did not match the existing names so far.
yishuvim_4 <- read_csv("yishuvim_names_files/yishuvim_orgs1.csv", col_types = "c")
yishuvim_5 <- read_csv("yishuvim_names_files/yishuvim_orgs2.csv", col_types = "c")
yishuvim_6 <- tribble(
  ~ yishuv_id, ~ yishuv_name,
  "0217", "כפר הרא~ה",
  "0696", "כפר חב~ד"
)
# Join data frames together
yishuvim <- yishuvim %>% 
  bind_rows(yishuvim_2, yishuvim_3, yishuvim_4, yishuvim_5, yishuvim_6) %>% 
  distinct(yishuv_name, .keep_all = TRUE)

# Write the CSV file
write_csv(yishuvim, "yishuv_names.csv")
