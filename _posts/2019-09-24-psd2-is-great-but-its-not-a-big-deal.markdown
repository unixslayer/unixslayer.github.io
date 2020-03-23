---
title: PSD2 is great… but it’s not a big deal.
layout: post
date: 2019-09-24
categories: [Programmer diaries]
tags: [API, money, online banking, open banking, payments, PSD2, REST, security]
---

On September 14th, `PSD2` came to live and the same day I read an article saying that “everybody can have access to your private account now”. I was like “Say whaaaaaa…?”.

The second version of PSD introduces several things in online banking, including it is assumed to be a definition of open banking, which means that banks are obliged to provide the payment service provider with a standardized method of accessing their resources. This, as intended, will unify the rules on the payment market and reduce the costs of online transactions. This does not mean, however, that from now on everyone will have access to my bank account anyway.

First of all, access is supervised. KIR (Polish Financial Supervision Authority) deals with this in Poland. I will not describe what the verification procedure looks like, but I will say that they carries it out very meticulously, which results in the fact that no commercial entity has obtained consent yet. And even if it is approved by KIR and obtains the status of TPP (Third Party Providers), it does not mean that it will be able to order transfers on our behalf or even view the history of our account. TPP may obtain the rights to:

- payment processing (Payment Initiation Services)
- access to account history (Account Information Service)
- the ability to confirm the availability of funds needed to make a payment without making it (Confirmation of the Availability of Funds).

The more rights the TPP applies for, the longer and more accurate the verification procedure will be. It does not matter, however, to what extent it works, everything is done with the direct consent of the account owner (Payment Service User) who intends to use the services of TPP. Each operation requires appropriate permissions, which are quite limited and, in the case of payments, one-off.

Example: we want to pay for purchases in the online store. From the store’s website (or payment system, e.g. Dotpay) we are redirected to our bank’s website, where after logging in we see information to whom and for which we have to transfer a specific amount of money. We also have information from which account the transfer is to be made (if we have several bank accounts, we can choose from which the transfer should be made). After giving consent, TPP will be able to make only this specific transfer.

From the consumer’s point of view, nothing changes compared to how it currently works. However, the login procedures may change. PSD2 introduces Strong Customer Authentication which is to ensure that we are the owner of the account and we can grant consent. SCA is based on the use of at least two components belonging to the following categories: knowledge (something that only the user knows), possession (something that only the user have) and customer features (something that the user is) independent in the sense that violation of one of them does not weaken the credibility of the others.

Even if the TPP passes the verification procedure successfully, it does not mean that it can do something right away. It is still necessary to carry out a separate verification procedure separately in each bank. And here it is different depending on the bank itself.

This should dispel doubts that PSD2 is just a heist for our money. It is expected to introduce a lot of new opportunities to the fintech industry, e.g. in the field of private banking management. But that doesn’t really mean that people will start losing their money.

From a TPP’s point of view, PSD2 should make integration with bank a lot easier. At least in the assumption. Uniform API, REST, access to the test environment. Unfortunately, the reality is slightly different.

I don’t know how it is in other countries, but in Poland we have PolishAPI. It is a “standard” describing the interface specification for the services provided by third parties based on access to payment accounts. In other words, it describes what the API issued by the Bank for TPP should look like. However, this standard is very loose. It describes the scope of data that is exchanged, but most are not required and will not necessarily be returned by the API. The standard also does not specify the structure of queries and responses, which means that the differences between individual implementations force you to deal with them separately. In terms of authorization, it is based on the OAuth standard, where the generated tokens are directly related to the operation we register and are limited in time. It is also necessary to sign the query with the JWS (Detached) signature using a certificate issued by an authorized issuer, e.g. KIR. Unfortunately, it looks like each test environments deals with it differently. For some sndboxes, a signature should be generated using test certificates provided by the bank, and those that use those issued by KIR interpret them slightly differently. In one of the banks, the organization identifier (OID 2.5.4.97) saved in the certificate (KIR transmits it in the PSDPL-XXXX-XXXXXXXXXX format) must correspond to the name of the user having access to the sandbox (email). Self-signed certificates do not work even though the documentation says otherwise. In addition, for seven implementations I have dealt with, only one is a REST implementation, the others are supposed to be COMMAND, but also far from ideal.

I will skip the issue of reliability of test environments here, but it is also different every time. It seems to me that even if anyone will manage to integrate with a sandbox, they will still have to break through the same problems in production environments. I hope I’m wrong in that matter, but so far we have been fully-integrated with only two banks, and apparently production environments are already available.

PSD2 and its interpretation in the form of PolishAPI is therefore great. For the end-user nothing changes in the way payment beside some additional security features. From the payment service provider point of view, it also doesn’t change much. As before, everyone must integrate with the bank individually solving completely different sets of problems. The only thing that changes is that we have the REST-alike API. But it doesn’t add much at the moment.
