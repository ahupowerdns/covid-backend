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

### Another alternative

We can generate 16 random bytes and use this as random authentication code.

We can format this output as 6 numbers of 6 digits in length.

This gives us an field of 10^36 which translates to an entropy of 
ln(10)/ln(2) which is about 119 bits which puts us in the realm of the
complexity of 3DES.

Scanning a QR-code is easiest, but the healthcare worker can also read out
these numbers over the phone.

So we would display:

"qr code"

Code 1: 943 702
Code 2: 897 561
Code 3: 983 450
Code 4: 965 072
Code 5: 156 304
Code 6: 394 580

If we do this, we do not have to compromise on security and have no 
problems with fonts.
