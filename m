Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id DDE2A8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 17:10:52 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id l14-v6so10984647oii.9
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 14:10:52 -0700 (PDT)
Received: from g4t3425.houston.hpe.com (g4t3425.houston.hpe.com. [15.241.140.78])
        by mx.google.com with ESMTPS id h6-v6si4283702oib.203.2018.09.14.14.10.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 14:10:51 -0700 (PDT)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH 1/5] ioremap: Rework pXd_free_pYd_page() API
Date: Fri, 14 Sep 2018 21:10:49 +0000
Message-ID: <db3f513bf3bfafb85b99f57f741f5bb07952af70.camel@hpe.com>
References: <1536747974-25875-1-git-send-email-will.deacon@arm.com>
	 <1536747974-25875-2-git-send-email-will.deacon@arm.com>
	 <71baefb8e0838fba89ee06262bbb2456e9091c7a.camel@hpe.com>
In-Reply-To: <71baefb8e0838fba89ee06262bbb2456e9091c7a.camel@hpe.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <6BBA5E9960E2D24F94F5733855EE94A0@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "will.deacon@arm.com" <will.deacon@arm.com>
Cc: "tglx@linutronix.de" <tglx@linutronix.de>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "Hocko, Michal" <MHocko@suse.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

T24gRnJpLCAyMDE4LTA5LTE0IGF0IDE0OjM2IC0wNjAwLCBUb3NoaSBLYW5pIHdyb3RlOg0KPiBP
biBXZWQsIDIwMTgtMDktMTIgYXQgMTE6MjYgKzAxMDAsIFdpbGwgRGVhY29uIHdyb3RlOg0KPiA+
IFRoZSByZWNlbnRseSBtZXJnZWQgQVBJIGZvciBlbnN1cmluZyBicmVhay1iZWZvcmUtbWFrZSBv
biBwYWdlLXRhYmxlDQo+ID4gZW50cmllcyB3aGVuIGluc3RhbGxpbmcgaHVnZSBtYXBwaW5ncyBp
biB0aGUgdm1hbGxvYy9pb3JlbWFwIHJlZ2lvbiBpcw0KPiA+IGZhaXJseSBjb3VudGVyLWludHVp
dGl2ZSwgcmVzdWx0aW5nIGluIHRoZSBhcmNoIGZyZWVpbmcgZnVuY3Rpb25zDQo+ID4gKGUuZy4g
cG1kX2ZyZWVfcHRlX3BhZ2UoKSkgYmVpbmcgY2FsbGVkIGV2ZW4gb24gZW50cmllcyB0aGF0IGFy
ZW4ndA0KPiA+IHByZXNlbnQuIFRoaXMgcmVzdWx0ZWQgaW4gYSBtaW5vciBidWcgaW4gdGhlIGFy
bTY0IGltcGxlbWVudGF0aW9uLCBnaXZpbmcNCj4gPiByaXNlIHRvIHNwdXJpb3VzIFZNX1dBUk4g
bWVzc2FnZXMuDQo+ID4gDQo+ID4gVGhpcyBwYXRjaCBtb3ZlcyB0aGUgcFhkX3ByZXNlbnQoKSBj
aGVja3Mgb3V0IGludG8gdGhlIGNvcmUgY29kZSwNCj4gPiByZWZhY3RvcmluZyB0aGUgY2FsbHNp
dGVzIGF0IHRoZSBzYW1lIHRpbWUgc28gdGhhdCB3ZSBhdm9pZCB0aGUgY29tcGxleA0KPiA+IGNv
bmp1bmN0aW9ucyB3aGVuIGRldGVybWluaW5nIHdoZXRoZXIgb3Igbm90IHdlIGNhbiBwdXQgZG93
biBhIGh1Z2UNCj4gPiBtYXBwaW5nLg0KPiA+IA0KPiA+IENjOiBDaGludGFuIFBhbmR5YSA8Y3Bh
bmR5YUBjb2RlYXVyb3JhLm9yZz4NCj4gPiBDYzogVG9zaGkgS2FuaSA8dG9zaGkua2FuaUBocGUu
Y29tPg0KPiA+IENjOiBUaG9tYXMgR2xlaXhuZXIgPHRnbHhAbGludXRyb25peC5kZT4NCj4gPiBD
YzogTWljaGFsIEhvY2tvIDxtaG9ja29Ac3VzZS5jb20+DQo+ID4gQ2M6IEFuZHJldyBNb3J0b24g
PGFrcG1AbGludXgtZm91bmRhdGlvbi5vcmc+DQo+ID4gU3VnZ2VzdGVkLWJ5OiBMaW51cyBUb3J2
YWxkcyA8dG9ydmFsZHNAbGludXgtZm91bmRhdGlvbi5vcmc+DQo+ID4gU2lnbmVkLW9mZi1ieTog
V2lsbCBEZWFjb24gPHdpbGwuZGVhY29uQGFybS5jb20+DQo+IA0KPiBZZXMsIHRoaXMgbG9va3Mg
bmljZXIuDQo+IA0KPiBSZXZpZXdlZC1ieTogVG9zaGkgS2FuaSA8dG9zaGkua2FuaUBocGUuY29t
Pg0KDQpTb3JyeSwgSSB0YWtlIGl0IGJhY2sgc2luY2UgSSBnb3QgYSBxdWVzdGlvbi4uLg0KDQor
c3RhdGljIGludCBpb3JlbWFwX3RyeV9odWdlX3BtZChwbWRfdCAqcG1kLCB1bnNpZ25lZCBsb25n
IGFkZHIsDQo+ICsJCQkJdW5zaWduZWQgbG9uZyBlbmQsIHBoeXNfYWRkcl90DQpwaHlzX2FkZHIs
DQo+ICsJCQkJcGdwcm90X3QgcHJvdCkNCj4gK3sNCj4gKwlpZiAoIWlvcmVtYXBfcG1kX2VuYWJs
ZWQoKSkNCj4gKwkJcmV0dXJuIDA7DQo+ICsNCj4gKwlpZiAoKGVuZCAtIGFkZHIpICE9IFBNRF9T
SVpFKQ0KPiArCQlyZXR1cm4gMDsNCj4gKw0KPiArCWlmICghSVNfQUxJR05FRChwaHlzX2FkZHIs
IFBNRF9TSVpFKSkNCj4gKwkJcmV0dXJuIDA7DQo+ICsNCj4gKwlpZiAocG1kX3ByZXNlbnQoKnBt
ZCkgJiYgIXBtZF9mcmVlX3B0ZV9wYWdlKHBtZCwgYWRkcikpDQo+ICsJCXJldHVybiAwOw0KDQpJ
cyBwbV9wcmVzZW50KCkgYSBwcm9wZXIgY2hlY2sgaGVyZT8gIFdlIHByb2JhYmx5IGRvIG5vdCBo
YXZlIHRoaXMgY2FzZQ0KZm9yIGlvbWFwLCBidXQgSSB3b25kZXIgaWYgb25lIGNhbiBkcm9wIHAt
Yml0IHdoaWxlIGl0IGhhcyBhIHB0ZSBwYWdlDQp1bmRlcm5lYXRoLg0KDQpUaGFua3MsDQotVG9z
aGkNCg0KDQo+ICsNCj4gKwlyZXR1cm4gcG1kX3NldF9odWdlKHBtZCwgcGh5c19hZGRyLCBwcm90
KTsNCj4gK30NCj4gKw0KDQoNCg==
