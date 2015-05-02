Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 67B616B0038
	for <linux-mm@kvack.org>; Sat,  2 May 2015 07:55:14 -0400 (EDT)
Received: by obbkp3 with SMTP id kp3so25014379obb.3
        for <linux-mm@kvack.org>; Sat, 02 May 2015 04:55:14 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id z66si4999503oiz.40.2015.05.02.04.55.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 May 2015 04:55:13 -0700 (PDT)
From: "Elliott, Robert (Server Storage)" <Elliott@hp.com>
Subject: RE: [PATCH 0/13] Parallel struct page initialisation v4
Date: Sat, 2 May 2015 11:52:18 +0000
Message-ID: <94D0CD8314A33A4D9D801C0FE68B40295A8CE70F@G9W0745.americas.hpqcorp.net>
References: <553FD39C.2070503@sgi.com> <1430410227.8193.0@cpanel21.proisp.no>
In-Reply-To: <1430410227.8193.0@cpanel21.proisp.no>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel J Blueman <daniel@numascale.com>, nzimmer <nzimmer@sgi.com>, Mel
 Gorman <mgorman@suse.de>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, "Long, Wai
 Man" <waiman.long@hp.com>, "Norton, Scott J" <scott.norton@hp.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 'Steffen Persvold' <sp@numascale.com>, "Boaz Harrosh (boaz@plexistor.com)" <boaz@plexistor.com>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

DQo+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+IEZyb206IGxpbnV4LWtlcm5lbC1vd25l
ckB2Z2VyLmtlcm5lbC5vcmcgW21haWx0bzpsaW51eC1rZXJuZWwtDQo+IG93bmVyQHZnZXIua2Vy
bmVsLm9yZ10gT24gQmVoYWxmIE9mIERhbmllbCBKIEJsdWVtYW4NCj4gU2VudDogVGh1cnNkYXks
IEFwcmlsIDMwLCAyMDE1IDExOjEwIEFNDQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggMC8xM10gUGFy
YWxsZWwgc3RydWN0IHBhZ2UgaW5pdGlhbGlzYXRpb24gdjQNCi4uLg0KPiBPbiBhIDdUQiwgMTcy
OC1jb3JlIE51bWFDb25uZWN0IHN5c3RlbSB3aXRoIDEwOCBOVU1BIG5vZGVzLCB3ZSdyZQ0KPiBz
ZWVpbmcgc3RvY2sgNC4wIGJvb3QgaW4gNzEzNnMuIFRoaXMgZHJvcHMgdG8gMjE1OXMsIG9yIGEg
NzAlIHJlZHVjdGlvbg0KPiB3aXRoIHRoaXMgcGF0Y2hzZXQuIE5vbi10ZW1wb3JhbCBQTUQgaW5p
dCBbMV0gZHJvcHMgdGhpcyB0byAxMDQ1cy4NCj4gDQo+IE5hdGhhbiwgd2hhdCBkbyB5b3UgZ3V5
cyBzZWUgd2l0aCB0aGUgbm9uLXRlbXBvcmFsIFBNRCBwYXRjaCBbMV0/IERvDQo+IGFkZCBhIHNm
ZW5jZSBhdCB0aGUgZW5kZSBsYWJlbCBpZiB5b3UgbWFudWFsbHkgcGF0Y2guDQo+IA0KLi4uDQo+
IFsxXSBodHRwczovL2xrbWwub3JnL2xrbWwvMjAxNS80LzIzLzM1MA0KDQpGcm9tIHRoYXQgcG9z
dDoNCj4gK2xvb3BfNjQ6DQo+ICsJZGVjcSAgJXJjeA0KPiArCW1vdm50aQklcmF4LCglcmRpKQ0K
PiArCW1vdm50aQklcmF4LDgoJXJkaSkNCj4gKwltb3ZudGkJJXJheCwxNiglcmRpKQ0KPiArCW1v
dm50aQklcmF4LDI0KCVyZGkpDQo+ICsJbW92bnRpCSVyYXgsMzIoJXJkaSkNCj4gKwltb3ZudGkJ
JXJheCw0MCglcmRpKQ0KPiArCW1vdm50aQklcmF4LDQ4KCVyZGkpDQo+ICsJbW92bnRpCSVyYXgs
NTYoJXJkaSkNCj4gKwlsZWFxICA2NCglcmRpKSwlcmRpDQo+ICsJam56ICAgIGxvb3BfNjQNCg0K
VGhlcmUgYXJlIHNvbWUgZXZlbiBtb3JlIGVmZmljaWVudCBpbnN0cnVjdGlvbnMgYXZhaWxhYmxl
IGluIHg4NiwNCmRlcGVuZGluZyBvbiB0aGUgQ1BVIGZlYXR1cmVzOg0KKiBtb3ZudGkJCTggYnl0
ZQ0KKiBtb3ZudGRxICV4bW0JCTE2IGJ5dGUsIFNTRQ0KKiB2bW92bnRkcSAleW1tCTMyIGJ5dGUs
IEFWWA0KKiB2bW92bnRkcSAlem1tCTY0IGJ5dGUsIEFWWC01MTIgKGZvcnRoY29taW5nKQ0KDQpU
aGUgbGFzdCB3aWxsIHRyYW5zZmVyIGEgZnVsbCBjYWNoZSBsaW5lIGF0IGEgdGltZS4NCg0KRm9y
IE5WRElNTXMsIHRoZSBuZCBwbWVtIGRyaXZlciBpcyBhbHNvIGluIG5lZWQgb2YgbWVtY3B5IGZ1
bmN0aW9ucyB0aGF0IA0KdXNlIHRoZXNlIG5vbi10ZW1wb3JhbCBpbnN0cnVjdGlvbnMsIGJvdGgg
Zm9yIHBlcmZvcm1hbmNlIGFuZCByZWxpYWJpbGl0eS4NCldlIGFsc28gbmVlZCB0byBzcGVlZCB1
cCBfX2NsZWFyX3BhZ2UgYW5kIGNvcHlfdXNlcl9lbmhhbmNlZF9zdHJpbmcgc28NCnVzZXJzcGFj
ZSBhY2Nlc3NlcyB0aHJvdWdoIHRoZSBwYWdlIGNhY2hlIGNhbiBrZWVwIHVwLg0KaHR0cHM6Ly9s
a21sLm9yZy9sa21sLzIwMTUvNC8yLzQ1MyBpcyBvbmUgb2YgdGhlIHRocmVhZHMgb24gdGhhdCB0
b3BpYy4NCg0KU29tZSByZXN1bHRzIEkndmUgZ290dGVuIHRoZXJlIHVuZGVyIGRpZmZlcmVudCBj
YWNoZSBhdHRyaWJ1dGVzDQooaW4gdGVybXMgb2YgNCBLaUIgSU9QUyk6DQoNCjE2LWJ5dGUgbW92
bnRkcToNClVDIHdyaXRlIGlvcHM9Njk3ODcyICg2OTcuODcyIEspKDAuNjk3ODcyIE0pDQpXQiB3
cml0ZSBpb3BzPTk3NDU4MDAgKDk3NDUuOCBLKSg5Ljc0NTggTSkNCldDIHdyaXRlIGlvcHM9OTgw
MTgwMCAoOTgwMS44IEspKDkuODAxOCBNKQ0KV1Qgd3JpdGUgaW9wcz05ODEyNDAwICg5ODEyLjQg
SykoOS44MTI0IE0pDQoNCjMyLWJ5dGUgdm1vdm50ZHE6DQpVQyB3cml0ZSBpb3BzPTEyNzQ0MDAg
KDEyNzQuNCBLKSgxLjI3NDQgTSkNCldCIHdyaXRlIGlvcHM9MTAyNTkwMDAgKDEwMjU5IEspKDEw
LjI1OSBNKQ0KV0Mgd3JpdGUgaW9wcz0xMDI4NjAwMCAoMTAyODYgSykoMTAuMjg2IE0pDQpXVCB3
cml0ZSBpb3BzPTEwMjk0MDAwICgxMDI5NCBLKSgxMC4yOTQgTSkNCg0KLS0tDQpSb2JlcnQgRWxs
aW90dCwgSFAgU2VydmVyIFN0b3JhZ2UNCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
