Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id B44288E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 14:38:53 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id p1-v6so11623746oti.18
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 11:38:53 -0700 (PDT)
Received: from g4t3426.houston.hpe.com (g4t3426.houston.hpe.com. [15.241.140.75])
        by mx.google.com with ESMTPS id x16-v6si6518226oie.224.2018.09.17.11.38.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Sep 2018 11:38:52 -0700 (PDT)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH 1/5] ioremap: Rework pXd_free_pYd_page() API
Date: Mon, 17 Sep 2018 18:38:28 +0000
Message-ID: <f4b73d9d61e87712fec1712bb6225e2b385a16e3.camel@hpe.com>
References: <1536747974-25875-1-git-send-email-will.deacon@arm.com>
	 <1536747974-25875-2-git-send-email-will.deacon@arm.com>
	 <71baefb8e0838fba89ee06262bbb2456e9091c7a.camel@hpe.com>
	 <db3f513bf3bfafb85b99f57f741f5bb07952af70.camel@hpe.com>
	 <20180917113328.GC22717@arm.com>
In-Reply-To: <20180917113328.GC22717@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <4F5E38911718DD40A11C9C087ED37C9F@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "will.deacon@arm.com" <will.deacon@arm.com>
Cc: "tglx@linutronix.de" <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "Hocko, Michal" <MHocko@suse.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

T24gTW9uLCAyMDE4LTA5LTE3IGF0IDEyOjMzICswMTAwLCBXaWxsIERlYWNvbiB3cm90ZToNCj4g
T24gRnJpLCBTZXAgMTQsIDIwMTggYXQgMDk6MTA6NDlQTSArMDAwMCwgS2FuaSwgVG9zaGkgd3Jv
dGU6DQo+ID4gT24gRnJpLCAyMDE4LTA5LTE0IGF0IDE0OjM2IC0wNjAwLCBUb3NoaSBLYW5pIHdy
b3RlOg0KPiA+ID4gT24gV2VkLCAyMDE4LTA5LTEyIGF0IDExOjI2ICswMTAwLCBXaWxsIERlYWNv
biB3cm90ZToNCj4gPiA+ID4gVGhlIHJlY2VudGx5IG1lcmdlZCBBUEkgZm9yIGVuc3VyaW5nIGJy
ZWFrLWJlZm9yZS1tYWtlIG9uIHBhZ2UtdGFibGUNCj4gPiA+ID4gZW50cmllcyB3aGVuIGluc3Rh
bGxpbmcgaHVnZSBtYXBwaW5ncyBpbiB0aGUgdm1hbGxvYy9pb3JlbWFwIHJlZ2lvbiBpcw0KPiA+
ID4gPiBmYWlybHkgY291bnRlci1pbnR1aXRpdmUsIHJlc3VsdGluZyBpbiB0aGUgYXJjaCBmcmVl
aW5nIGZ1bmN0aW9ucw0KPiA+ID4gPiAoZS5nLiBwbWRfZnJlZV9wdGVfcGFnZSgpKSBiZWluZyBj
YWxsZWQgZXZlbiBvbiBlbnRyaWVzIHRoYXQgYXJlbid0DQo+ID4gPiA+IHByZXNlbnQuIFRoaXMg
cmVzdWx0ZWQgaW4gYSBtaW5vciBidWcgaW4gdGhlIGFybTY0IGltcGxlbWVudGF0aW9uLCBnaXZp
bmcNCj4gPiA+ID4gcmlzZSB0byBzcHVyaW91cyBWTV9XQVJOIG1lc3NhZ2VzLg0KPiA+ID4gPiAN
Cj4gPiA+ID4gVGhpcyBwYXRjaCBtb3ZlcyB0aGUgcFhkX3ByZXNlbnQoKSBjaGVja3Mgb3V0IGlu
dG8gdGhlIGNvcmUgY29kZSwNCj4gPiA+ID4gcmVmYWN0b3JpbmcgdGhlIGNhbGxzaXRlcyBhdCB0
aGUgc2FtZSB0aW1lIHNvIHRoYXQgd2UgYXZvaWQgdGhlIGNvbXBsZXgNCj4gPiA+ID4gY29uanVu
Y3Rpb25zIHdoZW4gZGV0ZXJtaW5pbmcgd2hldGhlciBvciBub3Qgd2UgY2FuIHB1dCBkb3duIGEg
aHVnZQ0KPiA+ID4gPiBtYXBwaW5nLg0KPiA+ID4gPiANCj4gPiA+ID4gQ2M6IENoaW50YW4gUGFu
ZHlhIDxjcGFuZHlhQGNvZGVhdXJvcmEub3JnPg0KPiA+ID4gPiBDYzogVG9zaGkgS2FuaSA8dG9z
aGkua2FuaUBocGUuY29tPg0KPiA+ID4gPiBDYzogVGhvbWFzIEdsZWl4bmVyIDx0Z2x4QGxpbnV0
cm9uaXguZGU+DQo+ID4gPiA+IENjOiBNaWNoYWwgSG9ja28gPG1ob2Nrb0BzdXNlLmNvbT4NCj4g
PiA+ID4gQ2M6IEFuZHJldyBNb3J0b24gPGFrcG1AbGludXgtZm91bmRhdGlvbi5vcmc+DQo+ID4g
PiA+IFN1Z2dlc3RlZC1ieTogTGludXMgVG9ydmFsZHMgPHRvcnZhbGRzQGxpbnV4LWZvdW5kYXRp
b24ub3JnPg0KPiA+ID4gPiBTaWduZWQtb2ZmLWJ5OiBXaWxsIERlYWNvbiA8d2lsbC5kZWFjb25A
YXJtLmNvbT4NCj4gPiA+IA0KPiA+ID4gWWVzLCB0aGlzIGxvb2tzIG5pY2VyLg0KPiA+ID4gDQo+
ID4gPiBSZXZpZXdlZC1ieTogVG9zaGkgS2FuaSA8dG9zaGkua2FuaUBocGUuY29tPg0KPiA+IA0K
PiA+IFNvcnJ5LCBJIHRha2UgaXQgYmFjayBzaW5jZSBJIGdvdCBhIHF1ZXN0aW9uLi4uDQo+ID4g
DQo+ID4gK3N0YXRpYyBpbnQgaW9yZW1hcF90cnlfaHVnZV9wbWQocG1kX3QgKnBtZCwgdW5zaWdu
ZWQgbG9uZyBhZGRyLA0KPiA+ID4gKwkJCQl1bnNpZ25lZCBsb25nIGVuZCwgcGh5c19hZGRyX3QN
Cj4gPiANCj4gPiBwaHlzX2FkZHIsDQo+ID4gPiArCQkJCXBncHJvdF90IHByb3QpDQo+ID4gPiAr
ew0KPiA+ID4gKwlpZiAoIWlvcmVtYXBfcG1kX2VuYWJsZWQoKSkNCj4gPiA+ICsJCXJldHVybiAw
Ow0KPiA+ID4gKw0KPiA+ID4gKwlpZiAoKGVuZCAtIGFkZHIpICE9IFBNRF9TSVpFKQ0KPiA+ID4g
KwkJcmV0dXJuIDA7DQo+ID4gPiArDQo+ID4gPiArCWlmICghSVNfQUxJR05FRChwaHlzX2FkZHIs
IFBNRF9TSVpFKSkNCj4gPiA+ICsJCXJldHVybiAwOw0KPiA+ID4gKw0KPiA+ID4gKwlpZiAocG1k
X3ByZXNlbnQoKnBtZCkgJiYgIXBtZF9mcmVlX3B0ZV9wYWdlKHBtZCwgYWRkcikpDQo+ID4gPiAr
CQlyZXR1cm4gMDsNCj4gPiANCj4gPiBJcyBwbV9wcmVzZW50KCkgYSBwcm9wZXIgY2hlY2sgaGVy
ZT8gIFdlIHByb2JhYmx5IGRvIG5vdCBoYXZlIHRoaXMgY2FzZQ0KPiA+IGZvciBpb21hcCwgYnV0
IEkgd29uZGVyIGlmIG9uZSBjYW4gZHJvcCBwLWJpdCB3aGlsZSBpdCBoYXMgYSBwdGUgcGFnZQ0K
PiA+IHVuZGVybmVhdGguDQo+IA0KPiBGb3IgaW9yZW1hcC92dW5tYXAgdGhlIHBYZF9wcmVzZW50
KCkgY2hlY2sgaXMgY29ycmVjdCwgeWVzLiBUaGUgdnVubWFwKCkNCj4gY29kZSBvbmx5IGV2ZXIg
Y2xlYXJzIGxlYWYgZW50cmllcywgbGVhdmluZyB0YWJsZSBlbnRyaWVzIGludGFjdC4gDQoNClJp
Z2h0LiBJIHdhcyB0aGlua2luZyBpZiBzdWNoIGNhc2UgaGFwcGVucyBpbiBmdXR1cmUuDQoNCj4g
SWYgaXQNCj4gZGlkIGNsZWFyIHRhYmxlIGVudHJpZXMsIHlvdSdkIGJlIHN0dWNrIGhlcmUgYmVj
YXVzZSB5b3Ugd291bGRuJ3QgaGF2ZQ0KPiB0aGUgYWRkcmVzcyBvZiB0aGUgdGFibGUgdG8gZnJl
ZS4NCj4gDQo+IElmIHNvbWVib2R5IGNhbGxlZCBwbWRfbWtub3RwcmVzZW50KCkgb24gYSB0YWJs
ZSBlbnRyeSwgd2UgbWF5IHJ1biBpbnRvDQo+IHByb2JsZW1zLCBidXQgaXQncyBvbmx5IHVzZWQg
Zm9yIGh1Z2UgbWFwcGluZ3MgYWZhaWN0Lg0KDQpUcmVhdGluZyBhIHRhYmxlIGVudHJ5IHZhbGlk
IHdoZW4gcC1iaXQgaXMgb2ZmIGlzIHJpc2t5IGFzIHdlbGwuIFNvLCBJDQphZ3JlZSB3aXRoIHRo
ZSBwWGRfcHJlc2VudCgpIGNoZWNrLg0KDQpSZXZpZXdlZC1ieTogVG9zaGkgS2FuaSA8dG9zaGku
a2FuaUBocGUuY29tPg0KDQpUaGFua3MsDQotVG9zaGkNCg0K
