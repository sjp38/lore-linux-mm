Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8698F6B521B
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 11:45:26 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id o27-v6so4971552pfj.6
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 08:45:26 -0700 (PDT)
Received: from NAM05-CO1-obe.outbound.protection.outlook.com (mail-eopbgr720123.outbound.protection.outlook.com. [40.107.72.123])
        by mx.google.com with ESMTPS id p15-v6si6697449pgl.340.2018.08.30.08.45.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Aug 2018 08:45:25 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH v1] mm: relax deferred struct page requirements
Date: Thu, 30 Aug 2018 15:45:22 +0000
Message-ID: <87516e50-a17c-6c80-e9b5-ba68eda9ce33@microsoft.com>
References: <20171117014601.31606-1-pasha.tatashin@oracle.com>
 <20171121072416.v77vu4osm2s4o5sq@dhcp22.suse.cz>
 <b16029f0-ada0-df25-071b-cd5dba0ab756@suse.cz>
 <CAGM2rea=_VJJ26tohWQWgfwcFVkp0gb6j1edH1kVLjtxfugf5Q@mail.gmail.com>
 <CAGM2reYcwyOcKrO=WhB3Cf0FNL3ZearC=KvxmTNUU6rkWviQOg@mail.gmail.com>
 <83d035f1-40b4-bed8-6113-f4c5a0c4d22f@suse.cz>
 <c4d46b63-5237-d002-faf5-4e0749d825d7@suse.cz>
 <7aee9274-9e8e-4a40-a9e5-3c9ef28511b7@microsoft.com>
In-Reply-To: <7aee9274-9e8e-4a40-a9e5-3c9ef28511b7@microsoft.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <9951558AA4DCA24C902267BF4B6EC0D8@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: "mhocko@kernel.org" <mhocko@kernel.org>, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "paulus@samba.org" <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, "schwidefsky@de.ibm.com" <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>

SGkgSmlyaSwNCg0KSSBiZWxpZXZlIHRoaXMgYnVnIGlzIGZpeGVkIHdpdGggdGhpcyBjaGFuZ2U6
DQoNCmQzOWY4ZmI0Yjc3NzZkY2IwOWVjM2JmN2EzMjE1NDcwODMwNzhlZTMNCm1tOiBtYWtlIERF
RkVSUkVEX1NUUlVDVF9QQUdFX0lOSVQgZXhwbGljaXRseSBkZXBlbmQgb24gU1BBUlNFTUVNDQoN
CkkgYW0gbm90IGFibGUgdG8gcmVwcm9kdWNlIHRoaXMgcHJvYmxlbSBvbiB4ODYtMzIuDQoNClBh
dmVsDQoNCk9uIDgvMzAvMTggMTA6MzUgQU0sIFBhdmVsIFRhdGFzaGluIHdyb3RlOg0KPiBUaGFu
ayB5b3UgSmlyaSwgSSBhbSBzdHVkeWluZyBpdC4NCj4gDQo+IFBhdmVsDQo+IA0KPiBPbiA4LzI0
LzE4IDM6NDQgQU0sIEppcmkgU2xhYnkgd3JvdGU6DQo+PiBwYXNoYS50YXRhc2hpbkBvcmFjbGUu
Y29tIC0+IHBhdmVsLnRhdGFzaGluQG1pY3Jvc29mdC5jb20NCj4+DQo+PiBkdWUgdG8NCj4+ICA1
NTAgNS4xLjEgVW5rbm93biByZWNpcGllbnQgYWRkcmVzcy4NCj4+DQo+Pg0KPj4gT24gMDgvMjQv
MjAxOCwgMDk6MzIgQU0sIEppcmkgU2xhYnkgd3JvdGU6DQo+Pj4gT24gMDYvMTkvMjAxOCwgMDk6
NTYgUE0sIFBhdmVsIFRhdGFzaGluIHdyb3RlOg0KPj4+PiBPbiBUdWUsIEp1biAxOSwgMjAxOCBh
dCA5OjUwIEFNIFBhdmVsIFRhdGFzaGluDQo+Pj4+IDxwYXNoYS50YXRhc2hpbkBvcmFjbGUuY29t
PiB3cm90ZToNCj4+Pj4+DQo+Pj4+PiBPbiBTYXQsIEp1biAxNiwgMjAxOCBhdCA0OjA0IEFNIEpp
cmkgU2xhYnkgPGpzbGFieUBzdXNlLmN6PiB3cm90ZToNCj4+Pj4+Pg0KPj4+Pj4+IE9uIDExLzIx
LzIwMTcsIDA4OjI0IEFNLCBNaWNoYWwgSG9ja28gd3JvdGU6DQo+Pj4+Pj4+IE9uIFRodSAxNi0x
MS0xNyAyMDo0NjowMSwgUGF2ZWwgVGF0YXNoaW4gd3JvdGU6DQo+Pj4+Pj4+PiBUaGVyZSBpcyBu
byBuZWVkIHRvIGhhdmUgQVJDSF9TVVBQT1JUU19ERUZFUlJFRF9TVFJVQ1RfUEFHRV9JTklULA0K
Pj4+Pj4+Pj4gYXMgYWxsIHRoZSBwYWdlIGluaXRpYWxpemF0aW9uIGNvZGUgaXMgaW4gY29tbW9u
IGNvZGUuDQo+Pj4+Pj4+Pg0KPj4+Pj4+Pj4gQWxzbywgdGhlcmUgaXMgbm8gbmVlZCB0byBkZXBl
bmQgb24gTUVNT1JZX0hPVFBMVUcsIGFzIGluaXRpYWxpemF0aW9uIGNvZGUNCj4+Pj4+Pj4+IGRv
ZXMgbm90IHJlYWxseSB1c2UgaG90cGx1ZyBtZW1vcnkgZnVuY3Rpb25hbGl0eS4gU28sIHdlIGNh
biByZW1vdmUgdGhpcw0KPj4+Pj4+Pj4gcmVxdWlyZW1lbnQgYXMgd2VsbC4NCj4+Pj4+Pj4+DQo+
Pj4+Pj4+PiBUaGlzIHBhdGNoIGFsbG93cyB0byB1c2UgZGVmZXJyZWQgc3RydWN0IHBhZ2UgaW5p
dGlhbGl6YXRpb24gb24gYWxsDQo+Pj4+Pj4+PiBwbGF0Zm9ybXMgd2l0aCBtZW1ibG9jayBhbGxv
Y2F0b3IuDQo+Pj4+Pj4+Pg0KPj4+Pj4+Pj4gVGVzdGVkIG9uIHg4NiwgYXJtNjQsIGFuZCBzcGFy
Yy4gQWxzbywgdmVyaWZpZWQgdGhhdCBjb2RlIGNvbXBpbGVzIG9uDQo+Pj4+Pj4+PiBQUEMgd2l0
aCBDT05GSUdfTUVNT1JZX0hPVFBMVUcgZGlzYWJsZWQuDQo+Pj4+Pj4+DQo+Pj4+Pj4+IFRoZXJl
IGlzIHNsaWdodCByaXNrIHRoYXQgd2Ugd2lsbCBlbmNvdW50ZXIgY29ybmVyIGNhc2VzIG9uIHNv
bWUNCj4+Pj4+Pj4gYXJjaGl0ZWN0dXJlcyB3aXRoIHdlaXJkIG1lbW9yeSBsYXlvdXQvdG9wb2xv
Z3kNCj4+Pj4+Pg0KPj4+Pj4+IFdoaWNoIHg4Nl8zMi1wYWUgc2VlbXMgdG8gYmUuIE1hbnkgYmFk
IHBhZ2Ugc3RhdGUgZXJyb3JzIGFyZSBlbWl0dGVkDQo+Pj4+Pj4gZHVyaW5nIGJvb3Qgd2hlbiB0
aGlzIHBhdGNoIGlzIGFwcGxpZWQ6DQo+Pj4+Pg0KPj4+Pj4gSGkgSmlyaSwNCj4+Pj4+DQo+Pj4+
PiBUaGFuayB5b3UgZm9yIHJlcG9ydGluZyB0aGlzIGJ1Zy4NCj4+Pj4+DQo+Pj4+PiBCZWNhdXNl
IDMyLWJpdCBzeXN0ZW1zIGFyZSBsaW1pdGVkIGluIHRoZSBtYXhpbXVtIGFtb3VudCBvZiBwaHlz
aWNhbA0KPj4+Pj4gbWVtb3J5LCB0aGV5IGRvbid0IG5lZWQgZGVmZXJyZWQgc3RydWN0IHBhZ2Vz
LiBTbywgd2UgY2FuIGFkZCBkZXBlbmRzDQo+Pj4+PiBvbiA2NEJJVCB0byBERUZFUlJFRF9TVFJV
Q1RfUEFHRV9JTklUIGluIG1tL0tjb25maWcuDQo+Pj4+Pg0KPj4+Pj4gSG93ZXZlciwgYmVmb3Jl
IHdlIGRvIHRoaXMsIEkgd2FudCB0byB0cnkgcmVwcm9kdWNpbmcgdGhpcyBwcm9ibGVtIGFuZA0K
Pj4+Pj4gcm9vdCBjYXVzZSBpdCwgYXMgaXQgbWlnaHQgZXhwb3NlIGEgZ2VuZXJhbCBwcm9ibGVt
IHRoYXQgaXMgbm90IDMyLWJpdA0KPj4+Pj4gc3BlY2lmaWMuDQo+Pj4+DQo+Pj4+IEhpIEppcmks
DQo+Pj4+DQo+Pj4+IENvdWxkIHlvdSBwbGVhc2UgYXR0YWNoIHlvdXIgY29uZmlnIGFuZCBmdWxs
IHFlbXUgYXJndW1lbnRzIHRoYXQgeW91DQo+Pj4+IHVzZWQgdG8gcmVwcm9kdWNlIHRoaXMgYnVn
Lg0KPj4+DQo+Pj4gSGksDQo+Pj4NCj4+PiBJIHNlZW0gSSBuZXZlciByZXBsaWVkLiBBdHRhY2hp
bmcgLmNvbmZpZyBhbmQgdGhlIHFlbXUgY21kbGluZToNCj4+PiAkIHFlbXUta3ZtIC1tIDIwMDAg
LWhkYSAvZGV2L251bGwgLWtlcm5lbCBiekltYWdlDQo+Pj4NCj4+PiAiLW0gMjAwMCIgaXMgaW1w
b3J0YW50IHRvIHJlcHJvZHVjZS4NCj4+Pg0KPj4+IElmIEkgZGlzYWJsZSBDT05GSUdfREVGRVJS
RURfU1RSVUNUX1BBR0VfSU5JVCAod2hpY2ggdGhlIHBhdGNoIGFsbG93ZWQNCj4+PiB0byBlbmFi
bGUpLCB0aGUgZXJyb3IgZ29lcyBhd2F5LCBvZiBjb3Vyc2UuDQo+Pj4NCj4+PiB0aGFua3MsDQo+
Pj4NCj4+DQo+Pg==
