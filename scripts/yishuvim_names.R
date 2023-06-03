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
yishuvim_2 <- read_csv("muni_ids.csv", col_types = cols(.default = "c")) |> 
  select(!c(edu_id, tax_id)) |> 
  pivot_longer(!cbs_id, names_to = "var", values_to = "yishuv_name") |> 
  rename(yishuv_id = cbs_id) |>
  select(!var) |> 
  distinct(yishuv_name, .keep_all = TRUE)

# Yishuvim from the list of regsitered amutot from Guidestar.
# These id's were chosen by hand for each yishuv that did not match the existing names so far.
yishuvim_3 <- tibble(
  yishuv_name = c(
    "תל אביב - יפו",
    "דנ גליל עליון",
    "מעין ברוך", 
    "בנימינה",
    "דנ חפר",
    "מא יואב",
    "עופרה",
    "פרדס-חנה כרכור",
    "מא רמת הנגב דנ חלוצה", 
    "מגד אל-כרום",
    "חברון", 
    "מועצה אזורית אשכול",
    "אז\"ת שער בנימין",
    "מג'ד אל כרום",
    "ריחאניה",
    "צמח",
    "נתב\"ג",
    "מא רמת הנגב"
  ),
  yishuv_id = c(
    "5000",
    "01",
    "0416",
    "9800",
    "16",
    "35",
    "3617",
    "7800",
    "48",
    "0516",
    "1983",
    "38",
    "73",
    "0516",
    "0540",
    "1711",
    "1748",
    "48"
  )
)
# Join data frames together
yishuvim <- yishuvim %>% 
  bind_rows(yishuvim_2, yishuvim_3, yishuvim_4, yishuvim_5, yishuvim_6) %>% 
  distinct(yishuv_name, .keep_all = TRUE)

# Write the CSV file
write_csv(yishuvim, "yishuv_names.csv")
