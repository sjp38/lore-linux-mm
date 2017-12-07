Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 93FE36B0275
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 14:20:59 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id z130so2157424lff.18
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 11:20:59 -0800 (PST)
Received: from sesbmg23.ericsson.net (sesbmg23.ericsson.net. [193.180.251.37])
        by mx.google.com with ESMTPS id q87si2175454lfd.119.2017.12.07.11.20.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 11:20:58 -0800 (PST)
From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: [PATCH 8/8] net: tipc: remove unused hardirq.h
Date: Thu, 7 Dec 2017 19:20:44 +0000
Message-ID: <AM4PR07MB17147A3C4885EE59CFA58BDA9A330@AM4PR07MB1714.eurprd07.prod.outlook.com>
References: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com>
 <1510959741-31109-8-git-send-email-yang.s@alibaba-inc.com>
 <da42d136-4e51-6d04-4120-cb53df03c661@alibaba-inc.com>
In-Reply-To: <da42d136-4e51-6d04-4120-cb53df03c661@alibaba-inc.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Ying Xue <ying.xue@windriver.com>, "David S.
 Miller" <davem@davemloft.net>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogbmV0ZGV2LW93bmVyQHZn
ZXIua2VybmVsLm9yZyBbbWFpbHRvOm5ldGRldi0NCj4gb3duZXJAdmdlci5rZXJuZWwub3JnXSBP
biBCZWhhbGYgT2YgWWFuZyBTaGkNCj4gU2VudDogVGh1cnNkYXksIERlY2VtYmVyIDA3LCAyMDE3
IDE0OjE2DQo+IFRvOiBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnDQo+IENjOiBsaW51eC1t
bUBrdmFjay5vcmc7IGxpbnV4LWZzZGV2ZWxAdmdlci5rZXJuZWwub3JnOyBsaW51eC0NCj4gY3J5
cHRvQHZnZXIua2VybmVsLm9yZzsgbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsgSm9uIE1hbG95DQo+
IDxqb24ubWFsb3lAZXJpY3Nzb24uY29tPjsgWWluZyBYdWUgPHlpbmcueHVlQHdpbmRyaXZlci5j
b20+OyBEYXZpZCBTLg0KPiBNaWxsZXIgPGRhdmVtQGRhdmVtbG9mdC5uZXQ+DQo+IFN1YmplY3Q6
IFJlOiBbUEFUQ0ggOC84XSBuZXQ6IHRpcGM6IHJlbW92ZSB1bnVzZWQgaGFyZGlycS5oDQo+IA0K
PiBIaSBmb2xrcywNCj4gDQo+IEFueSBjb21tZW50IG9uIHRoaXMgb25lPw0KDQpJZiBpdCBjb21w
aWxlcyBpdCBpcyBvayB3aXRoIG1lLiBEb24ndCBrbm93IHdoeSBpdCB3YXMgcHV0IHRoZXJlIGlu
IHRoZSBmaXJzdCBwbGFjZS4NCg0KLy8vam9uDQoNCj4gDQo+IFRoYW5rcywNCj4gWWFuZw0KPiAN
Cj4gDQo+IE9uIDExLzE3LzE3IDM6MDIgUE0sIFlhbmcgU2hpIHdyb3RlOg0KPiA+IFByZWVtcHQg
Y291bnRlciBBUElzIGhhdmUgYmVlbiBzcGxpdCBvdXQsIGN1cnJlbnRseSwgaGFyZGlycS5oIGp1
c3QNCj4gPiBpbmNsdWRlcyBpcnFfZW50ZXIvZXhpdCBBUElzIHdoaWNoIGFyZSBub3QgdXNlZCBi
eSBUSVBDIGF0IGFsbC4NCj4gPg0KPiA+IFNvLCByZW1vdmUgdGhlIHVudXNlZCBoYXJkaXJxLmgu
DQo+ID4NCj4gPiBTaWduZWQtb2ZmLWJ5OiBZYW5nIFNoaSA8eWFuZy5zQGFsaWJhYmEtaW5jLmNv
bT4NCj4gPiBDYzogSm9uIE1hbG95IDxqb24ubWFsb3lAZXJpY3Nzb24uY29tPg0KPiA+IENjOiBZ
aW5nIFh1ZSA8eWluZy54dWVAd2luZHJpdmVyLmNvbT4NCj4gPiBDYzogIkRhdmlkIFMuIE1pbGxl
ciIgPGRhdmVtQGRhdmVtbG9mdC5uZXQ+DQo+ID4gLS0tDQo+ID4gICBuZXQvdGlwYy9jb3JlLmgg
fCAxIC0NCj4gPiAgIDEgZmlsZSBjaGFuZ2VkLCAxIGRlbGV0aW9uKC0pDQo+ID4NCj4gPiBkaWZm
IC0tZ2l0IGEvbmV0L3RpcGMvY29yZS5oIGIvbmV0L3RpcGMvY29yZS5oIGluZGV4IDVjYzUzOTgu
LjA5OWUwNzINCj4gPiAxMDA2NDQNCj4gPiAtLS0gYS9uZXQvdGlwYy9jb3JlLmgNCj4gPiArKysg
Yi9uZXQvdGlwYy9jb3JlLmgNCj4gPiBAQCAtNDksNyArNDksNiBAQA0KPiA+ICAgI2luY2x1ZGUg
PGxpbnV4L3VhY2Nlc3MuaD4NCj4gPiAgICNpbmNsdWRlIDxsaW51eC9pbnRlcnJ1cHQuaD4NCj4g
PiAgICNpbmNsdWRlIDxsaW51eC9hdG9taWMuaD4NCj4gPiAtI2luY2x1ZGUgPGFzbS9oYXJkaXJx
Lmg+DQo+ID4gICAjaW5jbHVkZSA8bGludXgvbmV0ZGV2aWNlLmg+DQo+ID4gICAjaW5jbHVkZSA8
bGludXgvaW4uaD4NCj4gPiAgICNpbmNsdWRlIDxsaW51eC9saXN0Lmg+DQo+ID4NCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
