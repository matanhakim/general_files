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

# Write the CSV file
write_csv(yishuvim, "yishuv_names.csv")
