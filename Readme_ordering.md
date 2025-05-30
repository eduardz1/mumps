# MUMPS ordering

To use Scotch (requires MUMPS >= 5.0 and Scotch built with libesmumps):

```sh
cmake -DMUMPS_scotch=yes
```

To use METIS:

```sh
cmake -DMUMPS_metis=yes
```

To use parMETIS (MUMPS_ option is ignored (overridden) by MUMPS_parmetis=yes):

```sh
cmake -DMUMPS_parmetis=yes
```

The path to METIS and Scotch can be specified via variables METIS_ROOT and Scotch_ROOT, respectively.

## Build METIS

Optionally, METIS can be built from source via CMake before MUMPS.
NOTE: the "-DMUMPS_intsize64" must be the same for METIS and MUMPS -- default is "off" for METIS and MUMPS.

```sh
cmake -Dprefix=~/mumps -P scripts/build_metis.cmake
```

Build MUMPS

```sh
cmake -Bbuild -DMETIS_ROOT=~/mumps -DMUMPS_metis=on

cmake --build build
```

## Build Scotch

Optionally, Scotch can be built from source via CMake before MUMPS.
NOTE: the "-DMUMPS_intsize64" must be the same for Scotch and MUMPS -- default is "off" for Scotch and MUMPS.

```sh
cmake -Dprefix=~/mumps -P scripts/build_scotch.cmake
```

Build MUMPS

```sh
cmake -Bbuild -DMETIS_ROOT=~/mumps -DScotch_ROOT=~/mumps -DMUMPS_scotch=on

cmake --build build
```

Build MUMPS example:

```sh
cmake -S example -B example/build
cmake --build example/build
```

---

If 64-bit integers are needed, use:

```sh
cmake -DMUMPS_intsize64=true
```
