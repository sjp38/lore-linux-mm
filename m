Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D18248D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 15:02:53 -0500 (EST)
Received: by yxt33 with SMTP id 33so1151780yxt.14
        for <linux-mm@kvack.org>; Fri, 04 Mar 2011 12:02:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1299262495.3062.298.camel@calx>
References: <1299174652.2071.12.camel@dan>
	<1299185882.3062.233.camel@calx>
	<1299186986.2071.90.camel@dan>
	<1299188667.3062.259.camel@calx>
	<1299191400.2071.203.camel@dan>
	<2DD7330B-2FED-4E58-A76D-93794A877A00@mit.edu>
	<AANLkTimpfk8EHjVKYsJv0p_G7tS2yB-n=PPbD2v7xefV@mail.gmail.com>
	<1299260164.8493.4071.camel@nimitz>
	<AANLkTim+XcYiiM9u8nT659FHaZO1RPDEtyAgFtiA8VOk@mail.gmail.com>
	<1299262495.3062.298.camel@calx>
Date: Fri, 4 Mar 2011 22:02:51 +0200
Message-ID: <AANLkTimRN_=APe_PWMFe_6CHHC7psUbCYE-O0qc=mmYY@mail.gmail.com>
Subject: Re: [PATCH] Make /proc/slabinfo 0400
From: Pekka Enberg <penberg@kernel.org>
Content-Type: multipart/mixed; boundary=001636ed72fe870acc049dada1f6
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Theodore Tso <tytso@mit.edu>, Dan Rosenberg <drosenberg@vsecurity.com>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>

--001636ed72fe870acc049dada1f6
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Mar 4, 2011 at 8:14 PM, Matt Mackall <mpm@selenic.com> wrote:
>> Of course, as you say, '/proc/meminfo' still does give you the trigger
>> for "oh, now somebody actually allocated a new page". That's totally
>> independent of slabinfo, though (and knowing the number of active
>> slabs would neither help nor hurt somebody who uses meminfo - you
>> might as well allocate new sockets in a loop, and use _only_ meminfo
>> to see when that allocated a new page).
>
> I think lying to the user is much worse than changing the permissions.
> The cost of the resulting confusion is WAY higher.

Yeah, maybe. I've attached a proof of concept patch that attempts to
randomize object layout in individual slabs. I'm don't completely
understand the attack vector so I don't make any claims if the patch
helps or not.

                        Pekka

--001636ed72fe870acc049dada1f6
Content-Type: text/x-patch; charset=US-ASCII; name="slub-randomize.patch"
Content-Disposition: attachment; filename="slub-randomize.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gkvj6bsl0

RnJvbSBjZDFlMjBmYjhlYjQ0NjI3ZmE1Y2NlYmM4YTI4MDNjMWZkN2JmN2JhIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBQZWtrYSBFbmJlcmcgPHBlbmJlcmdAa2VybmVsLm9yZz4KRGF0
ZTogRnJpLCA0IE1hciAyMDExIDIxOjI4OjU2ICswMjAwClN1YmplY3Q6IFtQQVRDSF0gU0xVQjog
UmFuZG9taXplIG9iamVjdCBsYXlvdXQgaW4gc2xhYnMKClNpZ25lZC1vZmYtYnk6IFBla2thIEVu
YmVyZyA8cGVuYmVyZ0BrZXJuZWwub3JnPgotLS0KIG1tL3NsdWIuYyB8ICAgNDUgKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrCiAxIGZpbGVzIGNoYW5nZWQsIDQ1
IGluc2VydGlvbnMoKyksIDAgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvbW0vc2x1Yi5jIGIv
bW0vc2x1Yi5jCmluZGV4IGUxNWFhN2YuLjE4MzdmZTMgMTAwNjQ0Ci0tLSBhL21tL3NsdWIuYwor
KysgYi9tbS9zbHViLmMKQEAgLTI3LDYgKzI3LDcgQEAKICNpbmNsdWRlIDxsaW51eC9tZW1vcnku
aD4KICNpbmNsdWRlIDxsaW51eC9tYXRoNjQuaD4KICNpbmNsdWRlIDxsaW51eC9mYXVsdC1pbmpl
Y3QuaD4KKyNpbmNsdWRlIDxsaW51eC9yYW5kb20uaD4KIAogI2luY2x1ZGUgPHRyYWNlL2V2ZW50
cy9rbWVtLmg+CiAKQEAgLTExODMsNiArMTE4NCw0NiBAQCBzdGF0aWMgdm9pZCBzZXR1cF9vYmpl
Y3Qoc3RydWN0IGttZW1fY2FjaGUgKnMsIHN0cnVjdCBwYWdlICpwYWdlLAogCQlzLT5jdG9yKG9i
amVjdCk7CiB9CiAKK3N0YXRpYyBib29sIHNldHVwX3NsYWJfcmFuZG9taXplZChzdHJ1Y3Qga21l
bV9jYWNoZSAqcywgc3RydWN0IHBhZ2UgKnBhZ2UsIGdmcF90IGZsYWdzKQoreworCXVuc2lnbmVk
IGxvbmcgYml0bWFwWzhdOworCXNpemVfdCBiaXRtYXBfc2l6ZTsKKwl2b2lkICpsYXN0LCAqc3Rh
cnQ7CisKKwliaXRtYXBfc2l6ZSA9IEJJVFNfVE9fTE9OR1MocGFnZS0+b2JqZWN0cykgKiBzaXpl
b2YodW5zaWduZWQgbG9uZyk7CisKKwlpZiAoQVJSQVlfU0laRShiaXRtYXApICogc2l6ZW9mKHVu
c2lnbmVkIGxvbmcpIDwgYml0bWFwX3NpemUpCisJCXJldHVybiBmYWxzZTsKKworCWJpdG1hcF9m
aWxsKGJpdG1hcCwgcGFnZS0+b2JqZWN0cyk7CisKKwlzdGFydCA9IHBhZ2VfYWRkcmVzcyhwYWdl
KTsKKworCWxhc3QgPSBzdGFydDsKKwl3aGlsZSAoIWJpdG1hcF9lbXB0eShiaXRtYXAsIHBhZ2Ut
Pm9iamVjdHMpKSB7CisJCXVuc2lnbmVkIGxvbmcgaWR4OworCQl2b2lkICpwOworCisJCWlkeAk9
IGdldF9yYW5kb21faW50KCkgJSBwYWdlLT5vYmplY3RzOworCisJCWlkeAk9IGZpbmRfbmV4dF9i
aXQoYml0bWFwLCBwYWdlLT5vYmplY3RzLCBpZHgpOworCisJCWlmIChpZHggPj0gcGFnZS0+b2Jq
ZWN0cykKKwkJCWNvbnRpbnVlOworCisJCWNsZWFyX2JpdChpZHgsIGJpdG1hcCk7CisKKwkJcCA9
IHN0YXJ0ICsgaWR4ICogcy0+c2l6ZTsKKwkJc2V0dXBfb2JqZWN0KHMsIHBhZ2UsIGxhc3QpOwor
CQlzZXRfZnJlZXBvaW50ZXIocywgbGFzdCwgcCk7CisJCWxhc3QgPSBwOworCX0KKwlzZXR1cF9v
YmplY3QocywgcGFnZSwgbGFzdCk7CisJc2V0X2ZyZWVwb2ludGVyKHMsIGxhc3QsIE5VTEwpOwor
CisJcmV0dXJuIHRydWU7Cit9CisKIHN0YXRpYyBzdHJ1Y3QgcGFnZSAqbmV3X3NsYWIoc3RydWN0
IGttZW1fY2FjaGUgKnMsIGdmcF90IGZsYWdzLCBpbnQgbm9kZSkKIHsKIAlzdHJ1Y3QgcGFnZSAq
cGFnZTsKQEAgLTEyMDYsNiArMTI0Nyw5IEBAIHN0YXRpYyBzdHJ1Y3QgcGFnZSAqbmV3X3NsYWIo
c3RydWN0IGttZW1fY2FjaGUgKnMsIGdmcF90IGZsYWdzLCBpbnQgbm9kZSkKIAlpZiAodW5saWtl
bHkocy0+ZmxhZ3MgJiBTTEFCX1BPSVNPTikpCiAJCW1lbXNldChzdGFydCwgUE9JU09OX0lOVVNF
LCBQQUdFX1NJWkUgPDwgY29tcG91bmRfb3JkZXIocGFnZSkpOwogCisJaWYgKHNldHVwX3NsYWJf
cmFuZG9taXplZChzLCBwYWdlLCBmbGFncykpCisJCWdvdG8gZG9uZTsgCisKIAlsYXN0ID0gc3Rh
cnQ7CiAJZm9yX2VhY2hfb2JqZWN0KHAsIHMsIHN0YXJ0LCBwYWdlLT5vYmplY3RzKSB7CiAJCXNl
dHVwX29iamVjdChzLCBwYWdlLCBsYXN0KTsKQEAgLTEyMTUsNiArMTI1OSw3IEBAIHN0YXRpYyBz
dHJ1Y3QgcGFnZSAqbmV3X3NsYWIoc3RydWN0IGttZW1fY2FjaGUgKnMsIGdmcF90IGZsYWdzLCBp
bnQgbm9kZSkKIAlzZXR1cF9vYmplY3QocywgcGFnZSwgbGFzdCk7CiAJc2V0X2ZyZWVwb2ludGVy
KHMsIGxhc3QsIE5VTEwpOwogCitkb25lOgogCXBhZ2UtPmZyZWVsaXN0ID0gc3RhcnQ7CiAJcGFn
ZS0+aW51c2UgPSAwOwogb3V0OgotLSAKMS43LjAuNAoK
--001636ed72fe870acc049dada1f6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
