Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id B23746B0026
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 04:29:50 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t8-v6so6724614ply.22
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 01:29:50 -0700 (PDT)
Received: from baidu.com ([220.181.50.185])
        by mx.google.com with ESMTP id c11si1604851pgv.446.2018.04.03.01.29.48
        for <linux-mm@kvack.org>;
        Tue, 03 Apr 2018 01:29:49 -0700 (PDT)
From: "Li,Rongqing" <lirongqing@baidu.com>
Subject: re: [PATCH] mm: avoid the unnecessary waiting when force empty a
 cgroup
Date: Tue, 3 Apr 2018 08:29:39 +0000
Message-ID: <2AD939572F25A448A3AE3CAEA61328C23756E4F1@BC-MAIL-M28.internal.baidu.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

DQoNCj4gLS0tLS3Tyrz+1K28/i0tLS0tDQo+ILeivP7IyzogTWljaGFsIEhvY2tvIFttYWlsdG86
bWhvY2tvQGtlcm5lbC5vcmddDQo+ILeiy83KsbzkOiAyMDE4xOo01MIzyNUgMTY6MDUNCj4gytW8
/sjLOiBMaSxSb25ncWluZyA8bGlyb25ncWluZ0BiYWlkdS5jb20+DQo+ILOty806IGhhbm5lc0Bj
bXB4Y2hnLm9yZzsgdmRhdnlkb3YuZGV2QGdtYWlsLmNvbTsNCj4gY2dyb3Vwc0B2Z2VyLmtlcm5l
bC5vcmc7IGxpbnV4LW1tQGt2YWNrLm9yZzsNCj4gbGludXgta2VybmVsQHZnZXIua2VybmVsLm9y
Zw0KPiDW98ziOiBSZTogW1BBVENIXSBtbTogYXZvaWQgdGhlIHVubmVjZXNzYXJ5IHdhaXRpbmcg
d2hlbiBmb3JjZSBlbXB0eSBhDQo+IGNncm91cA0KPiANCj4gT24gVHVlIDAzLTA0LTE4IDE1OjEy
OjA5LCBMaSBSb25nUWluZyB3cm90ZToNCj4gPiBUaGUgbnVtYmVyIG9mIHdyaXRlYmFjayBhbmQg
ZGlydHkgcGFnZSBjYW4gYmUgcmVhZCBvdXQgZnJvbSBtZW1jZywgdGhlDQo+ID4gdW5uZWNlc3Nh
cnkgd2FpdGluZyBjYW4gYmUgYXZvaWRlZCBieSB0aGVzZSBjb3VudHMNCj4gDQo+IFRoaXMgY2hh
bmdlbG9nIGRvZXNuJ3QgZXhwbGFpbiB0aGUgcHJvYmxlbSBhbmQgaG93IHRoZSBwYXRjaCBmaXhl
cyBpdC4NCg0KSWYgYSBwcm9jZXNzIGluIGEgbWVtb3J5IGNncm91cCB0YWtlcyBzb21lIFJTUywg
d2hlbiBmb3JjZSBlbXB0eSB0aGlzIG1lbW9yeSBjZ3JvdXAsIGNvbmdlc3Rpb25fd2FpdCB3aWxs
IGJlIGNhbGxlZCB1bmNvbmRpdGlvbmFsbHksIHRoZXJlIGlzIDAuNSBzZWNvbmRzIGRlbGF5DQoN
CklmIHVzZSB0aGlzIHBhdGNoLCBuZWFybHkgbm8gZGVsYXkuDQoNCg0KPiBXaHkgZG8gd2VlIGFu
b3RoZXIgdGhyb3R0bGluZyB3aGVuIHdlIGRvIGFscmVhZHkgdGhyb3R0bGUgaW4gdGhlIHJlY2xh
aW0NCj4gcGF0aD8NCg0KRG8geW91IG1lYW4gd2Ugc2hvdWxkIHJlbW92ZSBjb25nZXN0aW9uX3dh
aXQoQkxLX1JXX0FTWU5DLCBIWi8xMCkgZnJvbSBtZW1fY2dyb3VwX2ZvcmNlX2VtcHR5LCBzaW5j
ZSB0cnlfdG9fZnJlZV9tZW1fY2dyb3VwX3BhZ2VzIFtzaHJpbmtfaW5hY3RpdmVfbGlzdF0gaGFz
IGNhbGxlZCBjb25nZXN0aW9uX3dhaXQNCg0KDQotUm9uZ1FpbmcNCg0KPiANCj4gPiBTaWduZWQt
b2ZmLWJ5OiBMaSBSb25nUWluZyA8bGlyb25ncWluZ0BiYWlkdS5jb20+DQo+ID4gLS0tDQo+ID4g
IG1tL21lbWNvbnRyb2wuYyB8IDggKysrKysrLS0NCj4gPiAgMSBmaWxlIGNoYW5nZWQsIDYgaW5z
ZXJ0aW9ucygrKSwgMiBkZWxldGlvbnMoLSkNCj4gPg0KPiA+IGRpZmYgLS1naXQgYS9tbS9tZW1j
b250cm9sLmMgYi9tbS9tZW1jb250cm9sLmMgaW5kZXgNCj4gPiA5ZWMwMjRiODYyYWMuLjUyNTg2
NTFiZDRlYyAxMDA2NDQNCj4gPiAtLS0gYS9tbS9tZW1jb250cm9sLmMNCj4gPiArKysgYi9tbS9t
ZW1jb250cm9sLmMNCj4gPiBAQCAtMjYxMyw5ICsyNjEzLDEzIEBAIHN0YXRpYyBpbnQgbWVtX2Nn
cm91cF9mb3JjZV9lbXB0eShzdHJ1Y3QNCj4gbWVtX2Nncm91cCAqbWVtY2cpDQo+ID4gIAkJcHJv
Z3Jlc3MgPSB0cnlfdG9fZnJlZV9tZW1fY2dyb3VwX3BhZ2VzKG1lbWNnLCAxLA0KPiA+ICAJCQkJ
CQkJR0ZQX0tFUk5FTCwgdHJ1ZSk7DQo+ID4gIAkJaWYgKCFwcm9ncmVzcykgew0KPiA+ICsJCQl1
bnNpZ25lZCBsb25nIG51bTsNCj4gPiArDQo+ID4gKwkJCW51bSA9IG1lbWNnX3BhZ2Vfc3RhdGUo
bWVtY2csIE5SX1dSSVRFQkFDSykgKw0KPiA+ICsJCQkJCW1lbWNnX3BhZ2Vfc3RhdGUobWVtY2cs
IE5SX0ZJTEVfRElSVFkpOw0KPiA+ICAJCQlucl9yZXRyaWVzLS07DQo+ID4gLQkJCS8qIG1heWJl
IHNvbWUgd3JpdGViYWNrIGlzIG5lY2Vzc2FyeSAqLw0KPiA+IC0JCQljb25nZXN0aW9uX3dhaXQo
QkxLX1JXX0FTWU5DLCBIWi8xMCk7DQo+ID4gKwkJCWlmIChudW0pDQo+ID4gKwkJCQljb25nZXN0
aW9uX3dhaXQoQkxLX1JXX0FTWU5DLCBIWi8xMCk7DQo+ID4gIAkJfQ0KPiA+DQo+ID4gIAl9DQo+
ID4gLS0NCj4gPiAyLjExLjANCj4gDQo+IC0tDQo+IE1pY2hhbCBIb2Nrbw0KPiBTVVNFIExhYnMN
Cg==
