Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 72891800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 23:01:48 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id h5so3897195pgv.21
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 20:01:48 -0800 (PST)
Received: from esa4.hgst.iphmx.com (esa4.hgst.iphmx.com. [216.71.154.42])
        by mx.google.com with ESMTPS id a30si1003149pgn.599.2018.01.24.20.01.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 20:01:47 -0800 (PST)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: [LSF/MM TOPIC] Filesystem-DAX, page-pinning, and RDMA
Date: Thu, 25 Jan 2018 04:01:43 +0000
Message-ID: <1516852902.3724.4.camel@wdc.com>
References: <CAPcyv4gQNM9RbTbRWKnG6Vby_CW9CJ9EZTARsVNi=9cas7ZR2A@mail.gmail.com>
In-Reply-To: <CAPcyv4gQNM9RbTbRWKnG6Vby_CW9CJ9EZTARsVNi=9cas7ZR2A@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <421B4EAE84F4C14BB9A74F1146530B6F@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>
Cc: "jgg@mellanox.com" <jgg@mellanox.com>, "hch@infradead.org" <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

T24gV2VkLCAyMDE4LTAxLTI0IGF0IDE5OjU2IC0wODAwLCBEYW4gV2lsbGlhbXMgd3JvdGU6DQo+
IFRoZSBnZXRfdXNlcl9wYWdlc19sb25ndGVybSgpIGFwaSB3YXMgcmVjZW50bHkgYWRkZWQgYXMg
YSBzdG9wLWdhcA0KPiBtZWFzdXJlIHRvIHByZXZlbnQgYXBwbGljYXRpb25zIGZyb20gZ3Jvd2lu
ZyBkZXBlbmRlbmNpZXMgb24gdGhlDQo+IGFiaWxpdHkgdG8gdG8gcGluIERBWC1tYXBwZWQgZmls
ZXN5c3RlbSBibG9ja3MgZm9yIFJETUEgaW5kZWZpbml0ZWx5DQo+IHdpdGggbm8gb25nb2luZyBj
b29yZGluYXRpb24gd2l0aCB0aGUgZmlsZXN5c3RlbS4gVGhpcyAnbG9uZ3Rlcm0nDQo+IHBpbm5p
bmcgaXMgYWxzbyBwcm9ibGVtYXRpYyBmb3IgdGhlIG5vbi1EQVggVk1BIGNhc2Ugd2hlcmUgdGhl
IGNvcmUtbW0NCj4gbmVlZHMgYSB0aW1lIGJvdW5kZWQgd2F5IHRvIHJldm9rZSBhIHBpbiBhbmQg
bWFuaXB1bGF0ZSB0aGUgcGh5c2ljYWwNCj4gcGFnZXMuIFdoaWxlIGV4aXN0aW5nIFJETUEgYXBw
bGljYXRpb25zIGhhdmUgYWxyZWFkeSBncm93biB0aGUNCj4gYXNzdW1wdGlvbiB0aGF0IHRoZXkg
Y2FuIHBpbiBwYWdlLWNhY2hlIHBhZ2VzIGluZGVmaW5pdGVseSwgdGhlIGZhY3QNCj4gdGhhdCB3
ZSBhcmUgYnJlYWtpbmcgdGhpcyBhc3N1bXB0aW9uIGZvciBmaWxlc3lzdGVtLWRheCBwcmVzZW50
cyBhbg0KPiBvcHBvcnR1bml0eSB0byBkZXByZWNhdGUgdGhlICdpbmRlZmluaXRlIHBpbicgbWVj
aGFuaXNtcyBhbmQgbW92ZSB0byBhDQo+IGdlbmVyYWwgaW50ZXJmYWNlIHRoYXQgc3VwcG9ydHMg
cGluIHJldm9jYXRpb24uDQo+IA0KPiBXaGlsZSBSRE1BIG1heSBncm93IGFuIGV4cGxpY2l0IElu
ZmluaWJhbmQtdmVyYiBmb3IgdGhpcyAnbWVtb3J5DQo+IHJlZ2lzdHJhdGlvbiB3aXRoIGxlYXNl
JyBzZW1hbnRpYywgaXQgc2VlbXMgdGhhdCB0aGlzIHByb2JsZW0gaXMNCj4gYmlnZ2VyIHRoYW4g
anVzdCBSRE1BLiBBdCBMU0YvTU0gaXQgd291bGQgYmUgdXNlZnVsIHRvIGhhdmUgYQ0KPiBkaXNj
dXNzaW9uIGJldHdlZW4gZnMsIG1tLCBkYXgsIGFuZCBSRE1BIGZvbGtzIGFib3V0IGFkZHJlc3Np
bmcgdGhpcw0KPiBwcm9ibGVtIGF0IHRoZSBjb3JlIGxldmVsLg0KPiANCj4gUGFydGljdWxhciBw
ZW9wbGUgdGhhdCB3b3VsZCBiZSB1c2VmdWwgdG8gaGF2ZSBpbiBhdHRlbmRhbmNlIGFyZQ0KPiBN
aWNoYWwgSG9ja28sIENocmlzdG9waCBIZWxsd2lnLCBhbmQgSmFzb24gR3VudGhvcnBlIChjYydk
KS4NCg0KSXMgb24gZGVtYW5kIHBhZ2luZyBzdWZmaWNpZW50IGFzIGEgc29sdXRpb24gZm9yIHlv
dXIgdXNlIGNhc2Ugb3IgZG8NCnlvdSBwZXJoYXBzIG5lZWQgc29tZXRoaW5nIGRpZmZlcmVudD8g
U2VlIGFsc28NCmh0dHBzOi8vd3d3Lm9wZW5mYWJyaWNzLm9yZy9pbWFnZXMvZXZlbnRwcmVzb3Mv
d29ya3Nob3BzMjAxMy8yMDEzX1dvcmtzaG9wX1R1ZXNfMDkzMF9saXNzX29kcC5wZGYNCg0KVGhh
bmtzLA0KDQpCYXJ0Lg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
