Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id F2EA2280274
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 17:28:04 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id n132so418764736oih.1
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 14:28:04 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0102.outbound.protection.outlook.com. [104.47.41.102])
        by mx.google.com with ESMTPS id z57si13010121otd.29.2016.09.26.14.28.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 26 Sep 2016 14:28:04 -0700 (PDT)
From: Matthew Wilcox <mawilcox@microsoft.com>
Subject: RE: [PATCH 2/2] radix-tree: Fix optimisation problem
Date: Mon, 26 Sep 2016 21:28:00 +0000
Message-ID: <DM2PR21MB00897967DF6E1C0D57DFA9F4CBCD0@DM2PR21MB0089.namprd21.prod.outlook.com>
References: <1474570415-14938-1-git-send-email-mawilcox@linuxonhyperv.com>
 <1474570415-14938-3-git-send-email-mawilcox@linuxonhyperv.com>
 <CALXu0Ucx-6PeEk9nTD-4nZvwyVr9LLXcFGFzhctX-ucKfCygGA@mail.gmail.com>
 <CA+55aFyRG=us-EKnomo=QPE0GR1Qdxyw1Ozmuzw0EJcSr7U3hQ@mail.gmail.com>
 <CALXu0UfuwGM+H0YnfSNW6O=hgcUrmws+ihHLVB=OJWOp8YCwgw@mail.gmail.com>
 <CA+55aFzge97L-JLKZq0CTW1wtMOsnt8QzOw3b5qCMmzbKxZ5aw@mail.gmail.com>
 <CA+55aFxOJTOvxhv+hECHuGV+=xBHMuQitu86J=qBNmMYQ1ACSg@mail.gmail.com>
 <CA+55aFw9=wqyA4xO1KKJoH7xsj6poWFrWTddcNBR5tkDOn8SYg@mail.gmail.com>
In-Reply-To: <CA+55aFw9=wqyA4xO1KKJoH7xsj6poWFrWTddcNBR5tkDOn8SYg@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Cedric Blancher <cedric.blancher@gmail.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@linuxonhyperv.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel
 Mailing List <linux-kernel@vger.kernel.org>

RnJvbTogbGludXM5NzFAZ21haWwuY29tIFttYWlsdG86bGludXM5NzFAZ21haWwuY29tXSBPbiBC
ZWhhbGYgT2YgTGludXMgVG9ydmFsZHMNCj4gT24gU3VuLCBTZXAgMjUsIDIwMTYgYXQgMTI6MDQg
UE0sIExpbnVzIFRvcnZhbGRzDQo+IDx0b3J2YWxkc0BsaW51eC1mb3VuZGF0aW9uLm9yZz4gd3Jv
dGU6DQo+ID4gICAgICAgIEl0IGdldHMgcmlkIG9mDQo+ID4gdGhlIGFkLWhvYyBhcml0aG1ldGlj
IGluIHJhZGl4X3RyZWVfZGVzY2VuZCgpLCBhbmQganVzdCBtYWtlcyBhbGwgdGhhdA0KPiA+IGJl
IGluc2lkZSB0aGUgaXNfc2libGluZ19lbnRyeSgpIGxvZ2ljIGluc3RlYWQuIFdoaWNoIGdvdCBy
ZW5hbWVkIGFuZA0KPiA+IG1hZGUgdG8gYWN0dWFsbHkgcmV0dXJuIHRoZSBtYWluIHNpYmxpbmcu
DQo+IA0KPiBTYWRseSwgaXQgbG9va3MgbGlrZSBnY2MgZ2VuZXJhdGVzIGJhZCBjb2RlIGZvciB0
aGlzIGFwcHJvYWNoLiBMb29rcw0KPiBsaWtlIGl0IGVuZHMgdXAgdGVzdGluZyB0aGUgcmVzdWx0
aW5nIHNpYmxpbmcgcG9pbnRlciB0d2ljZSAoYmVjYXVzZQ0KPiB3ZSBleHBsaWNpdGx5IGRpc2Fi
bGUgLWZuby1kZWxldGUtbnVsbC1wb2ludGVyLWNoZWNrcyBpbiB0aGUga2VybmVsLA0KPiBhbmQg
d2UgaGF2ZSBubyB3YXkgdG8gc2F5ICJsb29rLCBJIGtub3cgdGhpcyBwb2ludGVyIEknbSByZXR1
cm5pbmcgaXMNCj4gbm9uLW51bGwiKS4NCj4gDQo+IFNvIGEgc21hbGxlciBwYXRjaCB0aGF0IGtl
ZXBzIHRoZSBvbGQgYm9vbGVhbiAiaXNfc2libGluZ19lbnRyeSgpIiBidXQNCj4gdGhlbiBhY3R1
YWxseSAqdXNlcyogdGhhdCBpbnNpZGUgcmFkaXhfdHJlZV9kZXNjZW5kKCkgYW5kIHRoZW4gdHJp
ZXMNCj4gdG8gbWFrZSB0aGUgbmFzdHkgY2FzdCB0byAidm9pZCAqKiIgbW9yZSBsZWdpYmxlIGJ5
IG1ha2luZyBpdCB1c2UgYQ0KPiB0ZW1wb3JhcnkgdmFyaWFibGUgc2VlbXMgdG8gYmUgYSByZWFz
b25hYmxlIGJhbGFuY2UuDQo+IA0KPiBBdCBsZWFzdCBJIGZlZWwgbGlrZSBJIGNhbiBzdGlsbCBy
ZWFkIHRoZSBjb2RlLCBidXQgYWRtaXR0ZWRseSBieSBub3cNCj4gdGhhdCBtYXkgYmUgYmVjYXVz
ZSBJJ3ZlIHN0YXJlZCBhdCB0aG9zZSBmZXcgbGluZXMgc28gbXVjaCB0aGF0IEkgZmVlbA0KPiBs
aWtlIEkga25vdyB3aGF0J3MgZ29pbmcgb24uIFNvIG1heWJlIHRoZSBjb2RlIGlzbid0IGFjdHVh
bGx5IGFueSBtb3JlDQo+IGxlZ2libGUgYWZ0ZXIgYWxsLg0KPiANCj4gLi4gYW5kIHVubGlrZSBt
eSBwcmV2aW91cyBwYXRjaCwgaXQgYWN0dWFsbHkgZ2VuZXJhdGVzIGJldHRlciBjb2RlDQo+IHRo
YW4gdGhlIG9yaWdpbmFsICh3aGlsZSBzdGlsbCBwYXNzaW5nIHRoZSBmaXhlZCB0ZXN0LXN1aXRl
LCBvZg0KPiBjb3Vyc2UpLiBUaGUgcmVhc29uIHNlZW1zIHRvIGJlIGV4YWN0bHkgdGhhdCB0ZW1w
b3JhcnkgdmFyaWFibGUsDQo+IGFsbG93aW5nIHVzIHRvIGp1c3QgZG8NCj4gDQo+ICAgICAgICAg
ZW50cnkgPSByY3VfZGVyZWZlcmVuY2VfcmF3KCpzaWJlbnRyeSk7DQo+IA0KPiByYXRoZXIgdGhh
biBkb2luZw0KPiANCj4gICAgICAgICBlbnRyeSA9IHJjdV9kZXJlZmVyZW5jZV9yYXcocGFyZW50
LT5zbG90c1tvZmZzZXRdKTsNCj4gDQo+IHdpdGggdGhlIHJlLWNvbXB1dGVkIG9mZnNldC4NCj4g
DQo+IFNvIEkgdGhpbmsgSSdsbCBjb21taXQgdGhpcyB1bmxlc3Mgc29tZWJvZHkgc2NyZWFtcy4N
Cg0KQWNrZWQtYnk6IE1hdHRoZXcgV2lsY294IDxtYXdpbGNveEBtaWNyb3NvZnQuY29tPg0KDQpJ
IGRvbid0IGxvdmUgaXQuICBCdXQgSSB0aGluayBpdCdzIGEgcmVhc29uYWJsZSBmaXggZm9yIHRo
aXMgcG9pbnQgaW4gdGhlIHJlbGVhc2UgY3ljbGUsIGFuZCBJIGhhdmUgYW4gaWRlYSBmb3IgY2hh
bmdpbmcgdGhlIHJlcHJlc2VudGF0aW9uIG9mIHNpYmxpbmcgc2xvdHMgdGhhdCB3aWxsIG1ha2Ug
dGhpcyBtb290Lg0KDQooQmFzaWNhbGx5IGFkb3B0aW5nIEtvbnN0YW50aW4ncyBpZGVhIGZvciB1
c2luZyB0aGUgKmxhc3QqIGVudHJ5IGluc3RlYWQgb2YgdGhlICpmaXJzdCosIGFuZCB0aGVuIHVz
aW5nIGVudHJpZXMgb2YgdGhlIGZvcm0gKG9mZnNldCA8PCAyIHwgUkFESVhfVFJFRV9JTlRFUk5B
TF9OT0RFKSwgc28gd2UgY2FuIGlkZW50aWZ5IHNpYmxpbmcgZW50cmllcyB3aXRob3V0IGtub3dp
bmcgdGhlIHBhcmVudCBwb2ludGVyLCBhbmQgd2UgY2FuIGdvIHN0cmFpZ2h0IGZyb20gc2libGlu
ZyBlbnRyeSB0byBzbG90IG9mZnNldCBhcyBhIHNoaWZ0IHJhdGhlciB0aGFuIGFzIGEgcG9pbnRl
ciBzdWJ0cmFjdGlvbikuDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
