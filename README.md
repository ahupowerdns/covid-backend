# covid-backend
Backend for privacy preserving corona contact tracing

bert@hubertnet.nl / [@PowerDNS_Bert](https://twitter.com/PowerDNS_Bert) /
[LinkedIn](https://www.linkedin.com/in/bert-hubert-b05452/)

The Dutch government [just launched a
tender](https://www.rijksoverheid.nl/actueel/nieuws/2020/04/11/oproep-om-mee-te-denken-over-apps) for "[digital technologies that can help with
Corona](https://www.tenderned.nl/tenderned-tap/aankondigingen/192421)".  The tender includes words on
privacy sensitive contact tracing, it explicitlty refers to
[PEPP-PT](https://www.pepp-pt.org/), the Pan-European Privacy-Preserving
Proximity Tracing project.

Responses are due on **Tuesday the 14th of April**, 12:00 (noon). The
question/answer form asks if you can do a demo on the 18th of April and have
something that could be rolled out on the 28th. This seems ambitious.

**[I](https://berthub.eu) (with help, see below) intend to submit a proposal
for a backend where apps can query for infected keys, and where any app,
after authorization from a health care professional, can submit infected
keys**.  This backend will feature advanced things like rollback of bad
submissions, health care provider authorization checks, checkpointing,
ability to de-register infected keys, incremental updates, DoS-filtering and
very high scalability and availability.

Documents:

 * [Vooraankondiging](https://www.tenderned.nl/papi/tenderned-rs-tns/publicaties/192421/documenten/5361584/content),
   pre-announcement, in Dutch
 * [Question / Answer form](https://www.tenderned.nl/papi/tenderned-rs-tns/publicaties/192421/documenten/5361580/content),
   in Dutch
 * [Uitnodiging](https://www.tenderned.nl/papi/tenderned-rs-tns/publicaties/192421/documenten/5361581/content),
   invitation letter, in Dutch
 * [Question / Answer form in English](https://www.tenderned.nl/papi/tenderned-rs-tns/publicaties/192421/documenten/5361582/content)
 * [Invitation in  English](https://www.tenderned.nl/papi/tenderned-rs-tns/publicaties/192421/documenten/5361583/content)

The goal is that if I/we focus on a high performance, geo-redundant, secure backend,
people that are "good with apps" can focus on the app part. The API will be
completely open so multiple apps can make use of this platform. All code
will be OPEN SOURCE.

More background is on [the call to action
page](https://berthub.eu/articles/posts/tracing-app-backend/). Also read: 
[Thoughts on Corona contact tracing](https://berthub.eu/articles/posts/tracing-app-thoughts-and-links/).

# Context
Various privacy preserving technologies are being developed, an overview is
[here](https://berthub.eu/articles/posts/tracing-app-thoughts-and-links/).

What all (or at least most) have in common that infections are reported as a
series of small keys. Such keys may be reported directly, or via a trusted
healthcare provider. 

Once a set of keys has been accepted it must be distributed to all users of
the app. There will likely be millions and millions of app users. There will
also be hundreds of thousand infected keys in the system.

Each key is also associated with a date. Old keys should no longer be shared
as they are of no further relevance given the incubation time of COVID-19.

The upshot is that all apps must initially download a large set of relevant
keys, and from them on must receive incremental updates.

> Note: most of the logic happens in the apps. The various protocols
> ([DP-3T](https://github.com/DP-3T/documents) or
> [Apple/Google](https://covid19-static.cdn-apple.com/applications/covid19/current/static/contact-tracing/pdf/ContactTracing-CryptographySpecification.pdf)) make sure
> only the most relevant data is uploaded. This project attempts to be the
> place where that data gets uploaded. So this project services the privacy
> preserving protocols.

# Key requirements
This will be serious public health infrastructure. It needs to be always on,
it needs to not go down, not send out bad data, and be able to recover from
malicious attacks. It needs to deal with lost keys, confused overworked
healthcare providers, erroneous data etc.

 * Privacy. Data minimization. Anything we don't need we should not have.
   Things that we do need we should have, even at the cost of some privacy.
   This might include storing IP address of a report briefly to combat
   fraud/spam/attacks. Almost nothing we can do about that.
 * Security. This is of the utmost importance. No privacy without security,
   no availability if we are hacked. Prefer to be secure over being
   available. But we try to be always on!
 * Always on in read mode: it is ok if the app can't update briefly, but we
   would definitely like to avoid that.  When we launch, 100s of thousands
   of users will arrive very quickly, we want to give them a good
   experience! 
 * Always on in write-mode: if a healthcare provider and/or user want to
   report an infection, this should ALWAYS WORK and once reported and
   confirmed, the data should be DURABLE. It should not ever fail to be
   stored.
 * Recoverable: we live in crazy times. We are in a hurry. Mistakes will be
   made. The system should always be recoverable from scratch based on a log of
   all incoming events. This should be a "5 minute operation". 
 * Flexible: again, because we live in crazy times, bad reports will be
   made, accidental reports will need to be removed. We should have tooling
   to fix whatever things have gone wrong.
 * Redundant - a proper reduntant architecture with multiple downstreams
   makes migrations and upgrades easy. And downgrades.

# Healthcare provider interface
It seems that the best reports of infection status will come only when
authorized by healthcare providers.

This means that users can not directly report themselves, they will need
some kind of authorization for that from their doctor or hospital. 

To do so requires infrastructure that can be delivered at very high speed to
doctors and labs. This may be as simple as a stack of paper with big numbers
on them, every piece of paper is good for reporting one patient. 

So what happens is that patient gets a test, test is positive, healthcare
provider gives piece of paper to the patient. Patient goes to app, pushes
the "I am infected button". App asks for the number, patient enters it. Our
backend now confirms receipt, and invalidates that code. 

Patient discards the now useless piece of paper.

Every set of numbers is tied to a specific healthcare provider. If they lose
track of their stack of papers, we can invalidate their numbers, either
prospectively ('no more reports') or even retroactively if we know all their
reports have been bogus.

Healthcare providers we know and have an authorization can print numbers
themselves, or request individual numbers on a website. 

# Hosting requirements
We will not only need to build the software, we should offer the hosting as
well.

This requires:

 * Superior DoS filtering: because we live in bad times
 * Non-cloud hosting within the jurisdiction of the healthcare system. In
   practice for us this will mean 'In the EU' or 'In The Netherlands',
   likely on servers that someone actually owns. 
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

# Very tentative design ideas
## Submission
Reporting a infection is a simple POST to a very redundant server that logs
the post as durably as possible. A POST might not be accepted because it has
no valid matching healthcare provider token, so we can't just log POSTs and
hope for the best. Some interaction is required it appears. 

If we could be somewhat asynchronous we could log POSTS without interaction
and have a 100% up collector. Very tempting. This would require the app to
ask back to see if the report was accepted. Might be worth it. We could
provide a tracking ID in response to a POST.

## Polling
It would be SUPER ACE if we could put the data files on a CDN and not have
to worry about them anymore. The initial data file would be quite large, and
you'd have to apply delta-sets to them.

There is no need to do realtime transmission of updates, it is acceptable to
have some delay. Perhaps delta files per 15 minutes? And always also
generate a full dump so 'dumb apps' could use that instead?

File need built-in integrity check so we know we got a full file correctly. 

Note that delta-sets also include deletion events, either because the key is
no longer relevant (post 14 days) or because we corrected a mistake.
