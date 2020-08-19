---
title: How I organize project code
layout: post
date: 2020-08-19
categories: [Developer workshop]
tags: [workshop, decouple code, infrastructure, domain, bounded context, subdomain]
---

There are many ways how to organize project code. There are probably almost as many ways as there are people writing code and two may vary even in the same organization. When organizing your project code, it is good practice to separate the domain code from the infrastructure code. And it does not matter whether our application will work with Symfony, Laravel, Laminas or the framework-agnostic.

Usually, working with the code comes down to three areas: domain, infrastructure and supporting components.

## Domain

Information obtained from domain experts, from which we separate `Subdomains` and` Bounded Contexts` in the next stages of the analysis, at some point can be transformed into the first implementations of our application. When implementing only the domain code with a set of tests to verify whether our design makes sense, we do not have to worry about the infrastructure layer. However, once we start adding it, we don't want our domain to depend on a technical implementation, which may be dictated by the framework we used.

I keep the domain in a namespace derived from the name of the project. The next level of namespace is the name of the `Bounded Context`. This is where commands, aggregates, handlers, policies, etc. are held. This division makes it easier to introduce changes or extensions. If I get a request regarding e.g. the invoice context, I know to modify the code in the namespace `ProjectName\Invoice`.

With more subdomains, there will also be `SharedContext`, with all the elements of the application that will be used for communication between contexts. At the same time, every developer working on an application knows what context they are working on and seeing that they are modifying the code in `SharedContext` will keep in mind that it is a` public` code.

An application structure may look like this at the beginning.

```tree
+-- src/
|   +-- ProjectName/
    |   +-- ContextA/
        |   +-- Command/
        |   +-- Event/
        |   +-- Exception/
        |   +-- Handler/
        |   +-- Model/
        |   +-- Policy/
        |   +-- Repository/
    |   +-- ContextB/
    |   +-- ContextC/
    |   +-- SharedContext/
        |   +-- DTO/
        |   +-- Event/
        |   +-- Exception/
        |   +-- Query/
        |   +-- Result/
+-- tests/
|   +-- ProjectName/
    |   +-- ContextA/
    |   +-- ContextB/
    |   +-- ContextC/
    |   +-- SharedContext/
```

## Infrastructure

Whether our application will provide API via the HTTP protocol or will be available from the command line, requires the insrastructure related namespace.  

I use `Symfony` on a daily basis, so I keep the infrastructure code in the` App` namespace. As in the case of the domain code, the developer is fully aware of the area being modified. 

After adding infrastructure our application structure may look like this now.

```
+-- src/
|   +-- App/
    |   +-- Console/
    |   +-- Controller/
    |   +-- DataFixtures/
    |   +-- Form/
    |   +-- Migrations/
    |   +-- Twig/
    |   +-- Validator/
|    +-- ProjectName/
+-- tests/
|   +-- App/
|   +-- ProjectName/
```

## Supporting components

Sometimes it happens that while working on a project, certain components may be created that solve problems in some universal way or provide specific functionalities. We may want to use them in our next project or share them with another team in our organization or even with the world. I start the namespace of this code with the name of the organization. At the lower level, it is the name of the component itself. This way, it will be easier to extract it, add `composer.json` to it and publish it, for example on` packagist.org`.

```
+-- src/
|   +-- Acme/
    |   +-- CommonComponent/
    |   +-- ComponentA/
    |   +-- ComponentB/
|   +-- App/
|   +-- ProjectName/
+-- tests/
|   +-- Acme/
    |   +-- CommonComponent/
    |   +-- CommonA/
    |   +-- CommonB/
|   +-- App/
|   +-- ProjectName/

```

## Maintaining boundaries

No matter how the application code is divided, as long as all contexts and layers intertwine, separating the code in any way becomes just a hard-to-maintain art. Here `deptrac` comes with help. Its configuration allows us to define how  the division of individual contexts and the dependencies between them - shared contexts by definition will be ... shared.

```yaml
; depfile.yaml
paths:
    - ./src
layers:
    -   name: Application
        collectors:
            -   type: directory
                regex: src/App/*
    -   name: Acme\CommonComponent
        collectors:
            -   type: directory
                regex: src/Acme/CommonComponent/*
    -   name: Acme\ComponentA
        collectors:
            -   type: directory
                regex: src/Acme/ComponentA/*
    -   name: Acme\ComponentB
        collectors:
            -   type: directory
                regex: src/Acme/ComponentB/*
    -   name: Project\ContextA
        collectors:
            -   type: directory
                regex: src/Project/ContextA/*
    -   name: Project\ContextB
        collectors:
            -   type: directory
                regex: src/Project/ContextB/*
    -   name: Project\ContextC
        collectors:
            -   type: directory
                regex: src/Project/ContextC/*
    -   name: Project\SharedContext
        collectors:
            -   type: directory
                regex: src/Project/SharedContext/*
ruleset:
    Application:
        - Acme\CommonComponent
        - Acme\ComponentA
        - Acme\ComponentB
        - Project\ContextA
        - Project\ContextB
        - Project\ContextC
        - Project\SharedContext
    Acme: ~
    Project\ContextA:
        - Acme\CommonComponent
        - Project\SharedContext
    Project\ContextB:
        - Acme\CommonComponent
        - Project\SharedContext
    Project\ContextC:
        - Acme\CommonComponent
        - Project\SharedContext

```

We can install `deptrac` using `composer`

    $ composer require --dev sensiolabs-de/deptrac-shim

Tool itself can be run passing the configuration file

    $ ./vendor/bin/deptrac analyse depfile.yml

## Tests

As can be seen, the test code follows the same structure as the production code itself. Personally, I don't like the separation of test types at the directory structure level. In practice, most of the tests for the domain are `unit tests`, while for infrastructure, the vast majority are `integration` or `end-to-end` tests. If I have to separate them, I prefer to do so using `groups`.
