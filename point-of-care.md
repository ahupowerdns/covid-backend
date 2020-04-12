# Point of care
Some practicalities - we are assuming any report of infection will have to
be confirmed by a healthcare worker, otherwise we'll get lots of hoax
reports.

Given the crisis we are in, we need something that is extremely simple and
robust. We also have to assume that the patient is not feeling well, so we
can't do complicated things. 

Only the app can send an 'infected' notification. This means the app will
need to be supplied with a public health authorization. This should be a
token that can be handed out by a lab/doctor/assistant.

Such a token means "this is a single use authorization to report a COVID-19
infection".

Authorized parties could stock up on such tokens to hand out with test
results.

## Sample workflow
We distribute tokens to all points-of-care that should have them. These are
PDF files they can print themselves and cut up into cards to hand out.

With the distribution, we also provide a workflow how to gain access to more
tokens.

If possible, we should try to make this happen from something all points of
care have access to already. For The Netherlands this may be the 'UZI Pas'
or something else.

## Practicalities
Such tokens may have a limited lifetime. For example, if a lab loses 10000
tokens, all kinds of bad things might happen. But after two days, the
problem is over, since the tokens will have expired.

On the other hand, this would be bad from a logistics perspective.

## Online reporting
If we had more time, point of care would submit the infected status
synchronously, using a tool that only works when signed in. But in the short
term this may not be practicable.

## Healthcare assisted reporting
One other way to do it is that the when diagnosed, the healthcare provider
does the report. This takes time. If the HCP does so using the patients
phone, nothing else is required. Simply take the phone, enter the token,
press submit.

If this is not feasible, for example because there is no physical contact,
the HCP could instruct the patient how to submit data over the phone.

The worry is that the patient might not report, I am unsure how to enforce
this.

## QR Code
Given that the authorization key will look something like this:

E0C1 8306 0C18 3060 C183 060C 1830 60C1

It may be tempting to add a QR code to the token. If we relax our security
requirements a bit, the code may look like this:

0012 E0C1 8306 0C18 3060

If we do this, we need a font where the 0 and the O are really different, or
maybe underline the digits.



