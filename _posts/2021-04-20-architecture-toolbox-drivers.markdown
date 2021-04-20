---
title: Architecture toolbox&colon; drivers
layout: post
date: 2021-04-20
categories: [architecture-toolbox]
tags: [architecture, drivers, decisions, risks, metrics]
---

Software development require us to make decisions which shape our architecture. These decisions are influenced by many factors and correct analysis and interpretation of which allows us to make the "right" ones. These factors are called architectural drivers of which knowing and understanding significantly facilitates decision-making at any point in the life of the project.

Architectural drivers define the final shape of the system explaining why one technology or solution was chosen instead of another. Individual drivers do not have to apply to the entire system, e.g. availability may be more related to cart functionalities than viewing application logs.

## Functional requirements

One of the projects I was implementing recently assumed that users should be able to send large files (> 1GB) to the server via a browser. This type of requirement prompted the team to select a set of technologies to deliver the desired functionality. 

## Quality attributes

In addition to providing functionality, the system should be scalable, reliable, accessible, easy to configure, etc. These types of requirements will also have a direct impact on selected technologies. Note that "quality" refers to the quality of the system being implemented as a whole. They do not result directly from functional requirements, so the development team should be responsible for discovering them. If not defined early enough, some of the quality attributes can be expensive and difficult to implement, e.g. it may be a good idea to think about scalability at early phase of a project.

## Conventions

If one specific library is used for logging in the whole organization, there is a high probability that if you need to implement logging in a new project that library will be used. These types of conventions are very often used to facilitate decision making. It is good if the organization has procedures in place to facilitate their support and development. This will help to maintain an attractive working environment, which should encourage new specialists to work with us and retaining the current ones as well.

## Limitations

We must take into account the fact that we will struggle with various limitations at daily basis. In addition to time and money, we will be limited by resources, technology or even our own knowledge. We will not choose an expensive, complicated technology that no one in our organization knows, if a similar solution that has been used for years and provides similar functions is available for free. Sometimes, even trying to learn about a new technology may turn out to be too costly.

## Goals

Lets say you are writing an application that is supposed to accept a data set, perform calculations on it and generate a report file. In addition, the entire application will be used only once or will be run once every three months. Probably instead of a relational database, you will save intermediate data in memory or in a key-value database. The purpose for which the application is created should contribute to making architectural decisions. However, this class of drivers is often omitted, although I myself am of the opinion that in some cases deviations are allowed, although these deviations may more often result from adopted conventions.

# Life of a driver

Discovering architectural drivers is crucial to the success of a project as it not only saves time and money, but also brings us closer to making the right decisions. Some may seem trivial, some more complicated. Sometimes a project finds itself at a point where one decision may be excluding others (wholly or partially). With a large number of technologies that we can use, it is easy to make a mistake. Architectural drivers help us narrow the spectrum of choice, bringing us closer to taking the best one, corresponding to the real needs of the project.

Since we do not operate in a perfect world, a single person who will know the answer to all questions and thus provide us with knowledge of all architectural drivers for a project doesn't exist. Especially if the project has many subdomains covering different parts of the business. That is why we should learn about architectural drivers from possibly the largest group of stakeholders, each of whom has their own requirements and goals. The section on stakeholders and discovering drivers with them is so extensive that it requires a separate article. 

We do not know how our system will be received after production launch. Some of the architectural drivers result directly from the requirements that can change - drivers can also change over time. There are so many factors that can affect the priorities that you should not be too attached to once defined drivers. Yes, they are binding, but it may often turn out that they need to be corrected or completely changed.

# Metric as driver quantification

Even the best described driver can mean something different for everyone, e.g. driver that describes the scalability of the application. This is where metrics come in handy that will allow you to clearly understand the driver. The metric should be expressed in numbers with several components:

- current value
- target value
- disaster value - the minimum threshold for the success that let us achieve the metric
- perfect value - value high enough, that it may seem unreachable

Staying in the example of scalability, it will be understood differently by different team members. For some, the issue of horizontal / vertical scalability will be important, for others, infrastructure utilization or the time needed to start new instance of the application. 

When describing the metrics, it is important to separate them into two categories: qualitative metrics and technical debt metrics. We will use a qualitative metric to describe the desired quantity that we will strive for. An example of such a metric will be the level of infrastructure utilization - the more the better. In opposite, debt metrics will describe the amount from which we should run away, e.g. the time needed to run an additional instance - the less the better.

The metric should not be subject to interpretation. Each "it depends" statement should be explained in the metric description. 

In addition to an unambiguous description, we must take care of the measurability and availability of the metric. Imagine that to get a simple result, you need to generate data from several sources and then subject it to complex analysis. Even with a perfectly described metric, we will not achieve anything if we are not able to easily measure the result. 