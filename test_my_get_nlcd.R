library(FedData)
library(sf)
library(dplyr)
library(magrittr)

nc <- st_read(system.file("shape/nc.shp", package="sf"))
st_crs(nc) # nad27 epsg 4267
nc_ashe <- nc[1,]

# use ashe co as template for get_nlcd
nc_ashe_sp <- as(nc_ashe, "Spatial")
nlcd_ashe <- get_nlcd(nc_ashe_sp, year = 2016, label = "nc1", dataset = "Land_Cover")
nlcd_ashe_albers <- my_get_nlcd(nc_ashe_sp, year = 2016, label = "nc1", dataset = "Land_Cover", output_crs = 5070, force.redo = TRUE)

# mask raster to county
nc_ashe_sp_prj <- nc_ashe %>% st_transform(proj4string(nlcd_ashe))
nlcd_ashe_mask <- raster::mask(nlcd_ashe, nc_ashe_sp_prj)

# calculate area from number and size of pixels
n_pix <- raster::freq(nlcd_ashe_mask) %>% as.data.frame() %>% 
  dplyr::filter(!is.na(value)) %>% pull(count) %>% sum()
area_m2 <- n_pix*xres(nlcd_ashe_mask)*yres(nlcd_ashe_mask)
area_m2/1e6

nc_ashe_sp_albers <- nc_ashe %>% st_transform(proj4string(nlcd_ashe_albers))
nlcd_ashe_albers_mask <- raster::mask(nlcd_ashe_albers, nc_ashe_sp_albers)

# calculate area from number and size of pixels
n_pix <- raster::freq(nlcd_ashe_albers_mask) %>% as.data.frame() %>% 
  dplyr::filter(!is.na(value)) %>% pull(count) %>% sum()
area_m2 <- n_pix*xres(nlcd_ashe_albers_mask)*yres(nlcd_ashe_albers_mask)
area_m2/1e6

