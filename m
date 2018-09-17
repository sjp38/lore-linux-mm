Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B0AF18E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 14:43:06 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id s1-v6so8800576pfm.22
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 11:43:06 -0700 (PDT)
Received: from g4t3425.houston.hpe.com (g4t3425.houston.hpe.com. [15.241.140.78])
        by mx.google.com with ESMTPS id f67-v6si16380190pfa.73.2018.09.17.11.43.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Sep 2018 11:43:05 -0700 (PDT)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH 3/5] x86: pgtable: Drop pXd_none() checks from
 pXd_free_pYd_table()
Date: Mon, 17 Sep 2018 18:43:02 +0000
Message-ID: <62056eebf0627d9aeaa1e208f77e660977e158af.camel@hpe.com>
References: <1536747974-25875-1-git-send-email-will.deacon@arm.com>
	 <1536747974-25875-4-git-send-email-will.deacon@arm.com>
	 <dc8b03de1e3318e3dd577d80482260f99ab4e9a5.camel@hpe.com>
	 <20180917113321.GB22717@arm.com>
In-Reply-To: <20180917113321.GB22717@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <645DCF0DA2CC8A46ADF9017624263C3B@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "will.deacon@arm.com" <will.deacon@arm.com>
Cc: "tglx@linutronix.de" <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "Hocko, Michal" <MHocko@suse.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

T24gTW9uLCAyMDE4LTA5LTE3IGF0IDEyOjMzICswMTAwLCBXaWxsIERlYWNvbiB3cm90ZToNCj4g
T24gRnJpLCBTZXAgMTQsIDIwMTggYXQgMDg6Mzc6NDhQTSArMDAwMCwgS2FuaSwgVG9zaGkgd3Jv
dGU6DQo+ID4gT24gV2VkLCAyMDE4LTA5LTEyIGF0IDExOjI2ICswMTAwLCBXaWxsIERlYWNvbiB3
cm90ZToNCj4gPiA+IE5vdyB0aGF0IHRoZSBjb3JlIGNvZGUgY2hlY2tzIHRoaXMgZm9yIHVzLCB3
ZSBkb24ndCBuZWVkIHRvIGRvIGl0IGluIHRoZQ0KPiA+ID4gYmFja2VuZC4NCj4gPiA+IA0KPiA+
ID4gQ2M6IENoaW50YW4gUGFuZHlhIDxjcGFuZHlhQGNvZGVhdXJvcmEub3JnPg0KPiA+ID4gQ2M6
IFRvc2hpIEthbmkgPHRvc2hpLmthbmlAaHBlLmNvbT4NCj4gPiA+IENjOiBUaG9tYXMgR2xlaXhu
ZXIgPHRnbHhAbGludXRyb25peC5kZT4NCj4gPiA+IENjOiBNaWNoYWwgSG9ja28gPG1ob2Nrb0Bz
dXNlLmNvbT4NCj4gPiA+IENjOiBBbmRyZXcgTW9ydG9uIDxha3BtQGxpbnV4LWZvdW5kYXRpb24u
b3JnPg0KPiA+ID4gU2lnbmVkLW9mZi1ieTogV2lsbCBEZWFjb24gPHdpbGwuZGVhY29uQGFybS5j
b20+DQo+ID4gPiAtLS0NCj4gPiA+ICBhcmNoL3g4Ni9tbS9wZ3RhYmxlLmMgfCA2IC0tLS0tLQ0K
PiA+ID4gIDEgZmlsZSBjaGFuZ2VkLCA2IGRlbGV0aW9ucygtKQ0KPiA+ID4gDQo+ID4gPiBkaWZm
IC0tZ2l0IGEvYXJjaC94ODYvbW0vcGd0YWJsZS5jIGIvYXJjaC94ODYvbW0vcGd0YWJsZS5jDQo+
ID4gPiBpbmRleCBhZTM5NDU1MmZiOTQuLmI0OTE5YzQ0YTE5NCAxMDA2NDQNCj4gPiA+IC0tLSBh
L2FyY2gveDg2L21tL3BndGFibGUuYw0KPiA+ID4gKysrIGIvYXJjaC94ODYvbW0vcGd0YWJsZS5j
DQo+ID4gPiBAQCAtNzk2LDkgKzc5Niw2IEBAIGludCBwdWRfZnJlZV9wbWRfcGFnZShwdWRfdCAq
cHVkLCB1bnNpZ25lZCBsb25nIGFkZHIpDQo+ID4gPiAgCXB0ZV90ICpwdGU7DQo+ID4gPiAgCWlu
dCBpOw0KPiA+ID4gIA0KPiA+ID4gLQlpZiAocHVkX25vbmUoKnB1ZCkpDQo+ID4gPiAtCQlyZXR1
cm4gMTsNCj4gPiA+IC0NCj4gPiANCj4gPiBEbyB3ZSBuZWVkIHRvIHJlbW92ZSB0aGlzIHNhZmUg
Z3VhcmQ/ICBJIGZlZWwgbGlzdCB0aGlzIGlzIHNhbWUgYXMNCj4gPiBrZnJlZSgpIGFjY2VwdGlu
ZyBOVUxMLg0KPiANCj4gSSB0aGluayB0d28gYmlnIGRpZmZlcmVuY2VzIHdpdGgga2ZyZWUoKSBh
cmUgKDEpIHRoYXQgdGhpcyBmdW5jdGlvbiBoYXMNCj4gZXhhY3RseSBvbmUgY2FsbGVyIGluIHRo
ZSB0cmVlIGFuZCAoMikgaXQncyBpbXBsZW1lbnRlZCBwZXItYXJjaC4gVGhlcmVmb3JlDQo+IHdl
J3JlIGluIGEgZ29vZCBwb3NpdGlvbiB0byBnaXZlIGl0IHNvbWUgc2ltcGxlIHNlbWFudGljcyBh
bmQgaW1wbGVtZW50DQo+IHRob3NlLiBPZiBjb3Vyc2UsIGlmIHRoZSB4ODYgcGVvcGxlIHdvdWxk
IGxpa2UgdG8ga2VlcCB0aGUgcmVkdW5kYW50IGNoZWNrLA0KPiB0aGF0J3MgdXAgdG8gdGhlbSwg
YnV0IEkgdGhpbmsgaXQgbWFrZXMgdGhlIGZ1bmN0aW9uIG1vcmUgY29uZnVzaW5nIGFuZA0KPiB0
ZW1wdHMgcGVvcGxlIGludG8gY2FsbGluZyBpdCBmb3IgcHJlc2VudCBlbnRyaWVzLg0KDQpXaXRo
IHBhdGNoIDEvNSBjaGFuZ2UgdG8gaGF2ZSBwWGRfcHJlc2VudCgpIGNoZWNrLCBJIGFncmVlIHRo
YXQgd2UgY2FuDQpyZW1vdmUgdGhpcyBwWGRfbm9uZSgpIGNoZWNrIHRvIGF2b2lkIGFueSBjb25m
dXNpb24uDQoNClJldmlld2VkLWJ5OiBUb3NoaSBLYW5pIDx0b3NoaS5rYW5pQGhwZS5jb20+DQoN
ClRoYW5rcywNCi1Ub3NoaQ0KDQo=
