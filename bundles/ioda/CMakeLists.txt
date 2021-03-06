#
# IODA bundle
#

cmake_minimum_required( VERSION 3.12 FATAL_ERROR )

project( ioda-bundle VERSION 1.0.0 LANGUAGES C CXX Fortran )

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

include( ecbuild_bundle )

set( ENABLE_MPI ON CACHE BOOL "Compile with MPI" )

ecbuild_bundle_initialize()

ecbuild_bundle( PROJECT jedicmake GIT "https://github.com/JCSDA/jedi-cmake.git" BRANCH develop UPDATE )
include( jedicmake/cmake/Functions/git_functions.cmake )

# ECMWF libs
# ----------
option("BUNDLE_SKIP_ECKIT" "Don't build eckit" "ON" ) # Skip eckit build unless user passes -DBUNDLE_SKIP_ECKIT=OFF
option("BUNDLE_SKIP_FCKIT" "Don't build fckit" "ON") # Skip fckit unless user passes -DBUNDLE_SKIP_FCKIT=OFF
option("BUNDLE_SKIP_ATLAS" "Don't build atlas" "ON") # Skip atlas unless user passes -DBUNDLE_SKIP_ATLAS=OFF
option("BUNDLE_SKIP_ODC" "Don't build odc" "ON") # Skip odc unless user passes -DBUNDLE_SKIP_ODC=OFF

option( ENABLE_LORENZ95_MODEL "Build LORENZ95 toy model" OFF )
option( ENABLE_QG_MODEL "Build QG toy model" OFF )

ecbuild_bundle( PROJECT eckit GIT "https://github.com/ecmwf/eckit.git" TAG 1.16.0 )
ecbuild_bundle( PROJECT fckit GIT "https://github.com/ecmwf/fckit.git" TAG 0.9.2 )
ecbuild_bundle( PROJECT atlas GIT "https://github.com/ecmwf/atlas.git" TAG 0.24.1 )
ecbuild_bundle( PROJECT odc GIT "https://github.com/ecmwf/odc.git" TAG 2021.03.0 )

# Core JEDI repositories
ecbuild_bundle( PROJECT oops GIT "https://github.com/JCSDA/oops.git" BRANCH develop UPDATE )
ecbuild_bundle( PROJECT ioda GIT "https://github.com/JCSDA/ioda.git" BRANCH develop UPDATE )

# Build IODA converters
option(BUILD_IODA_CONVERTERS "Build IODA Converters" ON)
if(BUILD_IODA_CONVERTERS)
  ecbuild_bundle( PROJECT iodaconv GIT "https://github.com/JCSDA-internal/ioda-converters.git" BRANCH develop UPDATE )
endif()

# Build Doxygen documentation
option(BUILD_IODA_BUNDLE_DOC "Build documentation" OFF)
if(BUILD_IODA_BUNDLE_DOC)
   add_subdirectory( Documentation )
endif(BUILD_IODA_BUNDLE_DOC)

ecbuild_bundle_finalize()

include(CTest)
