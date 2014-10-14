#################################################################################
#                                                                               #
# Copyright (C) 2014, Joanes Espanol                                            #
# All rights reserved.  Confidential and Proprietary.                           #
#                                                                               #
# This information is provided under the Master Supply Agreement between the    #
# parties and is considered a portion of the Licensed Software and Confidential #
# Information as defined therein.                                               #
# This information is provided "as is" without warranty of any kind either      #
# expressed or implied, including, but not limited to, the implied warranties   #
# of merchantability and/or fitness for a particular purpose.                   #
#                                                                               #
#################################################################################


# ==============================================================================
# CONFIGURATION
# ==============================================================================

# ----------  Constants & variables  ----------

dir.script <- dirname(sys.frame(1)$ofile)
dir.script <- dirname(parent.frame(2)$ofile)  # Other way to get the current directory

#args        <- commandArgs(trailingOnly = F)
#path.script <- dirname(sub("--file=", "", args[grep("--file", args)]))


# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

# ---------------------------------------------------------------------------- #
# Utility function to emulate similar printing functionlity as found in other  #
# languages such as Java or C++.                                               #
# ---------------------------------------------------------------------------- #

printf <- function(...) cat(sprintf(...))


# ---------------------------------------------------------------------------- #
# Installs a package, if is has not been installed already.                    #
#                                                                              #
# INPUT:                                                                       #
#   - the package name, with quotes                                            #
#                                                                              #
# OUTPUT:                                                                      #
#   - no output                                                                #
# ---------------------------------------------------------------------------- #

install_package <- function(mypkg) {
    if ( ! library(mypkg, character.only=TRUE, logical.return=TRUE, quietly=FALSE) ) {
        install.packages(mypkg)
    }
}


# ---------------------------------------------------------------------------- #
# Creates a directory if it does not already exist.                            #
#                                                                              #
# INPUT:                                                                       #
#   - the path to the directory                                                #
#                                                                              #
# OUTPUT:                                                                      #
#   - the directory path, identical to the input so calls can be chained       #
# ---------------------------------------------------------------------------- #

create_dir <- function(dir) {
    if ( ! file.exists(dir) ) {
        dir.create(path = dir, recursive = TRUE)
    }

    return(dir)
}


# ---------------------------------------------------------------------------- #
# Downloads a file if it does not already exist.                               #
#                                                                              #
# If the path points to a file, the content is downloaded into it.             #
#                                                                              #
# If the path points to a directory, a file is created inside it, with a name  #
# matching the file name in the url, and the content is downloaded into it.    #
#                                                                              #
# INPUT:                                                                       #
#   - the url of the file                                                      #
#   - the path (file or folder) where to download the file                     #
#                                                                              #
# OUTPUT:                                                                      #
#   - the path where the file was downloaded to                                #
# ---------------------------------------------------------------------------- #

download_file <- function(url, file) {
    if ( file.info(file)$isdir ) {
        file <- file.path(file, basename(url))
    }

    if ( ! file.exists(file) ) {
        download.file(
            url      = url,
            destfile = file,
            method   = 'curl'
        )
    }

    printf(
        "Downloaded file: name='%s', size=%d bytes\n",
        basename(file),
        file.info(file)$size
    )

    return(file)
}


# ---------------------------------------------------------------------------- #
# Unzips a file if it has not already been extracted.                          #
#                                                                              #
# If the path points to a file, the content is extracted into it.              #
#                                                                              #
# If the path points to a directory, a file is created inside it, with a name  #
# matching the name of the file to extract, and the content is extracted into  #
# it.                                                                          #
#                                                                              #
# INPUT:                                                                       #
#   - the path to the zip file                                                 #
#   - the name of the file to extract from the zip file                        #
#   - the path (file or folder) where to extract the file                      #
#                                                                              #
# OUTPUT:                                                                      #
#   - the path where the file was extracted to                                 #
# ---------------------------------------------------------------------------- #

unzip_file <- function(zip, name, file) {
    if ( file.info(file)$isdir ) {
        file <- file.path(file, name)
    }

    if ( ! file.exists(file) ) {
        unzip(
            zipfile = zip,
            files   = c(name),
            exdir   = dirname(file)
        )
    }

    printf(
        "Extracted file: name='%s', size=%d bytes\n",
        basename(file),
        file.info(file)$size
    )

    return(file)
}


# ---------------------------------------------------------------------------- #
# Unzips a file if it has not already been extracted.                          #
#                                                                              #
# If the path points to a file, the content is extracted into it.              #
#                                                                              #
# If the path points to a directory, a file is created inside it, with a name  #
# matching the name of the file to extract, and the content is extracted into  #
# it.                                                                          #
#                                                                              #
# INPUT:                                                                       #
#   - the path to the zip file                                                 #
#   - the name of the file to extract from the zip file                        #
#   - the path (file or folder) where to extract the file                      #
#                                                                              #
# OUTPUT:                                                                      #
#   - the path where the file was extracted to                                 #
# ---------------------------------------------------------------------------- #

unzip_all <- function(zip, dir) {
    unzip(
        zipfile   = zip,
        files     = NULL,
        overwrite = FALSE,
        exdir     = dir
    )
}


################################################################################
