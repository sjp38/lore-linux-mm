Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 21C246B000E
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 12:06:29 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s23-v6so1570984plq.7
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:06:29 -0700 (PDT)
Received: from NAM04-CO1-obe.outbound.protection.outlook.com (mail-eopbgr690102.outbound.protection.outlook.com. [40.107.69.102])
        by mx.google.com with ESMTPS id g13-v6si27467961pgk.21.2018.10.31.09.06.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 31 Oct 2018 09:06:27 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [mm PATCH v4 3/6] mm: Use memblock/zone specific iterator for
 handling deferred page init
Date: Wed, 31 Oct 2018 16:06:17 +0000
Message-ID: <0201b67f-e6a7-623c-77e1-f080d5bf30b5@microsoft.com>
References: <20181017235043.17213.92459.stgit@localhost.localdomain>
 <20181017235419.17213.68425.stgit@localhost.localdomain>
 <5b937f29-a6e1-6622-b035-246229021d3e@microsoft.com>
 <a7c1bc0ed1e68cbc32c4dd6753fa9f8ff7f1421f.camel@linux.intel.com>
In-Reply-To: <a7c1bc0ed1e68cbc32c4dd6753fa9f8ff7f1421f.camel@linux.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <2C47298D11152E4AB0857451CF9D6A85@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>, Pasha Tatashin <Pavel.Tatashin@microsoft.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "dave.jiang@intel.com" <dave.jiang@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "willy@infradead.org" <willy@infradead.org>, "davem@davemloft.net" <davem@davemloft.net>, "yi.z.zhang@linux.intel.com" <yi.z.zhang@linux.intel.com>, "khalid.aziz@oracle.com" <khalid.aziz@oracle.com>, "rppt@linux.vnet.ibm.com" <rppt@linux.vnet.ibm.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "ldufour@linux.vnet.ibm.com" <ldufour@linux.vnet.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "mingo@kernel.org" <mingo@kernel.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

DQoNCk9uIDEwLzMxLzE4IDEyOjA1IFBNLCBBbGV4YW5kZXIgRHV5Y2sgd3JvdGU6DQo+IE9uIFdl
ZCwgMjAxOC0xMC0zMSBhdCAxNTo0MCArMDAwMCwgUGFzaGEgVGF0YXNoaW4gd3JvdGU6DQo+Pg0K
Pj4gT24gMTAvMTcvMTggNzo1NCBQTSwgQWxleGFuZGVyIER1eWNrIHdyb3RlOg0KPj4+IFRoaXMg
cGF0Y2ggaW50cm9kdWNlcyBhIG5ldyBpdGVyYXRvciBmb3JfZWFjaF9mcmVlX21lbV9wZm5fcmFu
Z2VfaW5fem9uZS4NCj4+Pg0KPj4+IFRoaXMgaXRlcmF0b3Igd2lsbCB0YWtlIGNhcmUgb2YgbWFr
aW5nIHN1cmUgYSBnaXZlbiBtZW1vcnkgcmFuZ2UgcHJvdmlkZWQNCj4+PiBpcyBpbiBmYWN0IGNv
bnRhaW5lZCB3aXRoaW4gYSB6b25lLiBJdCB0YWtlcyBhcmUgb2YgYWxsIHRoZSBib3VuZHMgY2hl
Y2tpbmcNCj4+PiB3ZSB3ZXJlIGRvaW5nIGluIGRlZmVycmVkX2dyb3dfem9uZSwgYW5kIGRlZmVy
cmVkX2luaXRfbWVtbWFwLiBJbiBhZGRpdGlvbg0KPj4+IGl0IHNob3VsZCBoZWxwIHRvIHNwZWVk
IHVwIHRoZSBzZWFyY2ggYSBiaXQgYnkgaXRlcmF0aW5nIHVudGlsIHRoZSBlbmQgb2YgYQ0KPj4+
IHJhbmdlIGlzIGdyZWF0ZXIgdGhhbiB0aGUgc3RhcnQgb2YgdGhlIHpvbmUgcGZuIHJhbmdlLCBh
bmQgd2lsbCBleGl0DQo+Pj4gY29tcGxldGVseSBpZiB0aGUgc3RhcnQgaXMgYmV5b25kIHRoZSBl
bmQgb2YgdGhlIHpvbmUuDQo+Pj4NCj4+PiBUaGlzIHBhdGNoIGFkZHMgeWV0IGFub3RoZXIgaXRl
cmF0b3IgY2FsbGVkDQo+Pj4gZm9yX2VhY2hfZnJlZV9tZW1fcmFuZ2VfaW5fem9uZV9mcm9tIGFu
ZCB0aGVuIHVzZXMgaXQgdG8gc3VwcG9ydA0KPj4+IGluaXRpYWxpemluZyBhbmQgZnJlZWluZyBw
YWdlcyBpbiBncm91cHMgbm8gbGFyZ2VyIHRoYW4gTUFYX09SREVSX05SX1BBR0VTLg0KPj4+IEJ5
IGRvaW5nIHRoaXMgd2UgY2FuIGdyZWF0bHkgaW1wcm92ZSB0aGUgY2FjaGUgbG9jYWxpdHkgb2Yg
dGhlIHBhZ2VzIHdoaWxlDQo+Pj4gd2UgZG8gc2V2ZXJhbCBsb29wcyBvdmVyIHRoZW0gaW4gdGhl
IGluaXQgYW5kIGZyZWVpbmcgcHJvY2Vzcy4NCj4+Pg0KPj4+IFdlIGFyZSBhYmxlIHRvIHRpZ2h0
ZW4gdGhlIGxvb3BzIGFzIGEgcmVzdWx0IHNpbmNlIHdlIG9ubHkgcmVhbGx5IG5lZWQgdGhlDQo+
Pj4gY2hlY2tzIGZvciBmaXJzdF9pbml0X3BmbiBpbiBvdXIgZmlyc3QgaXRlcmF0aW9uIGFuZCBh
ZnRlciB0aGF0IHdlIGNhbg0KPj4+IGFzc3VtZSB0aGF0IGFsbCBmdXR1cmUgdmFsdWVzIHdpbGwg
YmUgZ3JlYXRlciB0aGFuIHRoaXMuIFNvIEkgaGF2ZSBhZGRlZCBhDQo+Pj4gZnVuY3Rpb24gY2Fs
bGVkIGRlZmVycmVkX2luaXRfbWVtX3Bmbl9yYW5nZV9pbl96b25lIHRoYXQgcHJpbWVzIHRoZQ0K
Pj4+IGl0ZXJhdG9ycyBhbmQgaWYgaXQgZmFpbHMgd2UgY2FuIGp1c3QgZXhpdC4NCj4+Pg0KPj4+
IE9uIG15IHg4Nl82NCB0ZXN0IHN5c3RlbSB3aXRoIDM4NEdCIG9mIG1lbW9yeSBwZXIgbm9kZSBJ
IHNhdyBhIHJlZHVjdGlvbiBpbg0KPj4+IGluaXRpYWxpemF0aW9uIHRpbWUgZnJvbSAxLjg1cyB0
byAxLjM4cyBhcyBhIHJlc3VsdCBvZiB0aGlzIHBhdGNoLg0KPj4+DQo+Pj4gU2lnbmVkLW9mZi1i
eTogQWxleGFuZGVyIER1eWNrIDxhbGV4YW5kZXIuaC5kdXlja0BsaW51eC5pbnRlbC5jb20+DQo+
Pg0KPj4gSGkgQWxleCwNCj4+DQo+PiBDb3VsZCB5b3UgcGxlYXNlIHNwbGl0IHRoaXMgcGF0Y2gg
aW50byB0d28gcGFydHM6DQo+Pg0KPj4gMS4gQWRkIGRlZmVycmVkX2luaXRfbWF4b3JkZXIoKQ0K
Pj4gMi4gQWRkIG1lbWJsb2NrIGl0ZXJhdG9yPw0KPj4NCj4+IFRoaXMgd291bGQgYWxsb3cgYSBi
ZXR0ZXIgYmlzZWN0aW5nIGluIGNhc2Ugb2YgcHJvYmxlbXMuIENoYW5pbmcgdHdvDQo+PiBsb29w
cyBpbnRvIGRlZmVycmVkX2luaXRfbWF4b3JkZXIoKSB3aGlsZSBhIGdvb2QgaWRlYSwgaXMgc3Rp
bGwNCj4+IG5vbi10cml2aWFsIGFuZCBtaWdodCBsZWFkIHRvIGJ1Z3MuDQo+Pg0KPj4gVGhhbmsg
eW91LA0KPj4gUGF2ZWwNCj4gDQo+IEkgY2FuIGRvIHRoYXQsIGJ1dCBJIHdpbGwgbmVlZCB0byBm
bGlwIHRoZSBvcmRlci4gSSB3aWxsIGFkZCB0aGUgbmV3DQo+IGl0ZXJhdG9yIGZpcnN0IGFuZCB0
aGVuIGRlZmVycmVkX2luaXRfbWF4b3JkZXIuIE90aGVyd2lzZSB0aGUNCj4gaW50ZXJtZWRpYXRl
IHN0ZXAgZW5kcyB1cCBiZWluZyB0b28gbXVjaCB0aHJvdy1hd2F5IGNvZGUuDQoNClRoYXQgc291
bmRzIGdvb2QuDQoNClRoYW5rIHlvdSwNClBhdmVsDQoNCj4gDQo+IC0gQWxleA0KPiA=
