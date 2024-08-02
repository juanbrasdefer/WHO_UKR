

#install whomapper for ukraine oblast shapefile
# devtools::install_github("whocov/whomapper", 
#                           force = TRUE, 
#                           dependencies = TRUE)



# libraries, directory----------------------------------------------------------
library(tidyverse) # facilitate data pipeline
library(here) # easily set paths
library(whomapper) # extensive and up to date shapefiles
library(sf) # working with simple features
library(patchwork)


# setting path
here::i_am("code/matrix_mapping.R")




# loading data ------------------------------------------------------------------
matrix_data <- read_csv(here("data/matrix_scores_prelim.csv")) 


# whomapper pull simple features function; becomes dataframe
oblasts_sf <- whomapper::pull_sfs(adm_level = 1,         #level 1 = 'prepackaged'
                                  iso3 = "UKR",              #iso code for ukraine
                                  query_server = TRUE) %>%   #query to get latest 
  rename(oblast = "adm1_viz_name") # rename so we can join


# then join some data to it
sf_and_matrix <- oblasts_sf %>%
  left_join(matrix_data, by = "adm1_altcode")




# add some centroid coordinates for labels
sf_and_matrix_coords <- st_centroid(sf_and_matrix)
df_sf <- st_as_sf(sf_and_matrix_coords, wkt = "geometry")
coordinates <- st_coordinates(df_sf$geometry)
df_coordinates <- as_data_frame(coordinates)



# join one last time
sf_and_matrix_usable <- df_coordinates %>% 
  cbind(sf_and_matrix)



