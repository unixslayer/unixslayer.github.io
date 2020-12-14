---
title: How I started the mutation tests
layout: post
date: 2020-09-10
categories: [tech]
tags: [workshop, php, testing, mutants]
---

Testy są ważne. Ważniejsze są tylko dobre testy. 

PHPSpec is a tool will give you awesome TDD and test-first experience. It can be installed `composer`. In addition you may want to install extension that generates Code Coverage reports for PHPSpec tests. 

```
$ composer require --dev phpspec/phpspec friends-of-phpspec/phpspec-code-coverage
```

When run, PHPSpec will look for `phpspec.yml`, `*.phpspec.yml`, or `phpspec.yml.dist` file in the root of your project which will contain configuration. Basic configuration I'm using looks like bellow:

```yaml
# phpspec.yml.dist
formatter.name: pretty
bootstrap: spec/bootstrap.php
extensions:
    FriendsOfPhpSpec\PhpSpec\CodeCoverage\CodeCoverageExtension:
        format:
            - text
            - html
        output:
            html: spec/_output/html
```

`formatter.name: pretty` - makes PHPSpec to display pretty log about running tests in your console. Check other formatters in [official documentation](http://www.phpspec.net/en/stable/cookbook/configuration.html#formatter).

`boostrap: /path/to/bootstrap.php` - makes PHPSpec to run custom bootstrap before running tests.

`extensions: ~` - adds aditional extensions to PHPSpec runtime.

`FriendsOfPhpSpec\PhpSpec\CodeCoverage\CodeCoverageExtension` uses `phpunit` coverage component. Given configuration will generate two coverage outputs: `text` will display phpunit-like sumary in console; `html`will generate HTML report into given directory.

Now create your first specification. For the purpose of this article lets asume, that we have to write calculator with basic arythmetic operations.

```
$ vendor/bin/phpspec desc App/Calculator/Operations/Addition
```

PHPSpec will use Composer autoloading configuration to guess naming scheme and assume where to put specification class. Above example will create `spec/App/Calculator/Operations/AdditionSpec.php` file. If you want PHPSpec to generate tests differently, you have to use [suites](http://www.phpspec.net/en/stable/cookbook/configuration.html#psr-4) configuration. I'll leave it as default, so let's look at the specification itself.

```php
<?php

namespace spec\App\Calculator\Operations;

use App\Calculator\Operations\Addition;
use PhpSpec\ObjectBehavior;

class AdditionSpec extends ObjectBehavior
{
    function it_is_initializable()
    {
        $this->shouldHaveType(Addition::class);
    }
}
```

Each time you generate specification, it will look like this one. PHPSpec will interpret every method that starts with `it_` as a test case (just like `test` methods in PHPUnit). As it might be a little confusing at the begining, `$this` refers to object this specification describes. You can now call your future methods in here and do assertions, which can be done by using [matchers](http://www.phpspec.net/en/stable/cookbook/matchers.html). You will see in a moment how it works. 



1. instalacja infectionphp

Mutation tests will teach you to think about your tests differently. Any mutation testing tool will show you how good are your tests but not like typical static analysis tool. They will first run your tests, check coverege, generate mutants and run your tests again agains each mutant that was created. If any mutant survive, you have a problem. So you may say that mutation testing is a game about killing mutants ;)

Mutant is a simple change in your codebase, like comparision from `>=` to `>`, or `true` to `false`, or removing method calls, or array items. This change is made on runtime in memory so it doesn't stay in your original codebase. 

1. konfiguracja infectionphp
1. użycie infection php