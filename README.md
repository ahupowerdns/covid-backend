# covid-backend
A backend for privacy preserving corona contact tracing

bert@hubertnet.nl / [@PowerDNS_Bert](https://twitter.com/PowerDNS_Bert) /
[LinkedIn](https://www.linkedin.com/in/bert-hubert-b05452/)

The Dutch government [just launched a
tender](https://www.rijksoverheid.nl/actueel/nieuws/2020/04/11/oproep-om-mee-te-denken-over-apps) for "[digital technologies that can help with
Corona](https://www.tenderned.nl/tenderned-tap/aankondigingen/192421)".  The tender includes words on
privacy sensitive contact tracing, it explicitly refers to
[PEPP-PT](https://www.pepp-pt.org/), the Pan-European Privacy-Preserving
Proximity Tracing project.

Responses are due on **Tuesday the 14th of April**, 12:00 (noon). The
question/answer form asks if you can do a demo on the 18th of April and have
something that could be rolled out on the 28th. This seems ambitious.

**[I](https://berthub.eu) (with help, see below) intend to submit a proposal
for a backend that apps can query for infected keys, and where any such app,
after authorization from a health care professional, can submit infected
keys to**. 

This backend will include advanced functionality, including but not limited to:
* health care provider authorization checks;
* rollback of bad submissions;
* ability to de-register infected keys.

Additionally, it also aims to provide a high degree of integrity, availability and scalability by applying:
* checkpointing;
* incremental updates;
* DoS-filtering.

Reference documents:

 * [Vooraankondiging](https://www.tenderned.nl/papi/tenderned-rs-tns/publicaties/192421/documenten/5361584/content),
   pre-announcement, in Dutch
 * [Question / Answer form](https://www.tenderned.nl/papi/tenderned-rs-tns/publicaties/192421/documenten/5361580/content),
   in Dutch
 * [Uitnodiging](https://www.tenderned.nl/papi/tenderned-rs-tns/publicaties/192421/documenten/5361581/content),
   invitation letter, in Dutch
 * [Question / Answer form in English](https://www.tenderned.nl/papi/tenderned-rs-tns/publicaties/192421/documenten/5361582/content)
 * [Invitation in  English](https://www.tenderned.nl/papi/tenderned-rs-tns/publicaties/192421/documenten/5361583/content)

The asssumption is that if we focus on a high performance, geo-redundant, secure backend,
people that are "good with apps" can focus on the app part. The API will be
completely open so multiple apps can use this platform. The project will be completely
open source, which invites inspection, participation and continuous and transparant improvement.

More background is on [the call to action
page](https://berthub.eu/articles/posts/tracing-app-backend/). Also read: 
[Thoughts on Corona contact tracing](https://berthub.eu/articles/posts/tracing-app-thoughts-and-links/).

# Context
Various privacy preserving technologies are being developed, an overview is
[here](https://berthub.eu/articles/posts/tracing-app-thoughts-and-links/).

How this could work in practice is as follows:
1. Health care authorities are granted a set of signing keys that can be used for signing (more on this below), in practice this could be implemented by them communicating an activation number to the patient.
2. Each user's device generates an initial random secret key on the first day and on each subsequent day generates a new secret key with a relation to the previous one (thus creating a chain of secret keys).
3. This secret key serves as an input to generate a large set of identification numbers. These numbers are emitted by the user's device during the day. They can also be recomputed based on the secret key (of that day, and given the initial secret key: on all days, or effictively anything in between day 1 and today).
4. When a user is infected they can do two things (a) they should report the secret key of the first day when they were infectious to the back-end application and (b) they can have their key signed by a healthcare authority. If they do both: it carries weight as it is a trusted/verified infection, if they perform only the first step it can be treated as a self-reported infection instead.
5. Once a secret key has been reported, it should be redistributed to all devices of all users that can use the key to regenerate to secret key for each day as well as the identification numbers for each day. This information can be used to figure out whether they have been close to the infected person. The secret key should come along with an expiry period that respect both the incubation and healing time of COVID-19 with some safety margin.
6. Expired keys can be removed by devices and no longer emitted by the back-end. The upshot is that the initial download of keys will be large, but updates to this are incremental, and thus smaller.

The expectation is that the app will have millions of users and that there will be hundreds of thousands of keys of infected users in the system.

> Note: most of the logic happens in the apps. The various protocols
> ([DP-3T](https://github.com/DP-3T/documents) with a detailed [whitepaper](https://github.com/DP-3T/documents/blob/master/DP3T%20White%20Paper.pdf) or
> [Apple/Google](https://covid19-static.cdn-apple.com/applications/covid19/current/static/contact-tracing/pdf/ContactTracing-CryptographySpecification.pdf)) make sure
> only the most relevant data is uploaded. This project attempts to be the
> place where that data gets uploaded. So this project services the privacy
> preserving protocols.

# Functional requirements

COMMENT: I am missing these ...

# Key non-functional requirements
This will be serious public health infrastructure.

 * Privacy. Data minimization. Anything we don't need we should not have.
   Things that we do need we should have, even at the cost of some privacy.
   This might include storing IP address of a report briefly to combat
   fraud/spam/attacks. Almost nothing we can do about that.
 * Security. This is of the utmost importance. No privacy without security,
   no availability if we are hacked. Prefer to be secure over being
   available. But we try to be always on! COMMENT: Describe potential hacks/risks, what potential hacks do you see?
 * Always on in read mode: it is ok if the app can't update briefly, but we
   would definitely like to avoid that. When we launch, 100s of thousands
   of users will arrive very quickly, we want to give them a good
   experience! --> COMMENT: An excellent solution may be a torrent-like protocol (e.g. protocols underlying Tribler), a more down practical one is to simply to leave this up to storage providers (dump it to a bucket).
 * Always on in write-mode: if a healthcare provider and/or user want to
   report an infection, this should ALWAYS WORK and once reported and
   confirmed, the data should be DURABLE. It should not ever fail to be
   stored --> COMMENT: this requirement can bite performance as well, I think it is more realistic to say something like: an infection should be transmitted and stored in say three minutes at most. This allows for retries, which realistically: will happen in a system of this scale.
 * Recoverable: we live in crazy times. We are in a hurry. Mistakes will be
   made. The system should always be recoverable from scratch based on a log of
   all incoming events. This should be a "5 minute operation" --> COMMENT: seems a bit optimistic, but I think this can be done using transaction logs that can be replayed from the start. Something akin to Delta Lake is a good technology to use for this (for on disk), but in practice the idea can be implemented in a simple No(SQL) database provided it is distributed/scaled enough to handle read/write load.
 * Flexible: again, because we live in crazy times, bad reports will be
   made, accidental reports will need to be removed. We should have tooling
   to fix whatever things have gone wrong --> COMMENT: Your transaction log can handle all these cases, but the API should expose proper calls for this (a simple REST-like API with a DELETE call can be sufficient client side).
 * Redundant - a proper redundant architecture with multiple downstreams
   makes migrations and upgrades easy. And downgrades --> COMMENT: Can you elaborate?

In summary:
* High availability: It needs to be always on, it needs to not go down
* High reliability: not send out bad data, and be able to recover from malicious attacks.
* High recovery: It needs to deal with lost keys, confused overworked healthcare providers, erroneous data etc.

# Healthcare provider / point of care interface
It seems that the best reports of infection status will come only when authorized by healthcare providers.

This means that users can not directly report themselves, they will need some kind of authorization for that from their doctor or hospital OR we assign different levels of trust to different types of reports (self reported, versus signed).

To do so requires infrastructure that can be delivered at very high speed to doctors and labs. This may be as simple as a stack of paper with big numbers on them, every piece of paper is good for reporting one patient. 

So what happens is that patient gets a test, test is positive, healthcare provider gives piece of paper to the patient. Patient goes to app, pushes the "I am infected button". App asks for the number, patient enters it. This signs their key and reports it to the backend. Our backend now confirms receipt, and invalidates that code. Patient discards the now useless piece of paper.

Every set of numbers is tied to a specific healthcare provider. If they lose track of their stack of papers, we can invalidate their numbers, either prospectively ('no more reports') or even retroactively if we know all their reports have been bogus. This is an effective way to implement key signing.

Healthcare providers we know and have an authorization can print numbers themselves, or request individual numbers on a website. 

More information about point of care logistics are [here](point-of-care.md).

# Hosting requirements
We will not only need to build the software, we should offer the hosting as well.

This requires:

 * Superior DoS filtering: because we live in bad times --> COMMENT: Can be handled by existing DoS protection solutions.
 * Non-cloud hosting within the jurisdiction of the healthcare system. In
   practice for us this will mean 'In the EU' or 'In The Netherlands',
   likely on servers that someone actually owns. --> COMMENT: This should be fairly easy to find.
 * 24/7 support
 * Likely hosting with relevant certifications for security, possibly
   healthcare data.


# Inspiration

 * https://apenwarr.ca/log/20190216 - "The log/event processing pipeline you can't
   have", an extremly robust design for collecting data. Also used by the
   [galmon.eu](https://galmon.eu) project.
 * [Golomb Coded Sets](https://giovanni.bajo.it/post/47119962313/golomb-coded-sets-smaller-than-bloom-filters)
   are a way to compress many numbers that are geometrically distributed - like cryptographic keys. It may even 
   be possible to use compressed sets with only partial hashes, and a confirmation API in case of a hit.
 * An interesting way to store geographic (location) data may be to use Rabin-Karp fingerprinting based on a GeoHash, probably more relevant to the front-end, not back-end.

# Very tentative design ideas
## Submission
Reporting a infection is a simple POST to a very redundant server that logs
the post as durably as possible. A POST might not be accepted because it has
no valid matching healthcare provider token, so we can't just log POSTs and
hope for the best. Some interaction is required it appears. --> COMMENT: Yes, it's still client/server for reporting, so clients also need to handle proper error handling and submission retry mechanisms. Logging is needed so we can monitor the rate of succeeding and failing back-end transmissions (and intervene and recover). It may be advisable to run multiple API deployments that use another mechanism to synchronize their back-end submissions to avoid a single point of failure.

If we could be somewhat asynchronous we could log POSTS without interaction
and have a 100% up collector. Very tempting. This would require the app to
ask back to see if the report was accepted. Might be worth it. We could
provide a tracking ID in response to a POST --> COMMENT: Yes, that may work well with the multiple endpoints/syncing ID above.

## Polling
It would be SUPER ACE if we could put the data files on a CDN and not have
to worry about them anymore. The initial data file would be quite large, and
you'd have to apply delta-sets to them -> COMMENT: As suggested, the back-end could write out it's stuff to a bucket in Delta Lake format, which clients can read from. This bucket could be replicated. This is probably the easiest mechanism for distribution to clients (read: apps) I can think of.

There is no need to do realtime transmission of updates, it is acceptable to have some delay. Perhaps delta files per 15 minutes? And always also generate a full dump so 'dumb apps' could use that instead? --> COMMENT: I'd go the dumb route only when necessary, the more there's one 'ticket booth' so to speak, the better that generally is.

File need built-in integrity check so we know we got a full file correctly --> COMMENT: Delta Lake, otherwise: CRC/Adler/MD5/MurmurHash (any non-cryptographic hash) or something like that over the data files.

Note that delta-sets also include deletion events, either because the key is no longer relevant (post 14 days) or because we corrected a mistake --> COMMENT: Yes, this is a standard part of any transaction log :)

COMMENT: An alternative to file-based distribution and syncing is a publish/subscribe system, but I am not sure if that will hold up with so many clients. A simple approach is to have numbered messages and replay capability so each client can synchronize to the last received number. Again: I am not sure if it could scale, but it could be an additional service built on top. This does not have to be real-time either, but could push out messages every 15m, similar to the file-based solution.

