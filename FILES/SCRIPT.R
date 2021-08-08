# Instalando pacotes ------------------------------------------------------
install.packages("httr")
install.packages("xml2")
install.packages("rvest")
install.packages("tibble")
install.packages("janitor")
install.packages("tidyverse")
install.packages("sf")
install.packages("purrr")
install.packages("leaflet")
install.packages("plotly")

# Carregando pacotes ------------------------------------------------------
library(httr)
library(xml2)
library(rvest)
library(tibble)
library(janitor)
library(tidyverse)
library(sf)
library(purrr)
library(leaflet)
library(plotly)

# Importando arquivo ------------------------------------------------------
r_capitals <- httr::GET(
  "https://lab.lmnixon.org/4th/worldcapitals.html",
  httr::user_agent("httr")
)

# Localizado e formatando a tabela ----------------------------------------
da_countries_raw <- r_capitals %>%
  xml2::read_html() %>% 
  xml2::xml_find_first("//table") %>% 
  rvest::html_table(header = TRUE) %>% 
  tibble::as_tibble() %>% 
  janitor::clean_names()

# Manipulando os dados ----------------------------------------------------
da_countries_tidy <- da_countries_raw %>% 
  filter(country != "") %>% 
  # Transforma (N,S) (E,W) em (1,-1), (1,-1)
  mutate(
    lat_num = str_detect(latitude, "N") * 2 - 1,
    lng_num = str_detect(longitude, "E") * 2 - 1
  ) %>% 
  # Transforma em numérico
  mutate(
    across(c(latitude, longitude), parse_number),
    lat = latitude * lat_num,
    lng = longitude * lng_num
  ) %>% 
  # Arruma coordenadas de Israel
  mutate(
    lat = if_else(country == "Israel", 31.7683, lat),
    lng = if_else(country == "Israel", 35.2137, lng)
  ) %>% 
  select(country, capital, lat, lng)


da_countries <- da_countries_tidy %>%
  mutate(pt = sf::st_sfc(
    map2(lng, lat, ~sf::st_point(c(.x, .y, 1))),
    crs = 4326
  )) %>%
  mutate(
    across(c(lat, lng), list(br = ~.x[country == "Brazil"])),
    pt_br = sf::st_sfc(
      list(sf::st_point(c(lng_br[1], lat_br[1], 1))), 
      crs = 4326
    )
  ) %>% 
  mutate(
    dist_br = sf::st_distance(pt, pt_br, by_element = TRUE),
    dist_br = as.numeric(dist_br / 1000)
  ) %>% 
  arrange(dist_br)

da_lines_sf <- da_countries %>%
  mutate(geometry = sf::st_sfc(
    purrr::map2(pt, pt_br, ~sf::st_linestring(c(.x, .y), dim = "XYZ"))
  )) %>%
  mutate(
    geometry = sf::st_line_sample(geometry, n = 30),
    geometry = sf::st_cast(geometry, "LINESTRING")
  ) %>%
  select(-pt, -pt_br) %>%
  arrange(desc(dist_br)) %>%
  head(10) %>%
  sf::st_as_sf()

# Tabelas -----------------------------------------------------------------
tab_perto <- da_countries %>% 
  arrange(dist_br) %>% 
  filter(country != "Brazil") %>% 
  select(country, capital, dist_br) %>% 
  head(10)

tab_longe <- da_countries %>% 
  arrange(-dist_br) %>% 
  filter(country != "Brazil") %>% 
  select(country, capital, dist_br) %>% 
  head(10)

# Mapa com leaflet -----------------------------------------------------
make_label <- function(pais, capital) {
  txt <- stringr::str_glue("<b>País</b>: {pais}<br/><b>Capital</b>: {capital}")
  htmltools::HTML(txt)
}

p_leaflet <- da_countries %>% 
  mutate(lab = map2(country, capital, make_label)) %>% 
  leaflet() %>% 
  addTiles() %>% 
  addMarkers(
    clusterOptions = markerClusterOptions(), 
    lat = ~lat, lng = ~lng, popup = ~lab
  )

# Mapa com plotly ------------------------------------------------------
world <- sf::st_as_sf(maps::map("world", plot = FALSE, fill = TRUE)) %>% 
  filter(!sf::st_is_empty(geom)) %>% 
  mutate(geom = sf::st_cast(geom, "MULTIPOLYGON"))

# Transformação de coordenadas
deg2rad <- function(degree) degree * pi / 180 
coord_x <- function(x, y) 1.001 * cos(deg2rad(x)) * cos(deg2rad(y))
coord_y <- function(x, y) 1.001 * sin(deg2rad(x)) * cos(deg2rad(y))
coord_z <- function(y) 1.001 * sin(deg2rad(y))
label_p <- function(pais, capital, dist) {
  stringr::str_glue(
    "<b>País</b>: {pais}<br>",
    "<b>Capital</b>: {capital}<br>",
    "<b>Distância</b>: {round(dist, 1)}km"
  )
}

p_plotly <- plot_ly(height = 1000) %>%
  add_sf(
    data = world, 
    x = ~coord_x(x, y),
    y = ~coord_y(x, y),
    z = ~coord_z(y),
    color = I("gray80"), 
    size = I(2),
    hoverinfo = "none"
  ) %>% 
  
  add_sf(
    data = da_lines_sf,
    name = "linhas",
    x = ~coord_x(x, y),
    y = ~coord_y(x, y),
    z = ~coord_z(y),
    color = ~dist_br,
    size = I(3),
    text = ~label_p(country, capital, dist_br),
    hoverinfo = "text"
  ) %>% 
  layout(showlegend = FALSE)

# Exportando arquivos -----------------------------------------------------
htmlwidgets::saveWidget(p_leaflet, "~/p_leaflet_map.html")
htmlwidgets::saveWidget(p_plotly, "~/p_plotly_map.html")
