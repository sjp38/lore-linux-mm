Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id F3EDF6B0007
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 18:08:38 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id u74so3751950oif.19
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 15:08:38 -0800 (PST)
Received: from g9t5008.houston.hpe.com (g9t5008.houston.hpe.com. [15.241.48.72])
        by mx.google.com with ESMTPS id o16si6453605otb.316.2018.03.08.15.08.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 15:08:38 -0800 (PST)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: Kernel page fault in vmalloc_fault() after a preempted ioremap
Date: Thu, 8 Mar 2018 23:08:34 +0000
Message-ID: <1520553209.2693.110.camel@hpe.com>
References: <87a7vi1f3h.fsf@kerf.amer.corp.natinst.com>
	 <1520548101.2693.106.camel@hpe.com>
	 <CALCETrUB0brd92Tuv_cgakTgBo8yXxaAC1eLUMePMNsoWPK+mw@mail.gmail.com>
In-Reply-To: <CALCETrUB0brd92Tuv_cgakTgBo8yXxaAC1eLUMePMNsoWPK+mw@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <1A124B64618EF047B87038BE93DAC2AD@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "luto@kernel.org" <luto@kernel.org>
Cc: "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "julia.cartwright@ni.com" <julia.cartwright@ni.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "bp@suse.de" <bp@suse.de>, "gratian.crisan@ni.com" <gratian.crisan@ni.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "brgerst@gmail.com" <brgerst@gmail.com>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "dvlasenk@redhat.com" <dvlasenk@redhat.com>, "gratian@gmail.com" <gratian@gmail.com>

T24gVGh1LCAyMDE4LTAzLTA4IGF0IDIyOjM4ICswMDAwLCBBbmR5IEx1dG9taXJza2kgd3JvdGU6
DQo+IE9uIFRodSwgTWFyIDgsIDIwMTggYXQgOTo0MyBQTSwgS2FuaSwgVG9zaGkgPHRvc2hpLmth
bmlAaHBlLmNvbT4gd3JvdGU6DQo+ID4gT24gVGh1LCAyMDE4LTAzLTA4IGF0IDE0OjM0IC0wNjAw
LCBHcmF0aWFuIENyaXNhbiB3cm90ZToNCiA6DQo+ID4gDQo+ID4gVGhhbmtzIGZvciB0aGUgcmVw
b3J0IGFuZCBhbmFseXNpcyEgIEkgYmVsaWV2ZSBwdWRfbGFyZ2UoKSBhbmQNCj4gPiBwbWRfbGFy
Z2UoKSBzaG91bGQgaGF2ZSBiZWVuIHVzZWQgaGVyZS4gIEkgd2lsbCB0cnkgdG8gcmVwcm9kdWNl
IHRoZQ0KPiA+IGlzc3VlIGFuZCB2ZXJpZnkgdGhlIGZpeC4NCj4gDQo+IEluZGVlZC4gIEkgZmlu
ZCBteXNlbGYgd29uZGVyaW5nIHdoeSBwdWRfaHVnZSgpIGV4aXN0cyBhdCBhbGwuDQo+IA0KPiBX
aGlsZSB5b3UncmUgYXQgaXQsIEkgdGhpbmsgdGhlcmUgbWF5IGJlIG1vcmUgYnVncyBpbiB0aGVy
ZS4NCj4gU3BlY2lmaWNhbGx5LCB0aGUgY29kZSB3YWxrcyB0aGUgcmVmZXJlbmNlIGFuZCBjdXJy
ZW50IHRhYmxlcyBhdCB0aGUNCj4gc2FtZSB0aW1lIHdpdGhvdXQgYW55IHN5bmNocm9uaXphdGlv
biBhbmQgd2l0aG91dCBSRUFEX09OQ0UoKQ0KPiBwcm90ZWN0aW9uLiAgSSB0aGluayB0aGF0IGFs
bCBvZiB0aGUgQlVHKCkgY2FsbHMgYmVsb3cgdGhlIGNvbW1lbnQ6DQo+IA0KPiAgICAgICAgIC8q
DQo+ICAgICAgICAgICogQmVsb3cgaGVyZSBtaXNtYXRjaGVzIGFyZSBidWdzIGJlY2F1c2UgdGhl
c2UgbG93ZXIgdGFibGVzDQo+ICAgICAgICAgICogYXJlIHNoYXJlZDoNCj4gICAgICAgICAgKi8N
Cj4gDQo+IGFyZSBib2d1cyBhbmQgY291bGQgYmUgaGl0IGR1ZSB0byByYWNlcy4gIEkgYWxzbyB0
aGluayB0aGV5J3JlDQo+IHBvaW50bGVzcyAtLSB3ZSd2ZSBhbHJlYWR5IGFzc2VydGVkIHRoYXQg
dGhlIHJlZmVyZW5jZSBhbmQgbG9hZGVkDQo+IHRhYmxlcyBhcmUgbGl0ZXJhbGx5IHRoZSBzYW1l
IHBvaW50ZXJzLiAgSSB0aGluayB0aGUgcmlnaHQgZml4IGlzIHRvDQo+IHJlbW92ZSBwdWRfcmVm
LCBwbWRfcmVmIGFuZCBwdGVfcmVmIGVudGlyZWx5IGFuZCB0byBnZXQgcmlkIG9mIHRob3NlDQo+
IEJVRygpIGNhbGxzLg0KPiANCj4gV2hhdCBkbyB5b3UgdGhpbms/DQoNCkkgYWdyZWUgdGhhdCB0
aGVzZSBCVUcoKSBjaGVja3MgYXJlIHBvaW50bGVzcy4gIEkgd2lsbCByZW1vdmUgdGhlbSBpbg0K
dGhpcyBvcHBvcnR1bml0eS4NCg0KVGhhbmtzLA0KLVRvc2hpDQo=
