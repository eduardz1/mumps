# --- compiler options

add_compile_definitions("$<$<COMPILE_LANGUAGE:C>:Add_>")
# "Add_" works for all modern compilers we tried.

add_compile_definitions("$<$<BOOL:${MUMPS_intsize64}>:INTSIZE64;PORD_INTSIZE64>")

if(MUMPS_openmp)
  add_compile_options(
  "$<$<COMPILE_LANG_AND_ID:C,IntelLLVM>:$<IF:$<BOOL:${WIN32}>,/Qopenmp,-fiopenmp>>"
  "$<$<COMPILE_LANG_AND_ID:C,MSVC>:/openmp>"
  "$<$<COMPILE_LANG_AND_ID:Fortran,IntelLLVM>:$<IF:$<BOOL:${WIN32}>,/Qopenmp,-fiopenmp>>"
  )
endif()

add_compile_options("$<$<COMPILE_LANG_AND_ID:C,AppleClang,Clang,GNU,IntelLLVM>:-Werror-implicit-function-declaration;-fno-strict-aliasing>")

add_compile_options(
"$<$<COMPILE_LANG_AND_ID:Fortran,IntelLLVM>:$<IF:$<BOOL:${WIN32}>,/warn:declarations;/heap-arrays,-implicitnone>>"
"$<$<COMPILE_LANG_AND_ID:Fortran,GNU>:-fimplicit-none>"
"$<$<COMPILE_LANG_AND_ID:Fortran,GNU>:-fno-strict-aliasing>"
"$<$<AND:$<COMPILE_LANG_AND_ID:Fortran,GNU>,$<VERSION_GREATER_EQUAL:${CMAKE_Fortran_COMPILER_VERSION},10>>:-fallow-argument-mismatch;-fallow-invalid-boz>"
)
# IntelLLVM does not have -fno-strict-aliasing for Fortran

# the Intel oneAPI fpscomp flag needs to be applied EVERYWHERE incl. submodule projects
# or runtime errors / weird behavior with unresolved procedures that actually exist.
# -standard-semantics is no good because it breaks linkage within oneAPI itself e.g. oneMPI library!
add_compile_options("$<$<COMPILE_LANG_AND_ID:Fortran,IntelLLVM>:$<IF:$<BOOL:${WIN32}>,/fpscomp:logicals,-fpscomp;logicals>>")

if(MUMPS_intsize64)
  add_compile_options(
    "$<$<COMPILE_LANG_AND_ID:Fortran,GNU>:-fdefault-integer-8>"
  )
  # ALL libraries must be compiled with -fdefault-integer-8, including MPI,
  # or runtime fails
  # See MUMPS 5.7.0 User manual about error -69

  if(CMAKE_Fortran_COMPILER_ID MATCHES "^Intel")
    # https://www.intel.com/content/www/us/en/docs/onemkl/developer-guide-linux/2025-2/using-the-ilp64-interface-vs-lp64-interface.html
    # https://www.intel.com/content/www/us/en/docs/onemkl/developer-guide-windows/2025-2/using-the-ilp64-interface-vs-lp64-interface.html
    # https://www.intel.com/content/www/us/en/docs/mpi-library/developer-guide-linux/2021-16/ilp64-support.html

    if(MUMPS_openmp)
      set(_mkl_ilp64 parallel)
    else()
      set(_mkl_ilp64 sequential)
    endif()

    add_compile_options("$<$<COMPILE_LANGUAGE:Fortran>:-i8>")
    if(WIN32)
      add_compile_options("$<$<COMPILE_LANGUAGE:Fortran>:/Qmkl-ilp64=${_mkl_ilp64}>")
    endif()

    add_compile_definitions(
      "$<$<COMPILE_LANGUAGE:C>:MKL_ILP64>"
      "$<$<COMPILE_LANGUAGE:Fortran>:WORKAROUNDINTELILP64MPI2INTEGER>"
    )

    add_link_options("$<$<COMPILE_LANGUAGE:Fortran>:-qmkl-ilp64=${_mkl_ilp64}>")
  endif()
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

# Necessary for shared library with Visual Studio / Windows oneAPI
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS true)
