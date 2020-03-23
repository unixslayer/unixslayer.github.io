---
title: Changing development
layout: post
date: 2019-05-07
categories: [Developer workshop]
tags: [business, development, efficiency, management, php]
---

In software companies, development is the real core of business. Some time ago, the idea of organizing the development team was born in my head. A flow based on specific assumptions, defining the general outline of cooperation between individual departments of the company that implements any software.

## Assumptions

I have adopted a number of assumptions that I will stick to.

* There is a clear division of responsibilities depending on the position – e.g. we are able to say exactly where the responsibility for the programmer ends, and where it begins for the administrator
* The implemented projects have a common denominator – it can be a technology stack, a framework, a platform, anything. I will show a solution based on organization implementing Magento.
* Team members have access to the same tools with the appropriate permissions – chat, code repository, CI tools, and other.
* The development team are determined allocate a certain (maximum) part of time to work on projects, e.g. 60% per iteration.

## Challenges

The change process should always start well from diagnosing what and why we want to change. We already know `What?`, so `Why?` must be defined. Here, I indicate the problems that can be encountered in almost every software company.

`Inaccurate estimation and transgression of those declared`

Probably the most difficult thing in software development. The eternal problem of what to do with the question “when will it be ready?”.

`Repeatability of work`

How many times have the same functionality been performed in each project from scratch and each time slightly differently?

`Lack of substitutability and interchangeability of people`

Have you ever met with a situation when a “key” team member goes on vacation or simply has a random event and the whole project stops in place?

`Lack of consistent documentation`

Well. The most important thing is the code to be done :)

`Lack of consistent work standards and knowledge exchange`

Here “how many programmers, that many solutions” principle goes up. Unfortunately, this increases the threshold of entry of a new person into the project or sometimes even hinders the rotation between projects for people who, after all, work together in the same company. While it can be largely done at the team level, there is high chance that between different projects it may occur. Unfortunately, consistent documentation is not a golden gun in here.

If any of this sounds familiar and you are going to read further, then I am very happy :) Maybe you will find answers to your problems. But if you’ve already solved them in your organization, you can confirm your methods or see how others approach the topic.

## Case study

On both ends there is always a customer. And I mean customer who ordered to our job. Before implementation client is the one who provides business requirements for analytics and architects and before and after project starts he is still the one who verifies if implementation meets what business needs. Even if client has technical skills and can participate in implementation process, he should only suggest and nothing more. Client responsibility should be narrowed only to deliver business requirements, describe how his organization works, provide complete set of crucial data for development team. We cannot rely nor expect that client will embrace whole development process. He just won’t do it. Client is only a client and if anything goes wrong we are the ones who should take responsibility for failure.

Client should be able to communicate with Amigos team – our specialists who have knowledge and competences high as possible. Among them are programmers, analytics, administrators, testers and anybody who participate in project. It is Amigos responsibility to take what business provide and turn it into real, ready to take tasks. It’s also them who should verify if client delivered enough information needed to implement functionality.

Amigos turn business requirements into product requirements. Gathering information from client the decide how implementation will look like – what technologies should be used, how services should be configured, how implementation affects big picture, etc. In short – Amigos takes What? and turn it into How? Tools adapted to this type of needs work very well here. Some time ago i found Atlassian blog post about [Product Requirement Document](https://pl.atlassian.com/agile/product-management/requirements). PRDs themself – what they are? what do they bring? what problems do they solve? – deserve separated article. I’m going to do that :)

In result of Amigos work are specific tasks should be created, which will help to deliver specific functionality. And because implementation details are specified, each task can be estimated more accurately. Any team member who takes such task won’t waste any extra time to figure out how to implement it.

An interesting thing is the organization of the code itself. According to the adopted assumptions, we implement a specific e-commerce platform. By limiting ourselves to a particular version, we can assume that if the functionality will work properly on it (e.g. 2.3.x) it should work the same in any project based on the same version. That way we’ve created the project we can call Proof of Concept (e.g. PoC-2.3.x) and assumed that features planned for the project based on Magento 2.3.x must work properly on PoC-2.3.x.

Lets get back to PRD. I’ve already said that it should take effect in specific tasks ready to implement. But first Amigos must decide if requested feature is suitable for implementation in any way in our PoC. If so, tasks should also describe where it must be implemented – PoC or project itself. It may be that all work needs to be done only in PoC and module will be ready to install in the project. It also may be that most of the code will be done in the project and only core functionality will end-up in PoC – the one without business overhead. Or it may be that PRD will define two tasks: one that will describe implementation details needs to be done in PoC; another that will describe how to configure or extend the module in the projekct. Each time it depends and decision must be done after careful analysis done by Amigos.

In assumption PoC must be stable project which has its own CI process. We must be able to run it in any moment from production branch with certainty that it will work properly. Code that will be introduced into PoC will became our private store with modules which we should be able to take, tag with proper version, define dependencies and share for installation, e.g. with composer.

As it usually happens, the key to success is persistence. Therefore, the above flow should be consistently followed for any project that appears in our organization. If that shouldn’t be enough, we should strive to make every feature/change/bug carried out without exception. Lets say we have project that was delivered that way, it’s already running on production, it’s monitored by the Ops team and everybody is happy. The only new thing that shows up in our flow is the source of issues/errors for Amigos to analyse. It doesn’t matter if we have change feature, bug or critical issue that suddenly occurs on production. We still have to decide Nie ważne czy będziemy mieć do czynienia ze zmianą funkcjonalności, błędem którego wcześniej nie przewidzieliśmy czy krytyczną sytuacją, która nagle pojawia się na produkcji. We need to know what this is about, where it needs to be changed and what is to be their target range.

![RD-Schemat9](/assets/RD-Schemat9.png)

## Conclusion

Lets get back to our challenges and look if and how we managed to deal with them.

`Inaccurate estimation and transgression of those declared`

By creating Amigos team and introducing PRDs we are able to do better estimate and verify the time team spend on implementation. Also team members can focus more on tasks since implementation details are delivered for them.

`Repeatability of work`
By introducing PoC we’ve created repository full of ready-to-use modules which should work properly on specific version. If we also prepare Infrastructure as a Code we increase certainty that functionalities will work with preconceived assumptions.

`Lack of substitutability, interchangeability of people and lack of knowledge exchange`

By reorganizing work and introducing responsibility separation based on roles (more in the end) we make the percentage of irreplaceable people become insignificant (if any). Don’t forget that we determined amount of time that team has for implementations. That way we can do better planning further iterations including space for events which help exchange knowledge – internal heckatons, meetups and others.

`Lack of consistent documentation`

PRD become our documentation. There should be clear rule that team don’t take tasks which has no documentation nor estimation.

`Lack of consistent work standards`

In some way PoC assure that code will be produced in accordance with accepted standards. Everything that PoC don’t cover should be treated separately.

Finally, it is worth to look at how in the discussed model work is organized and how communication flows in the software development process.

![RD-Schemat14](/assets/RD-Schemat14.png)

You should take into consideration, that there are no specific people assigned to any role. Information flow between roles is critical for project to success. It’s not only about quality of information. It is important for team that business don’t interrupt in their work, so they don’t loose focus. Also it’s not always desirable that team reports to business in other way than to deliver functionalities. It is crucial to define limits of responsibility.

