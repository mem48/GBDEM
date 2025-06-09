path = "C:/tiles/DTM_QGIS3_webp/"

fls = list.files(path, recursive = T, pattern = ".webp")
fls_size = file.size(file.path(path, fls))

dat = data.frame(path = fls, size = fls_size)
summary(dat$size == 54)
hist(dat$size, seq(0,338000, 1000))
sum(dat$size[dat$size < 100]) / sum(dat$size)

dat2 = dat[dat$size > 100,]
