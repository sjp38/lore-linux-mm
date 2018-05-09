Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id D01236B0517
	for <linux-mm@kvack.org>; Wed,  9 May 2018 10:04:48 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id g138so26330728qke.22
        for <linux-mm@kvack.org>; Wed, 09 May 2018 07:04:48 -0700 (PDT)
Received: from mail1.bemta8.messagelabs.com (mail1.bemta8.messagelabs.com. [216.82.243.198])
        by mx.google.com with ESMTPS id y7-v6si2438438qvl.90.2018.05.09.07.04.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 07:04:47 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: RE: [External] [RFC PATCH v1 3/6] mm, zone_type: create ZONE_NVM and
 fill into GFP_ZONE_TABLE
Date: Wed, 9 May 2018 14:04:21 +0000
Message-ID: <HK2PR03MB168425F6D00C30918169C77C92990@HK2PR03MB1684.apcprd03.prod.outlook.com>
References: <1525746628-114136-1-git-send-email-yehs1@lenovo.com>
 <1525746628-114136-4-git-send-email-yehs1@lenovo.com>
 <HK2PR03MB1684653383FFEDAE9B41A548929A0@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <ce3a6f37-3b13-0c35-6895-35156c7a290c@infradead.org>
 <HK2PR03MB16847B78265A033C7310DDCB92990@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <20180509114712.GP32366@dhcp22.suse.cz>
In-Reply-To: <20180509114712.GP32366@dhcp22.suse.cz>
Content-Language: zh-CN
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "willy@infradead.org" <willy@infradead.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "pasha.tatashin@oracle.com" <pasha.tatashin@oracle.com>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "penguin-kernel@I-love.SAKURA.ne.jp" <penguin-kernel@I-love.SAKURA.ne.jp>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, Ocean HY1 He <hehy1@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

PiBGcm9tOiBvd25lci1saW51eC1tbUBrdmFjay5vcmcgW21haWx0bzpvd25lci1saW51eC1tbUBr
dmFjay5vcmddIE9uIEJlaGFsZiBPZiBNaWNoYWwgSG9ja28NCj4gDQo+IE9uIFdlZCAwOS0wNS0x
OCAwNDoyMjoxMCwgSHVhaXNoZW5nIEhTMSBZZSB3cm90ZToNCj4gPg0KPiA+ID4gT24gMDUvMDcv
MjAxOCAwNzozMyBQTSwgSHVhaXNoZW5nIEhTMSBZZSB3cm90ZToNCj4gPiA+ID4gZGlmZiAtLWdp
dCBhL21tL0tjb25maWcgYi9tbS9LY29uZmlnDQo+ID4gPiA+IGluZGV4IGM3ODJlOGYuLjVmZTFm
NjMgMTAwNjQ0DQo+ID4gPiA+IC0tLSBhL21tL0tjb25maWcNCj4gPiA+ID4gKysrIGIvbW0vS2Nv
bmZpZw0KPiA+ID4gPiBAQCAtNjg3LDYgKzY4NywyMiBAQCBjb25maWcgWk9ORV9ERVZJQ0UNCj4g
PiA+ID4NCj4gPiA+ID4gK2NvbmZpZyBaT05FX05WTQ0KPiA+ID4gPiArCWJvb2wgIk1hbmFnZSBO
VkRJTU0gKHBtZW0pIGJ5IG1lbW9yeSBtYW5hZ2VtZW50IChFWFBFUklNRU5UQUwpIg0KPiA+ID4g
PiArCWRlcGVuZHMgb24gTlVNQSAmJiBYODZfNjQNCj4gPiA+DQo+ID4gPiBIaSwNCj4gPiA+IEkn
bSBjdXJpb3VzIHdoeSB0aGlzIGRlcGVuZHMgb24gTlVNQS4gQ291bGRuJ3QgaXQgYmUgdXNlZnVs
IGluIG5vbi1OVU1BDQo+ID4gPiAoaS5lLiwgVU1BKSBjb25maWdzPw0KPiA+ID4NCj4gPiBJIHdy
b3RlIHRoZXNlIHBhdGNoZXMgd2l0aCB0d28gc29ja2V0cyB0ZXN0aW5nIHBsYXRmb3JtLCBhbmQg
dGhlcmUgYXJlIHR3byBERFJzIGFuZA0KPiB0d28gTlZESU1NcyBoYXZlIGJlZW4gaW5zdGFsbGVk
IHRvIGl0Lg0KPiA+IFNvLCBmb3IgZXZlcnkgc29ja2V0IGl0IGhhcyBvbmUgRERSIGFuZCBvbmUg
TlZESU1NIHdpdGggaXQuIEhlcmUgaXMgbWVtb3J5IHJlZ2lvbg0KPiBmcm9tIG1lbWJsb2NrLCB5
b3UgY2FuIGdldCBpdHMgZGlzdHJpYnV0aW9uLg0KPiA+DQo+ID4gIDQzNSBbICAgIDAuMDAwMDAw
XSBab25lIHJhbmdlczoNCj4gPiAgNDM2IFsgICAgMC4wMDAwMDBdICAgRE1BICAgICAgW21lbSAw
eDAwMDAwMDAwMDAwMDEwMDAtMHgwMDAwMDAwMDAwZmZmZmZmXQ0KPiA+ICA0MzcgWyAgICAwLjAw
MDAwMF0gICBETUEzMiAgICBbbWVtIDB4MDAwMDAwMDAwMTAwMDAwMC0weDAwMDAwMDAwZmZmZmZm
ZmZdDQo+ID4gIDQzOCBbICAgIDAuMDAwMDAwXSAgIE5vcm1hbCAgIFttZW0gMHgwMDAwMDAwMTAw
MDAwMDAwLTB4MDAwMDAwNDZiZmZmZmZmZl0NCj4gPiAgNDM5IFsgICAgMC4wMDAwMDBdICAgTlZN
ICAgICAgW21lbSAweDAwMDAwMDA0NDAwMDAwMDAtMHgwMDAwMDA0NmJmZmZmZmZmXQ0KPiA+ICA0
NDAgWyAgICAwLjAwMDAwMF0gICBEZXZpY2UgICBlbXB0eQ0KPiA+ICA0NDEgWyAgICAwLjAwMDAw
MF0gTW92YWJsZSB6b25lIHN0YXJ0IGZvciBlYWNoIG5vZGUNCj4gPiAgNDQyIFsgICAgMC4wMDAw
MDBdIEVhcmx5IG1lbW9yeSBub2RlIHJhbmdlcw0KPiA+ICA0NDMgWyAgICAwLjAwMDAwMF0gICBu
b2RlICAgMDogW21lbSAweDAwMDAwMDAwMDAwMDEwMDAtMHgwMDAwMDAwMDAwMDlmZmZmXQ0KPiA+
ICA0NDQgWyAgICAwLjAwMDAwMF0gICBub2RlICAgMDogW21lbSAweDAwMDAwMDAwMDAxMDAwMDAt
MHgwMDAwMDAwMGE2OWMyZmZmXQ0KPiA+ICA0NDUgWyAgICAwLjAwMDAwMF0gICBub2RlICAgMDog
W21lbSAweDAwMDAwMDAwYTc2NTQwMDAtMHgwMDAwMDAwMGE4NWVlZmZmXQ0KPiA+ICA0NDYgWyAg
ICAwLjAwMDAwMF0gICBub2RlICAgMDogW21lbSAweDAwMDAwMDAwYWIzOTkwMDAtMHgwMDAwMDAw
MGFmM2Y2ZmZmXQ0KPiA+ICA0NDcgWyAgICAwLjAwMDAwMF0gICBub2RlICAgMDogW21lbSAweDAw
MDAwMDAwYWY0MjkwMDAtMHgwMDAwMDAwMGFmN2ZmZmZmXQ0KPiA+ICA0NDggWyAgICAwLjAwMDAw
MF0gICBub2RlICAgMDogW21lbSAweDAwMDAwMDAxMDAwMDAwMDAtMHgwMDAwMDAwNDNmZmZmZmZm
XQlOb3JtYWwgMA0KPiA+ICA0NDkgWyAgICAwLjAwMDAwMF0gICBub2RlICAgMDogW21lbSAweDAw
MDAwMDA0NDAwMDAwMDAtMHgwMDAwMDAyMzdmZmZmZmZmXQlOVkRJTU0gMA0KPiA+ICA0NTAgWyAg
ICAwLjAwMDAwMF0gICBub2RlICAgMTogW21lbSAweDAwMDAwMDIzODAwMDAwMDAtMHgwMDAwMDAy
NzdmZmZmZmZmXQlOb3JtYWwgMQ0KPiA+ICA0NTEgWyAgICAwLjAwMDAwMF0gICBub2RlICAgMTog
W21lbSAweDAwMDAwMDI3ODAwMDAwMDAtMHgwMDAwMDA0NmJmZmZmZmZmXQlOVkRJTU0gMQ0KPiA+
DQo+ID4gSWYgd2UgZGlzYWJsZSBOVU1BLCB0aGVyZSBpcyBhIHJlc3VsdCBhcyBOb3JtYWwgYW4g
TlZESU1NIHpvbmVzIHdpbGwgYmUgb3ZlcmxhcHBpbmcNCj4gd2l0aCBlYWNoIG90aGVyLg0KPiA+
IEN1cnJlbnQgbW0gdHJlYXRzIGFsbCBtZW1vcnkgcmVnaW9ucyBlcXVhbGx5LCBpdCBkaXZpZGVz
IHpvbmVzIGp1c3QgYnkgc2l6ZSwgbGlrZQ0KPiAxNk0gZm9yIERNQSwgNEcgZm9yIERNQTMyLCBh
bmQgb3RoZXJzIGFib3ZlIGZvciBOb3JtYWwuDQo+ID4gVGhlIHNwYW5uZWQgcmFuZ2Ugb2YgYWxs
IHpvbmVzIGNvdWxkbid0IGJlIG92ZXJsYXBwZWQuDQo+IA0KPiBObywgdGhpcyBpcyBub3QgY29y
cmVjdC4gWm9uZXMgY2FuIG92ZXJsYXAuDQoNCkhpIE1pY2hhbCwNCg0KVGhhbmtzIGZvciBwb2lu
dGluZyBpdCBvdXQuDQpCdXQgZnVuY3Rpb24gem9uZV9zaXplc19pbml0IGRlY2lkZXMgYXJjaF96
b25lX2xvd2VzdC9oaWdoZXN0X3Bvc3NpYmxlX3BmbidzIHNpemUgYnkgbWF4X2xvd19wZm4sIHRo
ZW4gZnJlZV9hcmVhX2luaXRfbm9kZXMvbm9kZSBhcmUgcmVzcG9uc2libGUgZm9yIGNhbGN1bGF0
aW5nIHRoZSBzcGFubmVkIHNpemUgb2Ygem9uZXMgZnJvbSBtZW1ibG9jayBtZW1vcnkgcmVnaW9u
cy4NClNvLCBaT05FX0RNQSBhbmQgWk9ORV9ETUEzMiBhbmQgWk9ORV9OT1JNQUwgaGF2ZSBzZXBh
cmF0ZSBhZGRyZXNzIHNjb3BlLiBIb3cgY2FuIHRoZXkgYmUgb3ZlcmxhcHBlZCB3aXRoIGVhY2gg
b3RoZXI/DQoNClNpbmNlcmVseSwNCkh1YWlzaGVuZyBZZSB8INK2u7PKpA0KTGludXgga2VybmVs
IHwgTGVub3ZvDQoNCg0KDQoNCg0KDQoNCg0KDQoNCg0KDQoNCg0KDQoNCg0K
