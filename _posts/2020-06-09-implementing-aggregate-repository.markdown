---
title: Implementing Aggregate Repository
layout: post
date: 2020-06-09
categories: [tech]
tags: [event sourcing, php, prooph, diy, ddd, aggregate, repository, event store, events]
---

When it comes to persisting an aggregate we have several options. We can take the current state of object and save it in chosen storage. Whether it will be a relational or document-based database we will need a layer that help us map our objects into its schema, like ORM. However, when we want to save `Event Sourced` aggregate we need to take all recorder events and append them to `Event Stream`. Those streams can be persisted in physical storage which will be represented by `Event Store` which can be relational or document database, or dedicated tools like [EventStore](https://eventstore.org).

## Simple as that

I strongly advise everyone against writing your own `Event Store`. While for the purposes of `Event Sourcing` only a few classes were needed, in the case of `Event Store` we are dealing with much more complicated problem, that will be very difficult and expensive to maintain. That is why it's better to use a ready-made solution. Here I am going to use the [prooph/event-store](https://github.com/prooph/event-store) component. While writing this, intensive work is underway on version 8, which can be used to integrate with [EventStore](https://eventstore.org). However, having some experience with `PDO` implementation, I will use version 7 for now to store events in relational database using [prooph/pdo-event-store](https://github.com/prooph/pdo-event-store). Doing so will only require several classes to implement.

```bash
$ composer require prooph/pdo-event-store
```

The above command will install all dependencies we need. We can proceed to the implementation of our repository.

```php
<?php

declare(strict_types=1);

namespace Unixslayer\EventSourcing;

use Ramsey\Uuid\UuidInterface;

abstract class AggregateRepository
{
    public function saveAggregateRoot(AggregateRoot $aggregateRoot): void
    {
        //...
    }

    public function getAggregateRoot(UuidInterface $aggregateId): ?AggregateRoot
    {
        //...
    }
}
```

Our repository has two public methods: one for saving and the other for reading an aggregate. Let's focus on saving for now.

## Persisting an aggregate

1. Our aggregate will be saved in relational database with use of `prooph/pdo-event-store`
1. Saving an aggregate means we have to save events that this aggregate has registered
1. Sequence of those events will be called as `Event Stream`, which will be associated with a particular aggregate. In my case this was the most convenient option, [which I already wrote about](/what-ive-learned-after-six-months-of-event-sourcing#data-data-data--lots-of-data)
1. If `Event Stream` doesn't exists, it should be created when saving an aggregate

Let's implement those assumptions in our repository class.

```php
<?php

declare(strict_types=1);

namespace Unixslayer\EventSourcing;

use Prooph\EventStore\EventStore;
use Prooph\EventStore\Exception\StreamNotFound;
use Prooph\EventStore\Stream;
use Prooph\EventStore\StreamName;
use Ramsey\Uuid\UuidInterface;

abstract class AggregateRepository
{
    private EventStore $eventStore;

    public function __construct(EventStore $eventStore)
    {
        $this->eventStore = $eventStore;
    }

    public function saveAggregateRoot(AggregateRoot $aggregateRoot): void
    {
        if (($aggregateType = \get_class($aggregateRoot)) !== $this->aggregateType()) {
            throw new \InvalidArgumentException(sprintf('Expecting %s, got %s', $this->aggregateType(), $aggregateType));
        }

        $events = $aggregateRoot->recordedEvents();
        if (empty($events)) {
            return;
        }

        $streamEvents = new \ArrayIterator($events);
        try {
            $this->eventStore->appendTo($this->streamName(), $streamEvents);
        } catch (StreamNotFound $e) {
            //if event stream was not found, repository will tell EventStore to create new one saving events
            $stream = new Stream($this->streamName(), $streamEvents);
            $this->eventStore->create($stream);
        }
    }

    // ...

    abstract protected function aggregateType(): string;

    abstract protected function streamName(): StreamName;
}
```

Everything looks fine: 

- repository will save only a specific aggregate, which means that if we want to persist an `AggregateRoot` we are required to write separate repository
- if aggregate contains registered events they will be saved in `Event Store` as `Event Stream` also dedicated for specific aggregate
- if `Event Stream` doesn't exists it will be created on the first attempt to save the aggregate

Before we continue to loading part, one more issue needs to be raised. `Event Store` has no idea about how our domain events works. In case of `prooph/event-store` it is required that events must implement `\Prooph\Common\Messaging\Message` interface. Since we do not want to mix component logic with our domain, we have to implement a layer that will translate our domain in a way that `Event Store` can understand.

```php
<?php

declare(strict_types=1);

namespace Unixslayer\ProophEventStoreBridge;

use Prooph\Common\Messaging\DomainEvent;

final class EventData extends DomainEvent
{
    private array $payload;

    public function payload(): array
    {
        return $this->payload;
    }

    protected function setPayload(array $payload): void
    {
        $this->payload = $payload;
    }
}
```

The actual implementation of `Unixslayer\ProophEventStoreBridge\EventData` will be persisted in `Event Store`. Extending `Prooph\Common\Messaging\DomainEvent` we make sure that it contains all logic needed to work properly. Now we only need one more class that will transform our events into proper ones.

```php
<?php

declare(strict_types=1);

namespace Unixslayer\ProophEventStoreBridge;

use Unixslayer\ProophEventStoreBridge\EventData;
use Prooph\Common\Messaging\Message;

final class MessageTransformer
{
    public function toEventData(AggregateEvent $event): Message
    {
        $event = $event->withAddedMetadata('_messageName', \get_class($event));

        $messageData = [
            'uuid' => $event->uuid()->toString(),
            'message_name' => EventData::class,
            'created_at' => $event->createdAt(),
            'payload' => $event->payload(),
            'metadata' => $event->metadata(),
        ];

        return EventData::fromArray($messageData);
    }
}
```

Just before the transformation, `MessageTransformer` adds our class name into metadata. This is due to the way that already saved events loads. When reading data, `Event Store` will create objects based on `message_name` value, which still have to implement `\Prooph\Common\Messaging\Message` interface. When those events will be transformed back into our domain events we need to know which object should be recreated. This information will be kept in metadata.

Now, we have to make our repository able to transform our events into `Event Store` ones.

```php
<?php

declare(strict_types=1);

namespace Unixslayer\EventSourcing;

use Prooph\EventStore\EventStore;
use Prooph\EventStore\Exception\StreamNotFound;
use Prooph\EventStore\Stream;
use Prooph\EventStore\StreamName;
use Ramsey\Uuid\UuidInterface;
use Unixslayer\ProophEventStoreBridge\MessageTransformer;

abstract class AggregateRepository
{
    private EventStore $eventStore;
    private MessageTransformer $messageTransformer;

    public function __construct(EventStore $eventStore, MessageTransformer $messageTransformer)
    {
        $this->eventStore = $eventStore;
        $this->messageTransformer = $messageTransformer;
    }

    public function saveAggregateRoot(AggregateRoot $aggregateRoot): void
    {
        if (($aggregateType = \get_class($aggregateRoot)) !== $this->aggregateType()) {
            throw new \InvalidArgumentException(sprintf('Expecting %s, got %s', $this->aggregateType(), $aggregateType));
        }

        $events = $aggregateRoot->recordedEvents();
        if (empty($events)) {
            return;
        }

        $events = array_reduce($events, function (array $carrier, Event $aggregateEvent) {
            $eventData = $this->messageTransformer->toEventData($aggregateEvent);
            $eventData = $eventData->withAddedMetadata('_aggregateType', $this->aggregateType());
            $carrier[] = $eventData;

            return $carrier;
        }, []);

        $streamEvents = new \ArrayIterator($events);
        try {
            $this->eventStore->appendTo($this->streamName(), $streamEvents);
        } catch (StreamNotFound $e) {
            //if event stream was not found, repository will tell EventStore to create new one saving events
            $stream = new Stream($this->streamName(), $streamEvents);
            $this->eventStore->create($stream);
        }
    }

    // ...
}
```

## Recreate an aggregate

To recreate an aggregate is simply an operation opposite from saving it - we have to load already saved events and recreate it by applying those events one-by-one. Our aggregate already has the appropriate functionality, we just need to complete our repository in the right way. Before that, however, we have look at the way events are being read.

We know that `Event Store` will return `Event Stream` with `Unixslayer\ProophEventStoreBridge\EventData` objects - events are persisted in that way. We need to use `_messageName` saved with metadata to make sure that we have proper event objects before recreating an aggregate. Therefore, `MessageTransformer` should have a method that will correctly translate one object to another.

```php
<?php

declare(strict_types=1);

namespace Unixslayer\ProophEventStoreBridge;

use Prooph\Common\Messaging\Message;
use Unixslayer\EventSourcing\Event;

final class MessageTransformer
{
    // ...

    public function fromEventData(EventData $eventData): Event
    {
        $messageName = $eventData->metadata()['_messageName'];

        if (!\class_exists($messageName)) {
            throw new \UnexpectedValueException(sprintf('`%s` is not a valid class.', $messageName));
        }

        if (!\is_subclass_of($messageName, Event::class)) {
            throw new \UnexpectedValueException(\sprintf(
                'Message class %s is not a sub class of %s',
                $messageName,
                Event::class
            ));
        }

        return $messageName::fromEventData($eventData);
    }
}
```

By transforming saved event to an equivalent from our domain, we make sure that the expected class exists and is an implementation of `Unixslayer\EventSourcing\Event`. Since class has non-public constructor and we don't really want to create completely new object, we are calling method that let us recreate it.

```php
<?php

declare(strict_types=1);

namespace Unixslayer\EventSourcing;

use Ramsey\Uuid\Uuid;
use Ramsey\Uuid\UuidInterface;
use Unixslayer\ProophEventStoreBridge\EventData;

class Event
{
    // ...

    public static function fromEventData(EventData $domainMessage): Event
    {
        $messageRef = new \ReflectionClass(\get_called_class());

        /** @var Event $message */
        $message = $messageRef->newInstanceWithoutConstructor();

        $message->uuid = $domainMessage->uuid();
        $message->createdAt = $domainMessage->createdAt();
        $message->metadata = $domainMessage->metadata();
        $message->payload = $domainMessage->payload();

        return $message;
    }
    
    // ...
}
```

Now let's head back to the repository and implement reading method.

```php
<?php

declare(strict_types=1);

namespace Unixslayer\EventSourcing;

// ...
use Prooph\EventStore\Exception\StreamNotFound;
use Prooph\EventStore\Metadata\MetadataMatcher;
use Prooph\EventStore\Metadata\Operator;
use Ramsey\Uuid\UuidInterface;
use Unixslayer\ProophEventStoreBridge\EventData;

abstract class AggregateRepository
{
    // ...

    public function getAggregateRoot(UuidInterface $aggregateId): ?AggregateRoot
    {
        $streamName = $this->streamName();
        $metadataMatcher = new MetadataMatcher();
        $aggregateType = $this->aggregateType();
        $metadataMatcher = $metadataMatcher->withMetadataMatch('_aggregateType', Operator::EQUALS(), $aggregateType);
        $metadataMatcher = $metadataMatcher->withMetadataMatch('_aggregateId', Operator::EQUALS(), (string)$aggregateId);

        try {
            $streamEvents = $this->eventStore->load($streamName, 1, null, $metadataMatcher);
        } catch (StreamNotFound $e) {
            return null;
        }

        if (!$streamEvents->valid()) {
            return null;
        }

        $aggregateEvents = array_reduce(iterator_to_array($streamEvents), function (array $carrier, EventData $eventData) {
            $carrier[] = $this->messageTransformer->fromEventData($eventData);

            return $carrier;
        }, []);

        return $aggregateType::fromHistory($aggregateEvents);
    }

    // ...
}
```

## Put it all together

Returning to [example with a cart](/how-i-did-my-own-implementation-of-event-sourcing) we can create a repository responsible for writing and reading our aggregate.

```php
<?php

declare(strict_types=1);

namespace Unixslayer\Domain;

use Prooph\EventStore\StreamName;
use Unixslayer\EventSourcing\AggregateRepository;

final class CartRepository extends AggregateRepository
{
    protected function aggregateType(): string
    {
        return Cart::class;
    }

    protected function streamName(): StreamName
    {
        return new StreamName('cart');
    }
}
```

```php
<?php

namespace Unixslayer\Domain;

use Money\Currency;
use Money\Money;
use Prooph\EventStore\InMemoryEventStore;
use Ramsey\Uuid\Uuid;
use Unixslayer\ProophEventStoreBridge\MessageTransformer;

$cartId = Uuid::uuid4();
$cart = Cart::create($cartId, new Currency('PLN'));
$cart->addProduct(new Product(Uuid::uuid4(), Money::PLN(1000)));
$cart->addProduct(new Product(Uuid::uuid4(), Money::PLN(1000)));

$repository = new CartRepository(new InMemoryEventStore(), new MessageTransformer());
$repository->saveAggregateRoot($cart);

// ...

$cart = $repository->getAggregateRoot($cartId);
```

## Conclusion

Adding another 3 classes, what took no more than 2 hours, we can now persist the history and use it to recreate our `Event Sourced` aggregates.

Repository should work properly with any `Event Store` implementation included in `prooph/event-store:7`. All the code with added tests is available on [github](https://github.com/unixslayer/event-sourcing). Tests use `PostgreSQL` and `MySQL` databases, which `prooph/pdo-event-store` supports.