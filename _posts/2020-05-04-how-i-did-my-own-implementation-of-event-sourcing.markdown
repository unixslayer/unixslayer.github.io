---
title: How I did my own implementation of Event Sourcing
layout: post
date: 2020-05-04
categories: [Developer workshop]
tags: [event sourcing, library, framework, php, prooph, broadway, diy]
---

After playing around with [prooph](https://github.com/prooph/event-sourcing) and [broadway](https://github.com/broadway/broadway), I finally decided to write something on my own. Took me little more than an hour and two classes later I have what I need for now to work on domain. Seriously. Writing this article took me more time than actual implementation.

## Brace yourself, events are comming.

> Capture all changes to an application state as a sequence of events.
>
> ___Martin Fowler___

Event Sourcing was introduced to me by Mariusz Gil during a training he conducted in early 2018 on which he shown it on Prooph components. At first glance, it didn't clicked. Not because I wasn't convinced but because I didn't have enought understanding in this topic and all of my projects in that time was around Magento. Fortunately in 2019 I've changed companies and an opportunity to use ES in new project came. I've started to learn more about ES. There are a lot of articles and conference recordings on Youtube about Event Sourcing. One of the first articles I read was by [Fowler's](https://martinfowler.com/eaaDev/EventSourcing.html) (Published in December 2005. Where was I all this time!?!?). After a while it gets noticable that every next article I've read was similar or the same as those I've already read. 

I can understand theory, but I'm a visual learner and when it comes to use it in practice it's a bit tricky for me for first time, so I find it better to learn be examples. In that new project, I've decided to use Prooph components for ES, and It was great. I've been learning about DDD for few years by then, and suddenly...boom! Everything makes more sense now :) Meantime I played a bit with Broadway to get another perspective. Doing this gave me better understanding of ES. 

Project was shut down and just before that I found out that with the end of 2019 Prooph gave up with support for ES component. This was a signal for me to write something on my own. Which turned out to be quite simple.

## Domain

Event Sourcing can be adapted in any domain, however, on a specific example it will be easier to show how to achieve the goal. As an example take an online store, where customer can add to cart any product they want to buy. Notice, that this is not domain-centric article. Example will most likely have no sense from business perspective but it will be good enough to prove a concept.

Lets start from implementing simple product class. 

```php
<?php

declare(strict_types=1);

namespace Unixslayer\Domain;

use Money\Money;
use Ramsey\Uuid\UuidInterface;

final class Product
{
    private UuidInterface $productId;
    private Money $price;

    public function __construct(UuidInterface $productId, Money $price)
    {
        $this->productId = $productId;
        $this->price = $price;
    }

    public function productId(): UuidInterface
    {
        return $this->productId;
    }

    public function price(): Money
    {
        return $this->price;
    }
}
```

Having a simple representation of product, which can be described with ID and price, now we need cart so customer can have a place to put that product in.

```php
<?php

declare(strict_types=1);

namespace Unixslayer\Domain;

use Ramsey\Uuid\UuidInterface;

final class Cart
{
    public function __construct(UuidInterface $consumerId)
    {
        // ... some logic
    }
}
```

Here I assumed, that cart will have a relation to authorized `Consumer` using its [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier). Normally when creating new instance of `Cart`, `$consumerId` would be assigned to private attribute. However, Event Sourcing assumes that instead of changing the state, you need to register events from which the state will be restored.

## Event

Events are the essence of Event Sourcing (its in the name, duh!). Having information about what happened in application gives us possibility to restore its state at any point in time. As long we have events.

Events must be immutable, because once somthing happen, it stays in the past so you cannot change it. They should be simple, without any logic, holding only specific data corelated with event itself. 

```php
<?php

declare(strict_types=1);

namespace Unixslayer\Domain;

use Ramsey\Uuid\UuidInterface;

final class CartWasCreated
{
    private UuidInterface $cartId;
    private UuidInterface $consumerId;

    public function __construct(UuidInterface $cartId, UuidInterface $consumerId)
    {
        $this->cartId = $cartId;
        $this->consumerId = $consumerId;
    }

    public function cartId(): UuidInterface
    {
        return $this->cartId;
    }

    public function consumerId(): UuidInterface
    {
        return $this->consumerId;
    }
}
```

When an `Event` occurs, it represents a change in our application and is usually the result of some command. `CartWasCreated` event can occur when a user logs on to an application.

## AggregateRoot

`Aggregate` is a pattern in DDD which should be treated as a single unit of businness rules. `AggregateRoot` will provide a high-level domain API describing the functionalities of the context that way application won't have direct acces to any of its components (like entities or value objects) in other way that through `AggregateRoot` class.

In our example, `Cart` will be an `AggregateRoot`. And every time public method gets called, `Event` should be recorded.

```php
<?php

declare(strict_types=1);

namespace Unixslayer\Domain;

use Ramsey\Uuid\UuidInterface;

final class Cart
{
    private UuidInterface $cartId;
    private UuidInterface $consumerId;
    private array $events = [];

    public function __construct(UuidInterface $consumerId)
    {
        $this->recordThat(new CartWasCreated(Uuid::uuid1(), $consumerId));
    }

    private function recordThat($event): void
    {
        $this->events[] = $event;

        $this->apply($event);
    }

    private function apply($event): void
    {
        if ($event instanceof CartWasCreated) {
            $this->cartCreated($event);
        }
    }

    private function cartCreated(CartWasCreated $event): void
    {
        $this->cartId = $event->cartId();
        $this->consumerId = $event->consumerId()
    }
}
```

Now lets go step by step and see what happend in code.

1. When new instance of `Cart` is created, it records an event.
1. `recordThat` method is private, bacause only `Cart` can record events from its context. 
1. When occured, events must be saved. Here, private attribute will be just enought.
1. Recorded events must be `applied`, so actual change may be done.
1. `apply` method is also private from same reasons as `recordThat` method.

## Changing the state

Since `Product` class can be added to `Cart`, and we are recording this as something that happens, we need a proper event.

```php
<?php

declare(strict_types=1);

namespace Unixslayer\Domain;

use Ramsey\Uuid\UuidInterface;

final class ProductWasAddedToCart
{
    private UuidInterface $cartId;
    private UuidInterface $consumerId;

    public function __construct(UuidInterface $cartId, Product $product)
    {
        $this->cartId = $cartId;
        $this->product = $product;
    }

    public function cartId(): UuidInterface
    {
        return $this->cartId;
    }

    public function product(): Product
    {
        return $this->product;
    }
}
```

For now, when product gets added to cart, all we have to know is information which cart, and which product. As for the `Cart`, it should have proper method that allow application to do that. We must remember to only record the event that occurred.

```php
<?php

declare(strict_types=1);

namespace Unixslayer\Domain;

use Ramsey\Uuid\UuidInterface;

final class Cart
{
    // ...
    
    /**
     * @var Money[]
     */
    private array $productsBalance = [];

    /**
     * @var int[]
     */
    private array $productsCount = [];

    public function addProduct(Product $product): void
    {
        $this->recordThat(new ProductWasAddedToCart($this->cartId, $product));
    }
    
    // ... skipping obvious and unchanged code

    private function apply($event): void
    {
        // ...

        if ($event instanceof ProductWasAddedToCart) {
            $this->productAddedToCart($event);
        }
    }

    private function productAddedToCart(ProductWasAddedToCart $event): void
    {
        $productId = $event->product()->productId();
        if (array_key_exists((string)$productId, $this->products)) {
            ++$this->productsCount[(string)$productId];
            $this->productsBalance[(string)$productId] = $this->productsBalance[(string)$productId]->add($event->product()->price());
        } else {
            $this->productsCount[(string)$productId] = 1;
            $this->productsBalance[(string)$productId] = $event->product()->price();
        }
    }
}
```

When the aggregate public method is called event must be recorded instead of changing state directly. The change of state can take place only by applying the registered event, which will now be explained why.

## Recreate the state

Lets see how this aggregate can be used.

```php
<?php

declare(strict_types=1);

use Unixslayer\Domain;

// ... assuming that $consumerId and products are valid variables

$cart = new Cart($consumerId);
$cart->addProduct($product1);
$cart->addProduct($product2);
$cart->addProduct($product1); // adding the same product twice, just for fun
```

First we have to create `Cart` instance so later, consumer can add product into it. From user point of view this looks legit, right? 

From the aggregate perspective, this will be just a serie of events that happened in application.

```php
$events = [
    new CartWasCreated($cartId, $consumerId),
    new ProductWasAddedToCart($cartId, $product1),
    new ProductWasAddedToCart($cartId, $product2),
    new ProductWasAddedToCart($cartId, $product1),
];
```

As you can see, each event must have the aggregate identifier in which it was recorded. 

And here comes the beauty of Event Sourcing. Having those events stored somewhere, we can recreate that state step by step just by applying them in our aggregate. Although I'm talking about applying only, since those events ware already recorded. `Cart` can do some additional stuff before recording an event, e.g. if the business rule says that the basket value cannot be higher than the one defined, `Cart` should check that whenever product is added. Now imagine, that we are recreating state with events from year ago and value limit has changed. This type of change should apply today, but we should still be able to recreate the state of the basket before it was introduced, so we need new method that allows us to do that without additional side effects.

```php
<?php

declare(strict_types=1);

namespace Unixslayer\Domain;

use Ramsey\Uuid\UuidInterface;

final class Cart
{
    // ...
    
    public static function fromHistory(array $events): self
    {
        $instance = new self();
        foreach ($events as $event) {
            $instance->apply($event);
        }

        return $instance;
    }
}
```

And this is it when it comes to Event Sourcing basics. Of course there is much more to come like Event Store (where, you guessed it, events will be stored), Snapshooting, CQRS (which works great with ES), but you don't need them to dive in Event Sourcing. 

## Put it all together

Because application will definitely have more than one event and more than one aggregate, let's separate abstraction we can extend from.

```php
<?php

declare(strict_types=1);

namespace Unixslayer\EventSourcing;

use Ramsey\Uuid\Uuid;
use Ramsey\Uuid\UuidInterface;

abstract class Event
{
    private array $payload = [];
    private array $metadata = [
        '_aggregateId' => null,
        '_version' => 1,
    ];

    public function aggregateId(): UuidInterface
    {
        return $this->metadata['_aggregateId'];
    }

    public function payload(): array
    {
        return $this->payload;
    }

    public function version(): int
    {
        return $this->metadata['_version'];
    }

    public function withVersion(int $version): AggregateEvent
    {
        $instance = clone $this;
        $instance->metadata['_version'] = $version;

        return $instance;
    }

    protected function __construct(UuidInterface $aggregateId, array $payload = [])
    {
        $this->metadata['_aggregateId'] = $aggregateId;
        $this->payload = $payload;
    }
}
```

Lets see what our event class is made of:

1. `$payload` is just a container for data. Abstraction doesn't know and don't have to know what data will it contain.
1. This is an aggregate event, so relation to aggregate must be held using `$aggregateId`.
1. Every thime event occur, it raises the version of an aggregate and to keep the right order of events, those should be corelated with proper aggregate version.
1. Non-public constructor force to use named constructors.

I also assumed that later in the future, when I'll start to implement Event Store into application, I'll have to serialize events in some way. `_aggregateId` and `_version` could be held in private attributes. I just like it that way.

Now our events will look like this:


```php
<?php

declare(strict_types=1);

namespace Unixslayer\Domain;

use Ramsey\Uuid\UuidInterface;
use Unixslayer\EventSourcing\Event;

final class ProductWasAddedToCart extends Event
{
    public static function occur(UuidInterface $cartId, Product $product): ProductWasAddedToCart
    {
        $payload = [
            'product' => $product,
        ];

        return new static($cartId, $payload);
    }

    public function product(): Product
    {
        return $this->payload['product'];
    }
}
```
Named constructor validates data associated with event and additionally gives us more readable usage:

```php
// ... somewhere in aggregate
$this->recordThat(ProductWasAddedToCart::occur(...));
// ...
```

As for the aggregate, we need to separate everything that cannot be considered as business logic:

```php
<?php

declare(strict_types=1);

namespace Unixslayer\EventSourcing;

use Ramsey\Uuid\Uuid;
use Ramsey\Uuid\UuidInterface;

abstract class AggregateRoot
{
    protected UuidInterface $id;
    private int $version = 0;
    private array $recordedEvents = [];

    public function version(): int
    {
        return $this->version;
    }

    public static function fromHistory(iterable $eventsHistory): self
    {
        $instance = new static();
        foreach ($eventsHistory as $event) {
            ++$instance->version;
            $instance->apply($event);
        }

        return $instance;
    }

    final public function aggregateId(): UuidInterface
    {
        return $this->id;
    }

    protected function recordThat(Event $event): void
    {
        ++$this->version;
        $this->recordedEvents[] = $event->withVersion($this->version);
        $this->apply($event);
    }

    abstract protected function apply(Event $event): void;
}
```

Aggregate can now contain only domain logic, so change it that way:

```php
<?php

declare(strict_types=1);

namespace Unixslayer\Domain;

use Ramsey\Uuid\UuidInterface;
use Unixslayer\EventSourcing\AggregateRoot;

final class Cart extends AggregateRoot
{
    private UuidInterface $consumerId;
    /**
     * @var Money[]
     */
    private array $productsBalance = [];
    /**
     * @var int[]
     */
    private array $productsCount = [];

    public function __construct(UuidInterface $consumerId)
    {
        $this->recordThat(CartWasCreated::occur(Uuid::uuid1(), $consumerId));
    }

    public function addProduct(Product $product): void
    {
        $this->recordThat(ProductWasAddedToCart::occur($this->id, $product));
    }

    protected function apply($event): void
    {
        if ($event instanceof CartWasCreated) {
            $this->cartCreated($event);
        }

        if ($event instanceof ProductWasAddedToCart) {
            $this->productAddedToCart($event);
        }
    }

    private function cartCreated(CartWasCreated $event): void
    {
        $this->id = $event->aggregateId();
        $this->consumerId = $event->consumerId()
    }

    private function productAddedToCart(ProductWasAddedToCart $event): void
    {
        $product = $event->product();
        $productId = $product->productId();
        if (array_key_exists((string)$productId, $this->products)) {
            ++$this->productsCount[(string)$productId];
            $this->productsBalance[(string)$productId] = $this->productsBalance[(string)$productId]->add($product->price());
        } else {
            $this->productsCount[(string)$productId] = 1;
            $this->productsBalance[(string)$productId] = $product->price();
        }
    }
}
```

## Conclusion

This is pretty much it. Well... ok, this in not entirely true. There are still some unresolved issues here, such as how to store events or how to implement aggregate snapshot, but these are all infrastructure-based issues. Having only those two classes, I'm able to start coding any domain. If you think that implementing Event Sourcing by yourself is too hard, or too much, you can always use ready-to-go framework like I did at first. I think this is fine, but making a domain dependent on a particular tool is not a good solution in the long run. If you already implement business logic, why not to implement something that is trivial yet powerful. It's not like you have to implement whole infrastructure yourself - leave that part for the experts.

All the code with added tests is available on [github](https://github.com/unixslayer/event-sourcing).

[CQRS, Task Based UIs, Event Sourcing agh!](http://codebetter.com/gregyoung/2010/02/16/cqrs-task-based-uis-event-sourcing-agh/)

[GOTO 2014 • Event Sourcing • Greg Young](https://www.youtube.com/watch?v=8JKjvY4etTY)

[Greg Young — A Decade of DDD, CQRS, Event Sourcing](https://www.youtube.com/watch?v=LDW0QWie21s)

[One simple trick to make Event Sourcing click](https://blog.arkency.com/one-simple-trick-to-make-event-sourcing-click/)