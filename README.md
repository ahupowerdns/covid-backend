# covid-backend
Backend for privacy preserving corona contact tracing

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
page](https://berthub.eu/articles/posts/tracing-app-backend/). Thoughts on
[Corona contact
tracing](https://berthub.eu/articles/posts/tracing-app-thoughts-and-links/).

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

# Key requirements
TBC

