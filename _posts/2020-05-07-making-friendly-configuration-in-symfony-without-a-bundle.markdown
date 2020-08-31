---
title: Making friendly configuration in Symfony without a Bundle
layout: post
date: 2020-05-07
categories: [tech]
tags: [no bundle, configuration, friendly configuration, symfony, symfony 5, framework, php, extensions]
---

Every time we want to have custom and friendly configuration in Symfony, the best way to do that was to create a Bundle which registered its own extension and ... tadaa. Although Bundles at some point become a way to organize application code which makes sense no because Symfony is just a framework. After all it is business and/or infrastructure that should be reason how code gets organized. But bundles still exists and will remain as long people will keep creating reusable components and since Symfony 5, bundles are discouraged to be used in other manner. 

> In Symfony versions prior to 4.0, it was recommended to organize your own application code using bundles. This is no longer recommended and bundles should only be used to share code and features between multiple applications.

So bundles are not recommended to be used in our application code, but Extensions still exists, right? Lets say, we want to have our own, friendly configuration.

```yaml
#config/packages/event_store.yaml
event_store:
    stores:
        ...
```

Having only this much, Symfony will tell us that `'There is no extension able to load the configuration for "event_store"'`. So if there is no extension to load our configuration, lets make one. 

But first we have to implement `\Symfony\Component\Config\Definition\ConfigurationInterface` that will translate our yaml in a way that Symfony can understand it.

```php
<?php

declare(strict_types=1);

namespace Unixslayer\EventSourcing\Application\DependencyInjection;

use Symfony\Component\Config\Definition\Builder\TreeBuilder;
use Symfony\Component\Config\Definition\ConfigurationInterface;

final class EventStoreConfiguration implements ConfigurationInterface
{
    public function getConfigTreeBuilder(): TreeBuilder
    {
        $treeBuilder = new TreeBuilder('event_store');
        $rootNode = $treeBuilder->getRootNode();

        $rootNode->children()
            ->arrayNode('stores')
            // ... and so on
        ;

        return $treeBuilder;
    }
}
```

Now, we need actual `Extension` which will process our configuration, so let's make one.

```php
<?php

declare(strict_types=1);

namespace Unixslayer\EventSourcing\Application\DependencyInjection;

use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\DependencyInjection\Extension\Extension;

final class EventStoreExtension extends Extension
{
    public function load(array $configs, ContainerBuilder $container)
    {
        $configuration = new EventStoreConfiguration();
        $processedConfig = $this->processConfiguration($configuration, $configs);

        // ... 
    }
}
```

We are almost done. All that has left is to register our `Extension`. We will do that in `Kernel` class.

```php
<?php

declare(strict_types=1);

namespace App;

use Unixslayer\EventSourcing\Application\DependencyInjection\EventStoreExtension;
use Symfony\Bundle\FrameworkBundle\Kernel\MicroKernelTrait;
use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\HttpKernel\Kernel as BaseKernel;

class Kernel extends BaseKernel
{
    use MicroKernelTrait;

    // ...

    protected function build(ContainerBuilder $container): void
    {
        $container->registerExtension(new EventStoreExtension());
    }

    // ...
}

```

[Defining and Processing Configuration Values](https://symfony.com/doc/current/components/config/definition.html)