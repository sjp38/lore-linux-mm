Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 126216B520E
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 10:35:41 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id l65-v6so5106746pge.17
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 07:35:41 -0700 (PDT)
Received: from NAM04-CO1-obe.outbound.protection.outlook.com (mail-eopbgr690109.outbound.protection.outlook.com. [40.107.69.109])
        by mx.google.com with ESMTPS id ca2-v6si7378169plb.305.2018.08.30.07.35.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Aug 2018 07:35:39 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH v1] mm: relax deferred struct page requirements
Date: Thu, 30 Aug 2018 14:35:37 +0000
Message-ID: <7aee9274-9e8e-4a40-a9e5-3c9ef28511b7@microsoft.com>
References: <20171117014601.31606-1-pasha.tatashin@oracle.com>
 <20171121072416.v77vu4osm2s4o5sq@dhcp22.suse.cz>
 <b16029f0-ada0-df25-071b-cd5dba0ab756@suse.cz>
 <CAGM2rea=_VJJ26tohWQWgfwcFVkp0gb6j1edH1kVLjtxfugf5Q@mail.gmail.com>
 <CAGM2reYcwyOcKrO=WhB3Cf0FNL3ZearC=KvxmTNUU6rkWviQOg@mail.gmail.com>
 <83d035f1-40b4-bed8-6113-f4c5a0c4d22f@suse.cz>
 <c4d46b63-5237-d002-faf5-4e0749d825d7@suse.cz>
In-Reply-To: <c4d46b63-5237-d002-faf5-4e0749d825d7@suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <1C800F9BE9F8864E8B6BE0DD1B2842EE@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: "mhocko@kernel.org" <mhocko@kernel.org>, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "paulus@samba.org" <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, "schwidefsky@de.ibm.com" <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>

VGhhbmsgeW91IEppcmksIEkgYW0gc3R1ZHlpbmcgaXQuDQoNClBhdmVsDQoNCk9uIDgvMjQvMTgg
Mzo0NCBBTSwgSmlyaSBTbGFieSB3cm90ZToNCj4gcGFzaGEudGF0YXNoaW5Ab3JhY2xlLmNvbSAt
PiBwYXZlbC50YXRhc2hpbkBtaWNyb3NvZnQuY29tDQo+IA0KPiBkdWUgdG8NCj4gIDU1MCA1LjEu
MSBVbmtub3duIHJlY2lwaWVudCBhZGRyZXNzLg0KPiANCj4gDQo+IE9uIDA4LzI0LzIwMTgsIDA5
OjMyIEFNLCBKaXJpIFNsYWJ5IHdyb3RlOg0KPj4gT24gMDYvMTkvMjAxOCwgMDk6NTYgUE0sIFBh
dmVsIFRhdGFzaGluIHdyb3RlOg0KPj4+IE9uIFR1ZSwgSnVuIDE5LCAyMDE4IGF0IDk6NTAgQU0g
UGF2ZWwgVGF0YXNoaW4NCj4+PiA8cGFzaGEudGF0YXNoaW5Ab3JhY2xlLmNvbT4gd3JvdGU6DQo+
Pj4+DQo+Pj4+IE9uIFNhdCwgSnVuIDE2LCAyMDE4IGF0IDQ6MDQgQU0gSmlyaSBTbGFieSA8anNs
YWJ5QHN1c2UuY3o+IHdyb3RlOg0KPj4+Pj4NCj4+Pj4+IE9uIDExLzIxLzIwMTcsIDA4OjI0IEFN
LCBNaWNoYWwgSG9ja28gd3JvdGU6DQo+Pj4+Pj4gT24gVGh1IDE2LTExLTE3IDIwOjQ2OjAxLCBQ
YXZlbCBUYXRhc2hpbiB3cm90ZToNCj4+Pj4+Pj4gVGhlcmUgaXMgbm8gbmVlZCB0byBoYXZlIEFS
Q0hfU1VQUE9SVFNfREVGRVJSRURfU1RSVUNUX1BBR0VfSU5JVCwNCj4+Pj4+Pj4gYXMgYWxsIHRo
ZSBwYWdlIGluaXRpYWxpemF0aW9uIGNvZGUgaXMgaW4gY29tbW9uIGNvZGUuDQo+Pj4+Pj4+DQo+
Pj4+Pj4+IEFsc28sIHRoZXJlIGlzIG5vIG5lZWQgdG8gZGVwZW5kIG9uIE1FTU9SWV9IT1RQTFVH
LCBhcyBpbml0aWFsaXphdGlvbiBjb2RlDQo+Pj4+Pj4+IGRvZXMgbm90IHJlYWxseSB1c2UgaG90
cGx1ZyBtZW1vcnkgZnVuY3Rpb25hbGl0eS4gU28sIHdlIGNhbiByZW1vdmUgdGhpcw0KPj4+Pj4+
PiByZXF1aXJlbWVudCBhcyB3ZWxsLg0KPj4+Pj4+Pg0KPj4+Pj4+PiBUaGlzIHBhdGNoIGFsbG93
cyB0byB1c2UgZGVmZXJyZWQgc3RydWN0IHBhZ2UgaW5pdGlhbGl6YXRpb24gb24gYWxsDQo+Pj4+
Pj4+IHBsYXRmb3JtcyB3aXRoIG1lbWJsb2NrIGFsbG9jYXRvci4NCj4+Pj4+Pj4NCj4+Pj4+Pj4g
VGVzdGVkIG9uIHg4NiwgYXJtNjQsIGFuZCBzcGFyYy4gQWxzbywgdmVyaWZpZWQgdGhhdCBjb2Rl
IGNvbXBpbGVzIG9uDQo+Pj4+Pj4+IFBQQyB3aXRoIENPTkZJR19NRU1PUllfSE9UUExVRyBkaXNh
YmxlZC4NCj4+Pj4+Pg0KPj4+Pj4+IFRoZXJlIGlzIHNsaWdodCByaXNrIHRoYXQgd2Ugd2lsbCBl
bmNvdW50ZXIgY29ybmVyIGNhc2VzIG9uIHNvbWUNCj4+Pj4+PiBhcmNoaXRlY3R1cmVzIHdpdGgg
d2VpcmQgbWVtb3J5IGxheW91dC90b3BvbG9neQ0KPj4+Pj4NCj4+Pj4+IFdoaWNoIHg4Nl8zMi1w
YWUgc2VlbXMgdG8gYmUuIE1hbnkgYmFkIHBhZ2Ugc3RhdGUgZXJyb3JzIGFyZSBlbWl0dGVkDQo+
Pj4+PiBkdXJpbmcgYm9vdCB3aGVuIHRoaXMgcGF0Y2ggaXMgYXBwbGllZDoNCj4+Pj4NCj4+Pj4g
SGkgSmlyaSwNCj4+Pj4NCj4+Pj4gVGhhbmsgeW91IGZvciByZXBvcnRpbmcgdGhpcyBidWcuDQo+
Pj4+DQo+Pj4+IEJlY2F1c2UgMzItYml0IHN5c3RlbXMgYXJlIGxpbWl0ZWQgaW4gdGhlIG1heGlt
dW0gYW1vdW50IG9mIHBoeXNpY2FsDQo+Pj4+IG1lbW9yeSwgdGhleSBkb24ndCBuZWVkIGRlZmVy
cmVkIHN0cnVjdCBwYWdlcy4gU28sIHdlIGNhbiBhZGQgZGVwZW5kcw0KPj4+PiBvbiA2NEJJVCB0
byBERUZFUlJFRF9TVFJVQ1RfUEFHRV9JTklUIGluIG1tL0tjb25maWcuDQo+Pj4+DQo+Pj4+IEhv
d2V2ZXIsIGJlZm9yZSB3ZSBkbyB0aGlzLCBJIHdhbnQgdG8gdHJ5IHJlcHJvZHVjaW5nIHRoaXMg
cHJvYmxlbSBhbmQNCj4+Pj4gcm9vdCBjYXVzZSBpdCwgYXMgaXQgbWlnaHQgZXhwb3NlIGEgZ2Vu
ZXJhbCBwcm9ibGVtIHRoYXQgaXMgbm90IDMyLWJpdA0KPj4+PiBzcGVjaWZpYy4NCj4+Pg0KPj4+
IEhpIEppcmksDQo+Pj4NCj4+PiBDb3VsZCB5b3UgcGxlYXNlIGF0dGFjaCB5b3VyIGNvbmZpZyBh
bmQgZnVsbCBxZW11IGFyZ3VtZW50cyB0aGF0IHlvdQ0KPj4+IHVzZWQgdG8gcmVwcm9kdWNlIHRo
aXMgYnVnLg0KPj4NCj4+IEhpLA0KPj4NCj4+IEkgc2VlbSBJIG5ldmVyIHJlcGxpZWQuIEF0dGFj
aGluZyAuY29uZmlnIGFuZCB0aGUgcWVtdSBjbWRsaW5lOg0KPj4gJCBxZW11LWt2bSAtbSAyMDAw
IC1oZGEgL2Rldi9udWxsIC1rZXJuZWwgYnpJbWFnZQ0KPj4NCj4+ICItbSAyMDAwIiBpcyBpbXBv
cnRhbnQgdG8gcmVwcm9kdWNlLg0KPj4NCj4+IElmIEkgZGlzYWJsZSBDT05GSUdfREVGRVJSRURf
U1RSVUNUX1BBR0VfSU5JVCAod2hpY2ggdGhlIHBhdGNoIGFsbG93ZWQNCj4+IHRvIGVuYWJsZSks
IHRoZSBlcnJvciBnb2VzIGF3YXksIG9mIGNvdXJzZS4NCj4+DQo+PiB0aGFua3MsDQo+Pg0KPiAN
Cj4g
