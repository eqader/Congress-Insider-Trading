######################
#Custom Functionality#
######################

check_packages <- function(packages, check = TRUE, load = TRUE, supress = FALSE){
        if(check == TRUE & supress == FALSE){
                for(i in packages){
                        print(as.character(i) %in% rownames(installed.packages()))        
                }
        }
        
        if(load == TRUE){
                for(i in packages){
                        if(as.character(i) %in% rownames(installed.packages()) == FALSE){
                                install.packages(as.character(i), dependencies = TRUE)
                        }
                        library(i, character.only = TRUE)
                        if(supress == FALSE){
                                print(paste("Loaded package: ",i))
                        }
                }
        }
}