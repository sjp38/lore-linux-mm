Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E0EF36B01B2
	for <linux-mm@kvack.org>; Sun, 23 May 2010 09:15:43 -0400 (EDT)
From: "Shi, Alex" <alex.shi@intel.com>
Date: Sun, 23 May 2010 21:15:36 +0800
Subject: RE: [PATCH v2] slub: move kmem_cache_node into it's own cacheline
Message-ID: <6E3BC7F7C9A4BF4286DD4C043110F30B0B596908DB@shsmsx502.ccr.corp.intel.com>
References: <20100521214135.23902.55360.stgit@gitlad.jf.intel.com>
 <4BF79761.5000402@cs.helsinki.fi>
In-Reply-To: <4BF79761.5000402@cs.helsinki.fi>
Content-Language: en-US
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>, "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Cc: "cl@linux.com" <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "yanmin_zhang@linux.intel.com" <yanmin_zhang@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rjw@sisk.pl" <rjw@sisk.pl>
List-ID: <linux-mm.kvack.org>

c3VyZS4gZ2xhZCB0byBhIGZpeCBvbiB0aGlzISANCiANCg0KLS0tLS1PcmlnaW5hbCBNZXNzYWdl
LS0tLS0NCkZyb206IFBla2thIEVuYmVyZyBbbWFpbHRvOnBlbmJlcmdAY3MuaGVsc2lua2kuZmld
IA0KU2VudDogMjAxMMTqNdTCMjLI1SAxNjozNg0KVG86IER1eWNrLCBBbGV4YW5kZXIgSA0KQ2M6
IGNsQGxpbnV4LmNvbTsgbGludXgtbW1Aa3ZhY2sub3JnOyBTaGksIEFsZXg7IHlhbm1pbl96aGFu
Z0BsaW51eC5pbnRlbC5jb207IGFrcG1AbGludXgtZm91bmRhdGlvbi5vcmc7IGxpbnV4LWtlcm5l
bEB2Z2VyLmtlcm5lbC5vcmc7IHJqd0BzaXNrLnBsDQpTdWJqZWN0OiBSZTogW1BBVENIIHYyXSBz
bHViOiBtb3ZlIGttZW1fY2FjaGVfbm9kZSBpbnRvIGl0J3Mgb3duIGNhY2hlbGluZQ0KDQpBbGV4
YW5kZXIgRHV5Y2sgd3JvdGU6DQo+IFRoaXMgcGF0Y2ggaXMgbWVhbnQgdG8gaW1wcm92ZSB0aGUg
cGVyZm9ybWFuY2Ugb2YgU0xVQiBieSBtb3ZpbmcgdGhlIA0KPiBsb2NhbCBrbWVtX2NhY2hlX25v
ZGUgbG9jayBpbnRvIGl0J3Mgb3duIGNhY2hlbGluZSBzZXBhcmF0ZSBmcm9tIGttZW1fY2FjaGUu
DQo+IFRoaXMgaXMgYWNjb21wbGlzaGVkIGJ5IHNpbXBseSByZW1vdmluZyB0aGUgbG9jYWxfbm9k
ZSB3aGVuIE5VTUEgaXMgZW5hYmxlZC4NCj4gDQo+IE9uIG15IHN5c3RlbSB3aXRoIDIgbm9kZXMg
SSBzYXcgYXJvdW5kIGEgNSUgcGVyZm9ybWFuY2UgaW5jcmVhc2Ugdy8gDQo+IGhhY2tiZW5jaCB0
aW1lcyBkcm9wcGluZyBmcm9tIDYuMiBzZWNvbmRzIHRvIDUuOSBzZWNvbmRzIG9uIGF2ZXJhZ2Uu
ICANCj4gSSBzdXNwZWN0IHRoZSBwZXJmb3JtYW5jZSBnYWluIHdvdWxkIGluY3JlYXNlIGFzIHRo
ZSBudW1iZXIgb2Ygbm9kZXMgDQo+IGluY3JlYXNlcywgYnV0IEkgZG8gbm90IGhhdmUgdGhlIGRh
dGEgdG8gY3VycmVudGx5IGJhY2sgdGhhdCB1cC4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IEFsZXhh
bmRlciBEdXljayA8YWxleGFuZGVyLmguZHV5Y2tAaW50ZWwuY29tPg0KDQpUaGFua3MgZm9yIHRo
ZSBmaXgsIEFsZXhhbmRlciENCg0KWWFubWluIGFuZCBBbGV4LCBjYW4gSSBoYXZlIHlvdXIgVGVz
dGVkLWJ5IG9yIEFja2VkLWJ5IHBsZWFzZSBzbyB3ZSBjYW4gY2xvc2UgIltCdWcgIzE1NzEzXSBo
YWNrYmVuY2ggcmVncmVzc2lvbiBkdWUgdG8gY29tbWl0IDlkZmM2ZTY4YmZlNmUiIA0KYWZ0ZXIg
dGhpcyBwYXRjaCBpcyBtZXJnZWQ/DQoNCgkJCVBla2thDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
