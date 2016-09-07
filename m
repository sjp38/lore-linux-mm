Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D9EEA6B0253
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 19:40:23 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v67so74200633pfv.1
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 16:40:23 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0127.outbound.protection.outlook.com. [104.47.40.127])
        by mx.google.com with ESMTPS id n11si42627544pfk.264.2016.09.07.12.39.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 07 Sep 2016 12:39:20 -0700 (PDT)
From: "Kani, Toshimitsu" <toshi.kani@hpe.com>
Subject: Re: [PATCH 4/5] mm: fix cache mode of dax pmd mappings
Date: Wed, 7 Sep 2016 19:39:19 +0000
Message-ID: <1473277101.2092.39.camel@hpe.com>
References: <147318056046.30325.5100892122988191500.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <147318058165.30325.16762406881120129093.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <20160906131756.6b6c6315b7dfba3a9d5f233a@linux-foundation.org>
	 <CAPcyv4hjdPWxdY+UTKVstiLZ7r4oOCa+h+Hd+kzS+wJZidzCjA@mail.gmail.com>
In-Reply-To: <CAPcyv4hjdPWxdY+UTKVstiLZ7r4oOCa+h+Hd+kzS+wJZidzCjA@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <AFD00A2A8E7A154ABA21E62498A40D44@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "kai.ka.zhang@oracle.com" <kai.ka.zhang@oracle.com>, "nilesh.choudhury@oracle.com" <nilesh.choudhury@oracle.com>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>

T24gVHVlLCAyMDE2LTA5LTA2IGF0IDE0OjUyIC0wNzAwLCBEYW4gV2lsbGlhbXMgd3JvdGU6DQo+
IE9uIFR1ZSwgU2VwIDYsIDIwMTYgYXQgMToxNyBQTSwgQW5kcmV3IE1vcnRvbiA8YWtwbUBsaW51
eC1mb3VuZGF0aW9uLg0KPiBvcmc+IHdyb3RlOg0KPiA+IA0KPiA+IE9uIFR1ZSwgMDYgU2VwIDIw
MTYgMDk6NDk6NDEgLTA3MDAgRGFuIFdpbGxpYW1zIDxkYW4uai53aWxsaWFtc0BpbnQNCj4gPiBl
bC5jb20+IHdyb3RlOg0KPiA+IA0KPiA+ID4gDQo+ID4gPiB0cmFja19wZm5faW5zZXJ0KCkgaXMg
bWFya2luZyBkYXggbWFwcGluZ3MgYXMgdW5jYWNoZWFibGUuDQo+ID4gPiANCj4gPiA+IEl0IGlz
IHVzZWQgdG8ga2VlcCBtYXBwaW5ncyBhdHRyaWJ1dGVzIGNvbnNpc3RlbnQgYWNyb3NzIGENCj4g
PiA+IHJlbWFwcGVkIHJhbmdlLiBIb3dldmVyLCBzaW5jZSBkYXggcmVnaW9ucyBhcmUgbmV2ZXIg
cmVnaXN0ZXJlZA0KPiA+ID4gdmlhIHRyYWNrX3Bmbl9yZW1hcCgpLCB0aGUgY2FjaGluZyBtb2Rl
IGxvb2t1cCBmb3IgZGF4IHBmbnMNCj4gPiA+IGFsd2F5cyByZXR1cm5zIF9QQUdFX0NBQ0hFX01P
REVfVUMuwqDCoFdlIGRvIG5vdCB1c2UNCj4gPiA+IHRyYWNrX3Bmbl9pbnNlcnQoKSBpbiB0aGUg
ZGF4LXB0ZSBwYXRoLCBhbmQgd2UgYWx3YXlzIHdhbnQgdG8gdXNlDQo+ID4gPiB0aGUgcGdwcm90
IG9mIHRoZSB2bWEgaXRzZWxmLCBzbyBkcm9wIHRoaXMgY2FsbC4NCj4gPiA+IA0KPiA+ID4gQ2M6
IFJvc3MgWndpc2xlciA8cm9zcy56d2lzbGVyQGxpbnV4LmludGVsLmNvbT4NCj4gPiA+IENjOiBN
YXR0aGV3IFdpbGNveCA8bWF3aWxjb3hAbWljcm9zb2Z0LmNvbT4NCj4gPiA+IENjOiBLaXJpbGwg
QS4gU2h1dGVtb3YgPGtpcmlsbC5zaHV0ZW1vdkBsaW51eC5pbnRlbC5jb20+DQo+ID4gPiBDYzog
QW5kcmV3IE1vcnRvbiA8YWtwbUBsaW51eC1mb3VuZGF0aW9uLm9yZz4NCj4gPiA+IENjOiBOaWxl
c2ggQ2hvdWRodXJ5IDxuaWxlc2guY2hvdWRodXJ5QG9yYWNsZS5jb20+DQo+ID4gPiBSZXBvcnRl
ZC1ieTogS2FpIFpoYW5nIDxrYWkua2EuemhhbmdAb3JhY2xlLmNvbT4NCj4gPiA+IFJlcG9ydGVk
LWJ5OiBUb3NoaSBLYW5pIDx0b3NoaS5rYW5pQGhwZS5jb20+DQo+ID4gPiBDYzogPHN0YWJsZUB2
Z2VyLmtlcm5lbC5vcmc+DQo+ID4gPiBTaWduZWQtb2ZmLWJ5OiBEYW4gV2lsbGlhbXMgPGRhbi5q
LndpbGxpYW1zQGludGVsLmNvbT4NCj4gPiANCj4gPiBDaGFuZ2Vsb2cgZmFpbHMgdG8gZXhwbGFp
biB0aGUgdXNlci12aXNpYmxlIGVmZmVjdHMgb2YgdGhlDQo+ID4gcGF0Y2guwqDCoFRoZSBzdGFi
bGUgbWFpbnRhaW5lcihzKSB3aWxsIGxvb2sgYXQgdGhpcyBhbmQgd29uZGVyICJ5dGYNCj4gPiB3
YXMgSSBzZW50IHRoaXMiLg0KPiANCj4gVHJ1ZSwgSSdsbCBjaGFuZ2UgaXQgdG8gdGhpczoNCj4g
DQo+IHRyYWNrX3Bmbl9pbnNlcnQoKSBpcyBtYXJraW5nIGRheCBtYXBwaW5ncyBhcyB1bmNhY2hl
YWJsZSByZW5kZXJpbmcNCj4gdGhlbSBpbXByYWN0aWNhbCBmb3IgYXBwbGljYXRpb24gdXNhZ2Uu
wqDCoERBWC1wdGUgbWFwcGluZ3MgYXJlIGNhY2hlZA0KPiBhbmQgdGhlIGdvYWwgb2YgZXN0YWJs
aXNoaW5nIERBWC1wbWQgbWFwcGluZ3MgaXMgdG8gYXR0YWluIG1vcmUNCj4gcGVyZm9ybWFuY2Us
IG5vdCBkcmFtYXRpY2FsbHkgbGVzcyAoMyBvcmRlcnMgb2YgbWFnbml0dWRlKS4NCj4gDQo+IERl
bGV0aW5nIHRoZSBjYWxsIHRvIHRyYWNrX3Bmbl9pbnNlcnQoKSBpbiB2bWZfaW5zZXJ0X3Bmbl9w
bWQoKSBsZXRzDQo+IHRoZSBkZWZhdWx0IHBncHJvdCAod3JpdGUtYmFjayBjYWNoZSBlbmFibGVk
KSBmcm9tIHRoZSB2bWEgYmUgdXNlZA0KPiBmb3IgdGhlIG1hcHBpbmcgd2hpY2ggeWllbGRzIHRo
ZSBleHBlY3RlZCBwZXJmb3JtYW5jZSBpbXByb3ZlbWVudA0KPiBvdmVyIERBWC1wdGUgbWFwcGlu
Z3MuDQo+IA0KPiB0cmFja19wZm5faW5zZXJ0KCkgaXMgbWVhbnQgdG8ga2VlcCB0aGUgY2FjaGUg
bW9kZSBmb3IgYSBnaXZlbiByYW5nZQ0KPiBzeW5jaHJvbml6ZWQgYWNyb3NzIGRpZmZlcmVudCB1
c2VycyBvZiByZW1hcF9wZm5fcmFuZ2UoKSBhbmQNCj4gdm1faW5zZXJ0X3Bmbl9wcm90KCkuwqDC
oERBWCB1c2VzIG5laXRoZXIgb2YgdGhvc2UgbWFwcGluZyBtZXRob2RzLCBhbmQNCj4gdGhlIHBt
ZW0gZHJpdmVyIGlzIGFscmVhZHkgbWFya2luZyBpdHMgbWVtb3J5IHJhbmdlcyBhcyB3cml0ZS1i
YWNrDQo+IGNhY2hlIGVuYWJsZWQuwqDCoFNvLCByZW1vdmluZyB0aGUgY2FsbCB0byB0cmFja19w
Zm5faW5zZXJ0KCkgbGVhdmVzDQo+IHRoZSBrZXJuZWwgbm8gd29yc2Ugb2ZmIHRoYW4gdGhlIGN1
cnJlbnQgc2l0dWF0aW9uIHdoZXJlIGEgdXNlciBjb3VsZA0KPiBtYXAgdGhlIHJhbmdlIHZpYSAv
ZGV2L21lbSB3aXRoIGFuIGluY29tcGF0aWJsZSBjYWNoZSBtb2RlIGNvbXBhcmVkDQo+IHRvIHRo
ZSBkcml2ZXIuDQoNCkkgdGhpbmvCoGRldm1fbWVtcmVtYXBfcGFnZXMoKSBzaG91bGQgY2FsbMKg
cmVzZXJ2ZV9tZW10eXBlKCkgb24geDg2IHRvDQprZWVwIGl0IGNvbnNpc3RlbnQgd2l0aMKgZGV2
bV9tZW1yZW1hcCgpIG9uIHRoaXMgcmVnYXJkLiDCoFdlIG1heSBuZWVkIGFuDQphcmNoIHN0dWIg
Zm9yIHJlc2VydmVfbWVtdHlwZSgpLCB0aG91Z2guIMKgVGhlbiwgdHJhY2tfcGZuX2luc2VydCgp
DQpzaG91bGQgaGF2ZSBubyBpc3N1ZSBpbiB0aGlzIGNhc2UuDQoNClRoYW5rcywNCi1Ub3NoaQ==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
