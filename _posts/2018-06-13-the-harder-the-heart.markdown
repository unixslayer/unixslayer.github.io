---
title: The harder the heart...
layout: post
date: 2018-06-13
categories: [diary]
tags: [based on true events, developer stories, funny, programmer]
---

It’s hard to be a programmer nowadays and it’s not because all the technology that is also changing so fast. You can always learn new tools, languages and stuff in finite amount of time. There are many programming languages with entry threshold so low it’s easy and fun to learn them. A lot of additional software works out of the box, so they can be tested almost without any cost.

It’s people that make this difficult.

In last 10 years, I’ve worked in few companies with variety number of employees. From 3 (including myself), to over 200 where most of them was programmers. If something was going wrong, it was always the human factor.

People are strange. They want to be a perfectionists. Or at least to be considered as such. They find it realy hard to admit that something is difficult, or they don’t understand it. Many times they are so detained on their solusions, that showing them another way is real rocket sience.

> – Ok, we are going to implement the same gitflow in every team in our company.
>
> – And what is wrong about our current gitflow?
> 
> – You don’t have development branch separated from production branch. You are making new feature branches from master instead of develop, which you don’t have. Later, feature is merged to release branch, not to source instead. After a while you are missing track of this feature. Also you have over 150 historical branches that are not needed anymore.
> 
> – So what do you suggest?
> 
> – Look at this basic gitflow (here was an elaboration about gitflow described [here](https://datasift.github.io/gitflow/IntroducingGitFlow.html)).
> 
> – I don’t see any added value implementing this into our work. This makes no sense to me. Also as I look at it, it’s no different than the way we work right now. It’s just more simpler and we already have our way works.
> 
> – If you don’t see any difference, why you don’t want to work that way?
> 
> – I just don’t. I will if it’s going to be official, but right now, I’m not going to use it.

But real pain in the ass is when they don’t know something, and are afraid to ask. This is when shit happens.

> – We need to upgrade our codebase framework to higher version.
>
> – Is that a problem?
>
> – We keep all vendor packages in separated git repository with our custom changes…
>
> – Ok, all you have to do is to make a clean `composer install` of your `composer.lock` file, take the difference between that and what you have in repository and put it all into patches. This shouldn’t be a problem.
>
> – We also handle few other projects in one main repository.
>
> – And how do you manage to do that?
>
> – We have a master branch per each project ... in the same repository.
>
> – Why the hell you did it?
>
> – No one told me not to do that.
>
> – ...

I’m not saying that striving for perfection is a bad thing.

I’m not saying that people shouldn’t be doing anything because they don’t understand it.

All I’m saying is that people should’t be afraid to say „I don’t know how to do this” or „I’m not sure if this is the right way”. Asking for help is never a bad thing. If you ask for help, you can learn something new. You will improve yourself.

On the other hand if you hide in your dark, tiny basement you will never feel that you are part of something bigger.

It’s also very important for you to ask for feedback, even if you will hear bad opinion. If you don’t know what is wrong, than how you are going to be better?

> One thing we’ve learned from our mistakes
> The harder the heart, the harder it breaks
>
> – BFMV
