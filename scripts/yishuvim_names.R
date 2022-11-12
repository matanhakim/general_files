# Load libraries
library(tidyverse)
library(readxl)
library(httr)

# Yishuvim from the CBS file, both Hebrew and English
url <- "https://www.cbs.gov.il/he/publications/doclib/2019/ishuvim/bycode2021.xlsx"
file_ext <- str_extract(url, "[0-9a-z]+$")
GET(url, write_disk(tf <- tempfile(fileext = file_ext)))  

yishuvim <- read_excel(tf, col_types = "text")

yishuvim <- yishuvim %>% 
  select(
    yishuv_id = 2,
    yishuv_name = 1,
    yishuv_name_eng_1 = 25
  ) %>% 
  mutate(
    yishuv_id = str_pad(yishuv_id, width = 4, side = "left", pad = "0"),
    yishuv_name_eng_2 = str_to_lower(yishuv_name_eng_1),
    yishuv_name_eng_3 = str_to_upper(yishuv_name_eng_1)
  ) %>% 
  pivot_longer(!yishuv_id, names_to = "name", values_to = "yishuv_name") %>% 
  select(!name)

# Yishuvim from Ido Lan
yishuvim_2 <- read_excel("yishuvim_names_files/yishuvim_ido_lan.xls", col_types = "text")

yishuvim_2 <- yishuvim_2 %>% 
  select(
    yishuv_name_1 = yeshuv,
    yishuv_name_2 = `fixed name`,
    yishuv_id = semelyeshuv
  ) %>% 
  mutate(
    yishuv_id = str_pad(yishuv_id, width = 4, side = "left", pad = "0")
  ) %>% 
  pivot_longer(!yishuv_id, names_to = "name", values_to = "yishuv_name") %>% 
  select(!name) %>% 
  distinct(yishuv_name, .keep_all = TRUE)

# Yishuvim as municipalities from CBS municipalities list, education ministry and tax authority using my own data file
yishuvim_3 <- read_csv("muni_ids.csv")

yishuvim_3 <- yishuvim_3 %>% 
  select(!c(edu_id, tax_id)) %>% 
  pivot_longer(!cbs_id, names_to = "var", values_to = "yishuv_name") %>% 
  rename(yishuv_id = cbs_id) %>%
  select(!var) %>% 
  distinct(yishuv_name, .keep_all = TRUE)

# Yishuvim from the list of regitered amutot from Guidestar.
# These id's were chosen by hand for each yishuv that did not match the existing names so far.
yishuvim_4 <- read_csv("yishuvim_names_files/yishuvim_orgs1.csv", col_types = "c")
yishuvim_5 <- read_csv("yishuvim_names_files/yishuvim_orgs2.csv", col_types = "c")

# Join data frames together
yishuvim <- yishuvim %>% 
  bind_rows(yishuvim_2, yishuvim_3, yishuvim_4, yishuvim_5) %>% 
  distinct(yishuv_name, .keep_all = TRUE)

# Write the CSV file
write_csv(yishuvim, "yishuv_names.csv")
