Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 04D596B000A
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 16:07:44 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id o4so2326440oib.15
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 13:07:43 -0700 (PDT)
Received: from g9t5009.houston.hpe.com (g9t5009.houston.hpe.com. [15.241.48.73])
        by mx.google.com with ESMTPS id x25si1002065otd.78.2018.03.14.13.07.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 13:07:42 -0700 (PDT)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH 2/2] x86/mm: remove pointless checks in vmalloc_fault
Date: Wed, 14 Mar 2018 20:07:37 +0000
Message-ID: <1521058054.2693.139.camel@hpe.com>
References: <20180313170347.3829-1-toshi.kani@hpe.com>
	 <20180313170347.3829-3-toshi.kani@hpe.com>
	 <alpine.DEB.2.21.1803142024540.1946@nanos.tec.linutronix.de>
	 <1521056327.2693.138.camel@hpe.com>
	 <alpine.DEB.2.21.1803142054390.1946@nanos.tec.linutronix.de>
In-Reply-To: <alpine.DEB.2.21.1803142054390.1946@nanos.tec.linutronix.de>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <C58D6D299981DF4EB9E396EABC60EA72@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "tglx@linutronix.de" <tglx@linutronix.de>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "gratian.crisan@ni.com" <gratian.crisan@ni.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "bp@alien8.de" <bp@alien8.de>

T24gV2VkLCAyMDE4LTAzLTE0IGF0IDIwOjU2ICswMTAwLCBUaG9tYXMgR2xlaXhuZXIgd3JvdGU6
DQo+IE9uIFdlZCwgMTQgTWFyIDIwMTgsIEthbmksIFRvc2hpIHdyb3RlOg0KPiA+IE9uIFdlZCwg
MjAxOC0wMy0xNCBhdCAyMDoyNyArMDEwMCwgVGhvbWFzIEdsZWl4bmVyIHdyb3RlOg0KPiA+ID4g
T24gVHVlLCAxMyBNYXIgMjAxOCwgVG9zaGkgS2FuaSB3cm90ZToNCj4gPiA+IA0KPiA+ID4gPiB2
bWFsbG9jX2ZhdWx0KCkgc2V0cyB1c2VyJ3MgcGdkIG9yIHA0ZCBmcm9tIHRoZSBrZXJuZWwgcGFn
ZSB0YWJsZS4NCj4gPiA+ID4gT25jZSBpdCdzIHNldCwgYWxsIHRhYmxlcyB1bmRlcm5lYXRoIGFy
ZSBpZGVudGljYWwuIFRoZXJlIGlzIG5vIHBvaW50DQo+ID4gPiA+IG9mIGZvbGxvd2luZyB0aGUg
c2FtZSBwYWdlIHRhYmxlIHdpdGggdHdvIHNlcGFyYXRlIHBvaW50ZXJzIGFuZCBtYWtlcw0KPiA+
ID4gPiBzdXJlIHRoZXkgc2VlIHRoZSBzYW1lIHdpdGggQlVHKCkuDQo+ID4gPiA+IA0KPiA+ID4g
PiBSZW1vdmUgdGhlIHBvaW50bGVzcyBjaGVja3MgaW4gdm1hbGxvY19mYXVsdCgpLiBBbHNvIHJl
bmFtZSB0aGUga2VybmVsDQo+ID4gPiA+IHBnZC9wNGQgcG9pbnRlcnMgdG8gcGdkX2svcDRkX2sg
c28gdGhhdCB0aGVpciBuYW1lcyBhcmUgY29uc2lzdGVudCBpbg0KPiA+ID4gPiB0aGUgZmlsZS4N
Cj4gPiA+IA0KPiA+ID4gSSBoYXZlIG5vIGlkZWEgdG8gd2hpY2ggYnJhbmNoIHRoaXMgbWlnaHQg
YXBwbHkuIFRoZSBmaXJzdCBwYXRjaCBhcHBsaWVzDQo+ID4gPiBjbGVhbmx5IG9uIGxpbnVzIGhl
YWQsIGJ1dCB0aGlzIG9uZSBmYWlscyBpbiBodW5rICMyIG9uIGV2ZXJ5dGhpbmcgSQ0KPiA+ID4g
dHJpZWQuIENhbiB5b3UgcGxlYXNlIGNoZWNrPw0KPiA+IA0KPiA+IFNvcnJ5IGZvciB0aGUgdHJv
dWJsZS4gVGhlIHBhdGNoZXMgYXJlIGJhc2VkIG9uIGxpbnVzIGhlYWQuIEkganVzdCB0cmllZA0K
PiA+IGFuZCB0aGV5IGFwcGxpZWQgY2xlYW4gdG8gbWUuLi4gDQo+IA0KPiBIbW0uIExvb2tzIGxp
a2UgSSB0cmllZCBvbiB0aGUgd3JvbmcgYnJhbmNoLiBOZXZlcnRoZWxlc3MsIDEvMiBpcyBxdWV1
ZWQgaW4NCj4gdXJnZW50LCBidXQgMi8yIHdpbGwgZ28gdGhyb3VnaCB0aXAveDg2L21tIHdoaWNo
IGFscmVhZHkgaGFzIGNoYW5nZXMgaW4NCj4gdGhhdCBhcmVhIGNhdXNpbmcgdGhlIHBhdGNoIHRv
IGZhaWwuIEkganVzdCBtZXJnZWQgeDg2L3VyZ2VudCBpbnRvIHg4Ni9tbQ0KPiBhbmQgcHVzaGVk
IGl0IG91dC4gQ2FuIHlvdSBwbGVhc2UgcmViYXNlIDIvMiBvbiB0b3Agb2YgdGhhdCBicmFjbmgg
YW5kDQo+IHJlc2VuZCA/DQoNClllcywgSSB3aWxsIG1lcmdlIHVwIDIvMiBhbmQgcmVzZW5kLg0K
DQpUaGFua3MsDQotVG9zaGkNCg==
