---
title: What I’ve learned after six months of Event Sourcing
layout: post
date: 2020-01-21
categories: [Developer workshop]
tags: [aggregates, architecture, Domain-Driven Design, entities, events, EventSourcing, workshop]
---

On July 2019 I’ve started working for one of polish payment service providers. In one of my responsibilities was to lead team in order to develop application that integrates with new open banking systems based on `PSD2` directive. I got a little over a month to learn about the functional requirements and propose the architecture for the system.

A few months earlier I participated in workshop conducted by Mariusz Gil, where he introduced the concept of `Event Sourcing`. I’d also participate in project where that concept was implemented. Having a certain level of knowledge about `Domain-Driven Design` and after looking through bunch of stuff about ES it all started to come together when reading again product requirements. Today, after half year of programming I’ve decided to gather part of my knowledge and write down few of my conclusions I came into.

## Event Storming

> It’s developer’s (mis)understanding, not expert knowledge that gets released into production
> 
> Alberto Brandolini

Okay. We are programming application that supports certain domain. In that domain certain events take place. Key to success is to understand this domain. `Event Storming` comes here with help. Antonio Brandolini came up with a workshop that helps to get in-depth knowledge of the domain in which we are moving. The basis of the workshop is collecting events that occur in the system. Those are represented by sticky notes placed on the wall. Each note can be either an event, actor, system, view, etc, each shown in different colour. Notation is really simple to learn. As the workshop progress, the cards are ordered chronologically, we get to know the dependencies between those events, we can separate bounded context that occur in our domain, point hot spots which we can have some sort of problems but most of all we can find out what we don’t know about the project yet. Workshop itself is not for developers only but for everyone who have valuable knowledge and can be our domain expert. This way, we gain a very broad knowledge of the system also leveling its level among the key people of our organization.

After our first workshop I was very excited. As it turned out later, we made several mistakes in its conduct, but in the end you have to start somewhere.

Gathering domain knowledge is crucial for the success of the project. `Event Storming` helps in that matter like nothing else and the effect of its implementation is very helpful in the subsequent understanding of the system and becomes an integral part of the project documentation. It also let you deal with upcoming and sudden changes being the way out to find answers to almost every question that arises. For me this is mandatory element of software development process.

There are buch of articles and courses about this method. Mariusz Gil gathered it nicely [here](https://github.com/mariuszgil/awesome-eventstorming).

## Keep your events light and simple

Events that occur in your application mostly will carry specific data. For example, our application is designed to order transfers in banking systems. The mere information that the user has ordered a transfer is of little value if we do not know to whom this transfer is to be sent, what is its amount or title. Although we have to remember that we will be facing various changes in our application. That way we can be taking into consideration either to add new events, remove or modify existing ones. The last one should never take place. In general, events that already occur stay in history and you should think about them as immutable data. It’s not that it is not possible, but it is difficult and can bring serious aftermath.

After Event Storming session we will end up with wall covered in stickers like “transfer was made” which will carry all information related to this event. However on design level you should keep in mind that events should be more specific and contain only common data. Instead of having one event saying that “transfer was made”, which will carry information about amount, currency, recipient and sender account number and transfer description you should consider events more like:

- “transfer was made” – with date of ordering the transfer
- “sender account number was provided”
- “recipient account number was provided”
- “transfer value was provided” – in most cases amount and currency will occur together

… and so on. It is easier to add new events, which we didn’t discover yet or remove ones that was defined by mistake or are no longer needed. Like it is impossible to change the past in real life, tt can get very hard to change the history in application that runs for a while and is crucial for your business.

## Data, data, data … lots of data

Keeping every event that happened in our application is no doubt advantage of Event Sourcing. That way we can, for example reproduce user behavior or state of whole application; use historical data in order to generate any kind of reports. As long we have events, we can do anything. Those events are saved in so called `Event Store`.

We can have one Event Store for all events. Imagine that our application orders around 200 transfers per minute, and in single entity lifetime around 50 events may occur. As a result, we end up with a single table in the database that swells very quickly. To reconstitute aggregate from history will be less and less optimal each day. As long snapshotting can help us a bit here, still it is not good solution for large application.

Another way is to have an Event Store for each entity. Again, not a good solution. With 200 transactions per minute we will end up with a lot of small tables in our database in no time. Depending on amount of entity lifetime, we can have only a little amount data in those tables. In addition, with a large number of entities, it can be difficult to debug having a large number of tables, not to mention the level of irritation from the staff managing the database.

Another solution is to have a Store for every entity within application. As long as solution should depend on needs, I think that this is the most optimal and comfortable way to deal with events. This gives us more intuitive context bounding, each stored in its own place. Debug process should be also less problematic since all we have to know is context we are working with.

## Aggregates/entities are not for reading data

Aggregate as design pattern used in `Domain-Driven Development` should encapsulate business logic in bounded context. If aggregate has a lifespan and can be identify by any unique value, then we are dealing with an entity. In `CQRS` commands will use those entities to perform logic. Most of the time some conditions must be fulfilled before operation can be run and technically we can load entity, check those conditions and decide if we have to do anything. Of course we can make our entity to have public API that will help us check those conditions with, but this way we can end up exposing data that should not be exposed and we will make our code way to much complicated just to have access to few flags outside entity. Happily there is a `Q` that stands for `Query`. Also a good practice would be to check those conditions before even reaching for an entity.

Let’s say that application has a bank transfer entity. This entity can make a transfer in external, banking system and get its status in return. Based on its value we would have to do something, eg. send notification if we get a final status. At this point it can be tempting to make a public method so we can know what is the current transfer status. Although reconstituting whole entity from all its events just to get single information is a little to much. You can do it, but more complicated entity will get, you should see fast enough that something is not right. To perform an operation and exposing data will be to much responsibility for our entity – it only has to make the transfer and at most interpret the response from the bank system, registering “transfer status obtained” event.

In the place where we need to know the current status of the transfer, we should use the `Read Model` which gets updated using projection. This way, we obtain responsibility segregation related to the specific functionality of our system. We can have many Read Models and projections that update them, even for the same entity.

## Projections are not only for updating read models

`Projections` are undoubtedly a tool that allows us to update the Read Model. But this is not necessarily the only thing we can use them for. By operating on events, it is possible to execute certain business logic to be called in a specific situation.

Returning to the bank transfer entity, one of the operations it performs is asking the bank’s API about the status of the transfer. We know from functional requirements that a change of status should result in sending a notification to the client. We know the current status of the transfer, so when we download it again, we can register the “transfer status has changed” event. But if we don’t want to send notification during the same process as retrieving the status, we can create a projection which, if change occurs, will send a message (or more possible, notify another process to send the message).

!EDIT! There is another solution for domain event to trigger another business operation. We can simply emit those events via `Event Bus` directly after saving aggregate. Although this should be done with cautions since we can end up in situation where simple aggregate operation will take forever to give a feedback to user. We should laverage between handling events in sync and async way. 

## Event Sourcing supports testing

Maybe `Event Sourcing` doesn’t support code testing just like that. However, by choosing ES, it will be easier for us to implement the principles of `Domain-Driven Design` and others, such as `SOLID`. Our classes, whether aggregates, values or anything else, will be smaller and more specialized. They will have a specific API that will have to meet specific test scenarios. With more small classes, it’s easier to write tests. And we all know how important testing of created software is.

For the first three months of implementation, the entire project, apart from the business code, consisted of a set of tests: unit, integration and functional; without any infrastructure, even in the form of a database.

Also implementing `TDD`’s test-code-refactor-repeat became much more simple.

## Keep your docs up to date

I will not dwell here on how to keep project documentation. I will only point out that if there is no time in the process to supplement it, then we will quickly come to a situation where nobody knows what is going on and why. In software development, change is the only constant. And documentation is something that suffers from it the most.

