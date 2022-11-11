# Load libraries
library(tidyverse)
library(readxl)
library(httr)

# Yishuvim from the CBS file
url <- "https://www.cbs.gov.il/he/publications/doclib/2019/ishuvim/bycode2021.xlsx"
file_ext <- str_extract(url, "[0-9a-z]+$")
GET(url, write_disk(tf <- tempfile(fileext = file_ext)))  

yishuvim <- read_excel(tf, col_types = "text")

yishuvim <- yishuvim %>% 
  select(
    yishuv_id = 2,
    yishuv_name = 1
  ) %>% 
  mutate(
    yishuv_id = str_pad(yishuv_id, width = 4, side = "left", pad = "0")
  )

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

# Join data frames together
yishuvim <- yishuvim %>% 
  bind_rows(yishuvim_2) %>% 
  distinct(yishuv_name, .keep_all = TRUE)

# Write the CSV file
write_csv(yishuvim, "yishuv_names.csv")
