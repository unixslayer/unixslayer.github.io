---
title: Firing a cannon at ants
layout: post
date: 2020-08-09
categories: [Developer workshop]
tags: [DDD, CQRS, Event Sourcing, Event Storming, Event Modeling, workshop]
---

The solutions should be tailored to the problem. This is a fact that is hard to disagree with. Listening to Mariusz Gil and Kuba Pilimon's podcast about `Large-scale structures`, something hit me. Very often you can hear something like "it won't work in every project" or "with smaller projects, it's a waste of time" from experienced experts sharing their knowledge.

Some time ago I got a simple project to do. The application was to accept payment orders, execute it in the PSD2 standard and return the payment status, which may actually be processed only after some time. I decided to try a new approach and implement this project using `DDD`, `CQRS/ES`. I started by organizing an `Event Storming` session. Two `Process Level` sessions, 3 hours each, and several smaller `Design Levels`. The domain turned out to be very simple, and the aggregates that were created - almost anemic. The `C4` model was also created :) The only thing that went beyond `CQRS/ES` were very low-level elements, such as communication with Banks' API.

Later I got another project. There was an application to be done that sends e-mails. Such with reports or transactional. The user wanted to be able to define message templates and order shipping in a fairly simple, but at the same time complex way. Here the domain was discovered with the help of `Event Modeling`. Lesson learned from my previous project, and I know what questions to ask during the workshop, how to organize the application architecture, what to pay attention to so I won't have to rewrite half the code at some point, how to implement events, how to extract subdomains and `Bounded Contexts`. The project, as it turned out, was a bit more complex than the previous one and introduced some new elements, such as the `Process Manager` pattern, which allowed for solving several complications that appeared. However, it was still a small scale in terms of the way it was implemented.

Now I'm starting another project. The previous ones turned out to be so well implemented that I was entrusted with providing the Affiliate Program application. Discovering the domain is still ongoing process - I'm after a few `Big Picture` sessions and in the middle of `Process and Design Level`, I already know that I will carry out this project in the same way as the previous ones. The project turns out to be much more complex, but instead of discovering new techniques, I extend the scope of those that I have already learned and slowly introduce new elements.

The arguments quoted in the introduction may be applicable only to projects that will not run for more than a few weeks. Then the development really should not be longer than the estimated lifetime of such an application. But one day a really big and ambitious project may come up. Should you wait for such a project to start using large and ambitious tools?

It's good to learn to shoot a cannon. If we shoot ants with it, possible losses will be small. It's just ants, after all. But when we hunt for big game, it seems to me that it is probably better to be prepared for it. Otherwise, we may be trampled.
