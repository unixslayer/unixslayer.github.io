---
title: Architecture toolbox&colon; estimations
layout: post
date: 2021-04-07
categories: [architecture-toolbox]
tags: [estimation, implementation, risks, howto]
---

In a discussion about whether to estimate or not, there are pretty decent arguments on both sides. It is not ether to estimate or not, because estimations should be done every time there is a need for a new feature or change of an existing one. It's more about how to approach and perform it and what estimation is really for.

#NoEstimates followers will say that estimates are not precise and can be a cause of bad decisions, overtimes, stress, and quality drop because the team has committed to deliver the product in time which is about to end. And there is (mostly) a business on the opposite side. Most of the time programmers have to estimate because PO needs to know the 'cost' of the next feature. In the case of describing MVP, estimation is a crucial piece of information. Estimating reduces the distance between devs and business but it's like a double-edged sword - when done wrong, it will be trouble for both.

# Estimation done wrong

People are exposed to cognitive biases. Some are dealing with them better, some worse but they apply to everyone without exception. We have to struggle with them every time a decision or judgment needs to be made and we don't even realize that something wrong is going on.

We tend to decide on the first information we receive. Let's say that I have something to sell for $30000. After a week or so when you ask me again, I'll tell you that I want $20000 for the same thing. If we manage to close the deal right away because your only motivation was dropping the price down 1/3, it is because of an anchoring bias. It makes us not validate the reliability of the information we received making a decision.

Sometimes we make our decisions based on our optimistic beliefs. This is understandable - we don't want to think about problems and issues that may occur. But this wishful thinking makes our estimations even worse because the world is not a fairytale. The more obstacles we can find, the more precise will our estimation be.

People that succeeded many times tend to behave overconfident forgetting about all aspects of success. How many times do we trust our guts more than the careful analysis or opinion of other members of our team? Even if we score 5/5 getting heads when flipping a coin, it is still only a 50% of chance that we won't get tails the sixth time.

# Mitigation of risks

Besides all psychological issues, several risks in software development have to be identified and taken into consideration when we are about to analyze and estimate any task. Those risks can let us fail without even knowing it. Being able to identify those risks and dealing with them in a proper way we can make estimates work.

## Something new

Being able to tell when we are dealing with something new can help us decide if we should even try to estimate. Taking a task into estimation we can try to categorize it based on the following questions: Is the solution known for everybody? Has anyone in our team done it before? Has anyone in our company done it before? Has anyone done it, but in a different context? We can estimate the task if we get a positive answer for the first three - the sooner we get 'YES', the better estimation we'll get. We can also try to adopt a solution from another context, but I recommend doing some additional research just to make sure we can use it. If the answer is 'NO' for all the questions, we shouldn't even bother trying to estimate. No worry, we can still be able to deliver a solution but we should use other tools for that. Ever heard of a spike? Or PoC?

To increase accuracy we can try to compare a given feature to something similar we've already done in the past. This can be achieved by finding common structural elements, patterns, or architectural styles. If we did something similar before, we will (with decent probability) spend at least the same amount of time implementing the same. Implementation differences like the number of attributes, exact endpoints, etc. should not make a significant effect on the final estimation.

## Knowledge gaps

You have to deliver yet another Airbnb. But only a few people are talking with business or (what is even worse) whole communication with the client goes through a single person and we end up playing deaf phone. Each task generates another task. Also, each iteration brings new tasks. Finally, you take overtime to meet a deadline but they get postponed one after another and the project has no end. After months of coding, it turned out that you end up with something completely different that was told in the beginning. Would it be easier if somehow visualize knowledge, and make sure that everyone involved in the project knows what we are doing?

Several tools can help with that. Event Storming (on 3 levels) or Event Modeling can be used to reduce general, unspecified, and undiscovered requirements. We should have defined architectural drivers and metrics for them. Good practice can be defining a set of behavioral scenarios. Both can increase common understanding of a project between devs and business and (what is forgettable) within the dev team itself.

## Large scope

When do you know that the scope is too large? Have you ever been in a situation, when you thought that you knew enough, start coding and got hit by so many dependencies, you don't even know what to do next? What if I told you it can get even worse if some of those dependencies are coupled with your business code that you don't know if you are changing project or vendor package?

Bounded Contexts can help you here. Being able to define valid boundaries in the system can help us separate bigger problems into small functionalities with the ability to place them in a specific place. Also, within Bounded Context, we can break down already a small problem even further using design elements. The problem reduced to a form that describes a specific implementation can be estimated with greater accuracy.

## Change of requirements

Time-consuming changes are painful. Changes that go beyond scope are painful. The smaller the change, with knowing what has to be done and where the greater probability that it can be done in finite time without cutting your wrists.

Following Conway's Law in system design lets us minimize the risk that change will go beyond a specific subdomain. Well-tailored Bounded Contexts, defined around small and specific models make it easier to find the place where change has to be made.

## Wait

How many times have you considered the time that needs to be spent waiting for something? How many times a task that was supposed to take a week of work get finished after two or more because you forgot that there is a dependency with something that also takes time?

Autonomy ... again. Read more about Conway's Law and learn to distinguish subdomains and define Bounded Contexts to minimize the communication and reduce coupling between components.

How many times have you been interrupted due to an urgent issue? Did deployment go wrong? New teammate failed to generate reports?

Automate as much as you can. If something is repeatable, it can most likely be written down as a script and put in a deployment pipeline or something.

# Conclusion

Learn when not to estimate. Sometimes it is better to spend a certain amount of time searching and checking the available options. It will be more responsible than making bare commitments.

Learn to use design elements. This will introduce repeatability and allow estimation through comparisons.

Look for autonomy at any cost. The smaller and more independent components you have, they will be easier to deliver and maintain in the future.

And if this doesn't come up from what you've already read, I'll say it now: estimate implementation, and implementation only. Try to figure out what steps the team has to take to deliver requirements. Narrowing down the scope into the smallest peace there is, the estimation will not only become more precise but also achievable.