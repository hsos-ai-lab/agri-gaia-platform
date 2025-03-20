<!--
SPDX-FileCopyrightText: 2024 Osnabrück University of Applied Sciences
SPDX-FileContributor: Andreas Schliebitz
SPDX-FileContributor: Henri Graf
SPDX-FileContributor: Jonas Tüpker
SPDX-FileContributor: Lukas Hesse
SPDX-FileContributor: Maik Fruhner
SPDX-FileContributor: Prof. Dr.-Ing. Heiko Tapken
SPDX-FileContributor: Tobias Wamhof

SPDX-License-Identifier: MIT
-->

# GAIA-X Ontology Material

**In using the GAIA-X ontologies, we're following a moving target. To anybody within the AgriGAIA project: please update this page and accompanying files whenever you become aware of new material.**

## Reference Source (Currently)

There is now a [gitlab repository available](https://gitlab.com/gaia-x/technical-committee/service-characteristics/) that provides tools and material necessary to build GAIA-X self descriptions in various formats including turtle files and SHACL shapes. Obviously, the code provided there is still under heavy development and there are a number of pitfalls like issues in generated ontology files or undocumented features of tools.

The turtle files in this directory are generated from the original sources. If you want to reproduce this - here's how to move along:

Get the gitlab repository and change directory to `toolchain/ontology_generation`:

```
git clone https://gitlab.com/gaia-x/technical-committee/service-characteristics.git
cd service-characteristics/toolchain/ontology_generation
```

There is a runnable python script called `cli.py` in this directory. Apart from a standard python3 install it requires the yaml, pytz and colorama modules. So make sure to install these beforehand using pip or the package manager of choice.

You have to provide a path configuration contained in a csv file to this script using the `--srcFile` option. A sample that works with the sources provided is available in the repository at the path `toolchain/pathFile.csv`. Note however, that the python script interprets paths relative to its execution directory and not relative to the `pathFile.csv`-location. So it's best to simply copy the file to the directory where cli.py resides and edit the paths contained accordingly (essentially adding one more `../` up front of each path given).

Additionally, you have to provide a target directory where generated files will be placed, that has to exist before you run the tool. So:

```
mkdir ../../generated
```

You can then run the ontology generator like so:

```
python.exe .\cli.py ontology-generation --srcFile pathFile.csv --dstPath ../../generated/ -e gax-core -e gax-trust-framework -e trusted-cloud
```

The strings given with the `-e` options are "ecosystems". There is little documentation on that concept and on what role they play, but their names seem to coincide with the names of directories in `single_point_of_truth/yaml` and given these three ecosystems it looks like you get roughly what was formerly contained in Core, Resource, Participant and Service Offering (see below).

Currently, the tool generates broken rdfs:subClassOf-statements of the form:

```
:X rdfs:subClassOf gax-trust-framework:gax-core:Resource ;
```

so, it duplicates namespace prefixes in a number of variations. As long as there is no patch/fix available for the python ontology generation script, this can be fixed by running the `fix-subClassOf-statements.sed` sed-Script in the tools directory like so:

```
sed -f ../tools/fix-subClassOf-statements.sed gax-trust-framework_generated.ttl > gax-trust-framework_generated-fixed.ttl && mv gax-trust-framework_generated-fixed.ttl gax-trust-framework_generated.ttl
```

## Other Material

You can access the GAIA-X ontology documentation by inserting the respective namespace URIs (without fragment identifier) into the address line of your browser:

- Core: https://www.w3id.org/gaia-x/core
- Resource: https://www.w3id.org/gaia-x/resource
- Participant: https://www.w3id.org/gaia-x/participant
- Service Offering: https://www.w3id.org/gaia-x/service

At this point in time, these URIs will redirect to:

- Core: https://gaia-x.gitlab.io/technical-committee/service-characteristics/widoco/core/core.html
- Resource: https://gaia-x.gitlab.io/technical-committee/service-characteristics/widoco/resource/resource.html
- Participant: https://gaia-x.gitlab.io/technical-committee/service-characteristics/widoco/participant/participant.html
- Service Offering: https://gaia-x.gitlab.io/technical-committee/service-characteristics/widoco/service/service.html

For each of these, a set of serializations is available, including a Turtle file. See the "Download serialization:" section close to the top of each of the pages.

There is additional information available at https://gaia-x.gitlab.io/technical-committee/service-characteristics. That page is currently mostly an empty stub, but there are some zip-files available for the ontologies and SHACL shapes in the "Downloads" section of that page, for now here: https://gaia-x.gitlab.io/technical-committee/service-characteristics/v22.06/downloads/

Both of these sources however do not reflect the most recent state as available in the gitlab repository.
