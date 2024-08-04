

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
library(glue)


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




























# plots --------------------------------------------------------------------
#final final plots... hahaha maybe

# EXPOSURE
variable_to_show <- "exposure"
sf_and_matrix_usable$exposure <- as.character(sf_and_matrix_usable$exposure)

pl_exposure <- ggplot() +
  geom_sf(data = sf_and_matrix_usable, 
          aes_string(fill = variable_to_show,
                     geometry = "geometry")) +
  scale_fill_brewer(palette = "Blues", direction = 1)  +
  labs(fill = glue("Exposure Severity")) +
  theme_bw() +
  theme_void()+ 
  theme(plot.background = element_rect(fill = "white"),
        legend.position = c(0.15, 0.20),
        aspect.ratio = 0.65)


ggsave(here("plots/pl_exposure.png"), 
       pl_exposure, 
       width = 8, 
       height = 4)





# VULNERABILITY
variable_to_show <- "vulnerability"
#sf_and_matrix_usable$vulnerability <- as.character(sf_and_matrix_usable$vulnerability)

pl_vulnerability <- ggplot() +
  geom_sf(data = sf_and_matrix_usable, 
          aes_string(fill = variable_to_show,
                     geometry = "geometry")) +
  #scale_fill_brewer(palette = "YlOrBr", direction = 1)  +
  scale_fill_gradient(low = "yellow", high = "maroon") +
  labs(fill = glue("Vulnerability")) +
  theme_bw() +
  theme_void()+ 
  theme(plot.background = element_rect(fill = "white"),
        legend.position = c(0.15, 0.20),
        aspect.ratio = 0.65) +
   geom_text(data = sf_and_matrix_usable, 
             aes(x = X, y = Y, label = vulnerability),
             size = 3, color = "white")


ggsave(here("plots/pl_vulnerability.png"), 
       pl_vulnerability, 
       width = 8, 
       height = 4)




# COPING CAPACITY
variable_to_show <- "coping"
#sf_and_matrix_usable$coping <- as.character(sf_and_matrix_usable$coping)

pl_coping <- ggplot() +
  geom_sf(data = sf_and_matrix_usable, 
          aes_string(fill = variable_to_show,
                     geometry = "geometry")) +
  #scale_fill_brewer(palette = "YlOrBr", direction = 1)  +
  scale_fill_gradient(low = "lightgreen", high = "darkgreen") +
  labs(fill = glue("coping")) +
  theme_bw() +
  theme_void()+ 
  theme(plot.background = element_rect(fill = "white"),
        legend.position = c(0.15, 0.20),
        aspect.ratio = 0.65) + 
 geom_text(data = sf_and_matrix_usable, 
           aes(x = X, y = Y, label = coping),
           size = 3, color = "white")


ggsave(here("plots/pl_coping.png"), 
       pl_coping, 
       width = 8, 
       height = 4)




# FINAL CATEGORIZATION
variable_to_show <- "risk_categorization"

pl_risk_categorization <- ggplot() +
  geom_sf(data = sf_and_matrix_usable, 
          aes_string(fill = variable_to_show,
                     geometry = "geometry")) +
  scale_fill_brewer(palette = "YlOrRd", direction = -1)  +
  labs(
    fill = glue("Final Risk Categorization")
  ) +
  # geom_text(data = sf_and_matrix_usable, 
  #           aes(x = X, y = Y, label = oblast),
  #           size = 2) +
  theme_bw() +
  theme_void()+ 
  theme(plot.background = element_rect(fill = "white"),
        legend.position = c(0.15, 0.20),
        aspect.ratio = 0.65)




ggsave(here("plots/pl_risk_categorization.png"), 
       pl_risk_categorization, 
       width = 8, 
       height = 4)







