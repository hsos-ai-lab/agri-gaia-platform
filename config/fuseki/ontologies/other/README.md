<!--
SPDX-FileCopyrightText: 2024 University of Applied Sciences Osnabrück
SPDX-FileContributor: Andreas Schliebitz
SPDX-FileContributor: Henri Graf
SPDX-FileContributor: Jonas Tüpker
SPDX-FileContributor: Lukas Hesse
SPDX-FileContributor: Maik Fruhner
SPDX-FileContributor: Prof. Dr.-Ing. Heiko Tapken
SPDX-FileContributor: Tobias Wamhof

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Ontology Dependencies Apart From GAIA-X and W3C

Notes specific to certain ontologies:

## Creative Commons Namespace

At the namespace of https://creativecommons.org/ns#, you directly only get an HTML description of the namespace. There is however a link to an RDF schema at the bottom of the page: https://creativecommons.org/schema.rdf. We provide here a version converted to turtle. You can do this like so:

```
rapper -i rdfxml -o turtle schema.rdf > creativecommons.ttl
```

## DOAP Namespace

The DOAP vocabulary provides a RDF/XML file at its namespace URL http://usefulinc.com/ns/doap#. Convert as described for other vocabularies here into turtle:

```
rapper -i rdfxml -o turtle doap.rdf > doap.ttl
```

## Dublin Core Namespaces

The Dublin Core namespace http://purl.org/dc/terms/ redirects to https://www.dublincore.org/specifications/dublin-core/dcmi-terms/. Links to RDF schemas are here: https://www.dublincore.org/schemas/rdfs/. We need the ones for:

* Dublin Core Terms: https://www.dublincore.org/specifications/dublin-core/dcmi-terms/dublin_core_terms.ttl
* Dublin Core Abstract Model: https://www.dublincore.org/specifications/dublin-core/dcmi-terms/dublin_core_abstract_model.ttl
* Dublin Core Elements: https://www.dublincore.org/specifications/dublin-core/dcmi-terms/dublin_core_elements.ttl 

## The FOAF Namespace

The FOAF namespace points to http://xmlns.com/foaf/0.1/ providing HTML documentation there. An RDF file is available here: http://xmlns.com/foaf/0.1/index.rdf. Again, convert to turtle using:

```
rapper -i rdfxml -o turtle index.rdf > foaf.ttl
```

## GoodRelations Namespace

The GoodRelations namespace http://purl.org/goodrelations/v1# redirects to http://www.heppnetz.de/ontologies/goodrelations/v1. Use the http://purl.org/goodrelations/v1.owl link at the top of the page to grab a file containing the ontology. Although this uses .owl as file extension, you can use the usual

```
rapper -i rdfxml -o turtle v1.owl > goodrelations.ttl
```

to convert into turtle.

## VANN Namespace

The VANN namespace http://purl.org/vocab/vann/ redirects to an HTML description at https://vocab.org/vann/. The link to the RDF is provided at the top of the page: https://vocab.org/vann/vann-vocab-20100607.rdf. Again, you have to convert to turtle:

```
rapper -i rdfxml -o turtle vann-vocab-20100607.rdf > vann.ttl
```

## VOAF Namespace

The VOAF namespace http://purl.org/vocommons/voaf# redirects to http://lov.okfn.org/vocommons/voaf, which is a dead link. For now, there is thus no turtle file. It will be provided later if the downtime is only temporary or an alternative has been found.

## VoID Namespace

The VoID Namespace http://rdfs.org/ns/void# redirects to http://vocab.deri.ie/void. The link to the turtle file at the top of the page http://vocab.deri.ie/data_file.ttl currently doesn't work and gives a 404. You can get the void vocabulary turtle file from http://vocab.deri.ie/void.ttl

