Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 86E056B0329
	for <linux-mm@kvack.org>; Wed,  9 May 2018 00:22:38 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id d11so25626262qkg.20
        for <linux-mm@kvack.org>; Tue, 08 May 2018 21:22:38 -0700 (PDT)
Received: from mail1.bemta8.messagelabs.com (mail1.bemta8.messagelabs.com. [216.82.243.201])
        by mx.google.com with ESMTPS id r68si9413537qkf.198.2018.05.08.21.22.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 21:22:37 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: RE: [External] [RFC PATCH v1 3/6] mm, zone_type: create ZONE_NVM and
 fill into GFP_ZONE_TABLE
Date: Wed, 9 May 2018 04:22:10 +0000
Message-ID: <HK2PR03MB16847B78265A033C7310DDCB92990@HK2PR03MB1684.apcprd03.prod.outlook.com>
References: <1525746628-114136-1-git-send-email-yehs1@lenovo.com>
 <1525746628-114136-4-git-send-email-yehs1@lenovo.com>
 <HK2PR03MB1684653383FFEDAE9B41A548929A0@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <ce3a6f37-3b13-0c35-6895-35156c7a290c@infradead.org>
In-Reply-To: <ce3a6f37-3b13-0c35-6895-35156c7a290c@infradead.org>
Content-Language: zh-CN
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "willy@infradead.org" <willy@infradead.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "pasha.tatashin@oracle.com" <pasha.tatashin@oracle.com>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "penguin-kernel@I-love.SAKURA.ne.jp" <penguin-kernel@I-love.SAKURA.ne.jp>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, Ocean HY1 He <hehy1@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

DQo+IE9uIDA1LzA3LzIwMTggMDc6MzMgUE0sIEh1YWlzaGVuZyBIUzEgWWUgd3JvdGU6DQo+ID4g
ZGlmZiAtLWdpdCBhL21tL0tjb25maWcgYi9tbS9LY29uZmlnDQo+ID4gaW5kZXggYzc4MmU4Zi4u
NWZlMWY2MyAxMDA2NDQNCj4gPiAtLS0gYS9tbS9LY29uZmlnDQo+ID4gKysrIGIvbW0vS2NvbmZp
Zw0KPiA+IEBAIC02ODcsNiArNjg3LDIyIEBAIGNvbmZpZyBaT05FX0RFVklDRQ0KPiA+DQo+ID4g
K2NvbmZpZyBaT05FX05WTQ0KPiA+ICsJYm9vbCAiTWFuYWdlIE5WRElNTSAocG1lbSkgYnkgbWVt
b3J5IG1hbmFnZW1lbnQgKEVYUEVSSU1FTlRBTCkiDQo+ID4gKwlkZXBlbmRzIG9uIE5VTUEgJiYg
WDg2XzY0DQo+IA0KPiBIaSwNCj4gSSdtIGN1cmlvdXMgd2h5IHRoaXMgZGVwZW5kcyBvbiBOVU1B
LiBDb3VsZG4ndCBpdCBiZSB1c2VmdWwgaW4gbm9uLU5VTUENCj4gKGkuZS4sIFVNQSkgY29uZmln
cz8NCj4gDQpJIHdyb3RlIHRoZXNlIHBhdGNoZXMgd2l0aCB0d28gc29ja2V0cyB0ZXN0aW5nIHBs
YXRmb3JtLCBhbmQgdGhlcmUgYXJlIHR3byBERFJzIGFuZCB0d28gTlZESU1NcyBoYXZlIGJlZW4g
aW5zdGFsbGVkIHRvIGl0Lg0KU28sIGZvciBldmVyeSBzb2NrZXQgaXQgaGFzIG9uZSBERFIgYW5k
IG9uZSBOVkRJTU0gd2l0aCBpdC4gSGVyZSBpcyBtZW1vcnkgcmVnaW9uIGZyb20gbWVtYmxvY2ss
IHlvdSBjYW4gZ2V0IGl0cyBkaXN0cmlidXRpb24uDQoNCiA0MzUgWyAgICAwLjAwMDAwMF0gWm9u
ZSByYW5nZXM6DQogNDM2IFsgICAgMC4wMDAwMDBdICAgRE1BICAgICAgW21lbSAweDAwMDAwMDAw
MDAwMDEwMDAtMHgwMDAwMDAwMDAwZmZmZmZmXQ0KIDQzNyBbICAgIDAuMDAwMDAwXSAgIERNQTMy
ICAgIFttZW0gMHgwMDAwMDAwMDAxMDAwMDAwLTB4MDAwMDAwMDBmZmZmZmZmZl0NCiA0MzggWyAg
ICAwLjAwMDAwMF0gICBOb3JtYWwgICBbbWVtIDB4MDAwMDAwMDEwMDAwMDAwMC0weDAwMDAwMDQ2
YmZmZmZmZmZdDQogNDM5IFsgICAgMC4wMDAwMDBdICAgTlZNICAgICAgW21lbSAweDAwMDAwMDA0
NDAwMDAwMDAtMHgwMDAwMDA0NmJmZmZmZmZmXQ0KIDQ0MCBbICAgIDAuMDAwMDAwXSAgIERldmlj
ZSAgIGVtcHR5DQogNDQxIFsgICAgMC4wMDAwMDBdIE1vdmFibGUgem9uZSBzdGFydCBmb3IgZWFj
aCBub2RlDQogNDQyIFsgICAgMC4wMDAwMDBdIEVhcmx5IG1lbW9yeSBub2RlIHJhbmdlcw0KIDQ0
MyBbICAgIDAuMDAwMDAwXSAgIG5vZGUgICAwOiBbbWVtIDB4MDAwMDAwMDAwMDAwMTAwMC0weDAw
MDAwMDAwMDAwOWZmZmZdDQogNDQ0IFsgICAgMC4wMDAwMDBdICAgbm9kZSAgIDA6IFttZW0gMHgw
MDAwMDAwMDAwMTAwMDAwLTB4MDAwMDAwMDBhNjljMmZmZl0NCiA0NDUgWyAgICAwLjAwMDAwMF0g
ICBub2RlICAgMDogW21lbSAweDAwMDAwMDAwYTc2NTQwMDAtMHgwMDAwMDAwMGE4NWVlZmZmXQ0K
IDQ0NiBbICAgIDAuMDAwMDAwXSAgIG5vZGUgICAwOiBbbWVtIDB4MDAwMDAwMDBhYjM5OTAwMC0w
eDAwMDAwMDAwYWYzZjZmZmZdDQogNDQ3IFsgICAgMC4wMDAwMDBdICAgbm9kZSAgIDA6IFttZW0g
MHgwMDAwMDAwMGFmNDI5MDAwLTB4MDAwMDAwMDBhZjdmZmZmZl0NCiA0NDggWyAgICAwLjAwMDAw
MF0gICBub2RlICAgMDogW21lbSAweDAwMDAwMDAxMDAwMDAwMDAtMHgwMDAwMDAwNDNmZmZmZmZm
XQlOb3JtYWwgMA0KIDQ0OSBbICAgIDAuMDAwMDAwXSAgIG5vZGUgICAwOiBbbWVtIDB4MDAwMDAw
MDQ0MDAwMDAwMC0weDAwMDAwMDIzN2ZmZmZmZmZdCU5WRElNTSAwDQogNDUwIFsgICAgMC4wMDAw
MDBdICAgbm9kZSAgIDE6IFttZW0gMHgwMDAwMDAyMzgwMDAwMDAwLTB4MDAwMDAwMjc3ZmZmZmZm
Zl0JTm9ybWFsIDENCiA0NTEgWyAgICAwLjAwMDAwMF0gICBub2RlICAgMTogW21lbSAweDAwMDAw
MDI3ODAwMDAwMDAtMHgwMDAwMDA0NmJmZmZmZmZmXQlOVkRJTU0gMQ0KDQpJZiB3ZSBkaXNhYmxl
IE5VTUEsIHRoZXJlIGlzIGEgcmVzdWx0IGFzIE5vcm1hbCBhbiBOVkRJTU0gem9uZXMgd2lsbCBi
ZSBvdmVybGFwcGluZyB3aXRoIGVhY2ggb3RoZXIuDQpDdXJyZW50IG1tIHRyZWF0cyBhbGwgbWVt
b3J5IHJlZ2lvbnMgZXF1YWxseSwgaXQgZGl2aWRlcyB6b25lcyBqdXN0IGJ5IHNpemUsIGxpa2Ug
MTZNIGZvciBETUEsIDRHIGZvciBETUEzMiwgYW5kIG90aGVycyBhYm92ZSBmb3IgTm9ybWFsLg0K
VGhlIHNwYW5uZWQgcmFuZ2Ugb2YgYWxsIHpvbmVzIGNvdWxkbid0IGJlIG92ZXJsYXBwZWQuDQoN
CklmIHdlIGVuYWJsZSBOVU1BLCBmb3IgZXZlcnkgc29ja2V0IGl0cyBERFIgYW5kIE5WRElNTSBh
cmUgc2VwYXJhdGVkLCB5b3UgY2FuIGZpbmQgdGhhdCBOVkRJTU0gcmVnaW9uIGFsd2F5cyBiZWhp
bmQgTm9ybWFsIHpvbmUuDQoNClNpbmNlcmVseSwNCkh1YWlzaGVuZyBZZSANCg==
