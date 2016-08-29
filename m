Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7905D82F64
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 16:45:07 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id i27so321536974qte.3
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 13:45:07 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0125.outbound.protection.outlook.com. [104.47.33.125])
        by mx.google.com with ESMTPS id q129si24658488qkd.233.2016.08.29.13.45.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 29 Aug 2016 13:45:06 -0700 (PDT)
From: "Kani, Toshimitsu" <toshi.kani@hpe.com>
Subject: Re: [PATCH v4 RESEND 1/2] thp, dax: add thp_get_unmapped_area for pmd
 mappings
Date: Mon, 29 Aug 2016 20:44:57 +0000
Message-ID: <1472503455.1532.28.camel@hpe.com>
References: <1472497881-9323-1-git-send-email-toshi.kani@hpe.com>
	 <1472497881-9323-2-git-send-email-toshi.kani@hpe.com>
	 <CAPcyv4hJ1DrCkBCwqm02e1D85wtSPwUaSG2S84JaDJwFWA_4hA@mail.gmail.com>
In-Reply-To: <CAPcyv4hJ1DrCkBCwqm02e1D85wtSPwUaSG2S84JaDJwFWA_4hA@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <2939AF2AE98DBE4499B0F35CF99C1BF6@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "dan.j.williams@intel.com" <dan.j.williams@intel.com>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "adilger.kernel@dilger.ca" <adilger.kernel@dilger.ca>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "tytso@mit.edu" <tytso@mit.edu>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>

T24gTW9uLCAyMDE2LTA4LTI5IGF0IDEyOjM0IC0wNzAwLCBEYW4gV2lsbGlhbXMgd3JvdGU6DQo+
IE9uIE1vbiwgQXVnIDI5LCAyMDE2IGF0IDEyOjExIFBNLCBUb3NoaSBLYW5pIDx0b3NoaS5rYW5p
QGhwZS5jb20+DQo+IHdyb3RlOg0KPiA+IA0KPiA+IFdoZW4gQ09ORklHX0ZTX0RBWF9QTUQgaXMg
c2V0LCBEQVggc3VwcG9ydHMgbW1hcCgpIHVzaW5nIHBtZCBwYWdlDQo+ID4gc2l6ZS7CoMKgVGhp
cyBmZWF0dXJlIHJlbGllcyBvbiBib3RoIG1tYXAgdmlydHVhbCBhZGRyZXNzIGFuZCBGUw0KPiA+
IGJsb2NrIChpLmUuIHBoeXNpY2FsIGFkZHJlc3MpIHRvIGJlIGFsaWduZWQgYnkgdGhlIHBtZCBw
YWdlIHNpemUuDQo+ID4gVXNlcnMgY2FuIHVzZSBta2ZzIG9wdGlvbnMgdG8gc3BlY2lmeSBGUyB0
byBhbGlnbiBibG9jaw0KPiA+IGFsbG9jYXRpb25zLiBIb3dldmVyLCBhbGlnbmluZyBtbWFwIGFk
ZHJlc3MgcmVxdWlyZXMgY29kZSBjaGFuZ2VzDQo+ID4gdG8gZXhpc3RpbmcgYXBwbGljYXRpb25z
IGZvciBwcm92aWRpbmcgYSBwbWQtYWxpZ25lZCBhZGRyZXNzIHRvDQo+ID4gbW1hcCgpLg0KPiA+
IA0KPiA+IEZvciBpbnN0YW5jZSwgZmlvIHdpdGggImlvZW5naW5lPW1tYXAiIHBlcmZvcm1zIEkv
T3Mgd2l0aCBtbWFwKCkNCj4gPiBbMV0uIEl0IGNhbGxzIG1tYXAoKSB3aXRoIGEgTlVMTCBhZGRy
ZXNzLCB3aGljaCBuZWVkcyB0byBiZSBjaGFuZ2VkDQo+ID4gdG8gcHJvdmlkZSBhIHBtZC1hbGln
bmVkIGFkZHJlc3MgZm9yIHRlc3Rpbmcgd2l0aCBEQVggcG1kIG1hcHBpbmdzLg0KPiA+IENoYW5n
aW5nIGFsbCBhcHBsaWNhdGlvbnMgdGhhdCBjYWxsIG1tYXAoKSB3aXRoIE5VTEwgaXMNCj4gPiB1
bmRlc2lyYWJsZS4NCj4gPiANCj4gPiBBZGQgdGhwX2dldF91bm1hcHBlZF9hcmVhKCksIHdoaWNo
IGNhbiBiZSBjYWxsZWQgYnkgZmlsZXN5c3RlbSdzDQo+ID4gZ2V0X3VubWFwcGVkX2FyZWEgdG8g
YWxpZ24gYW4gbW1hcCBhZGRyZXNzIGJ5IHRoZSBwbWQgc2l6ZSBmb3INCj4gPiBhIERBWCBmaWxl
LsKgwqBJdCBjYWxscyB0aGUgZGVmYXVsdCBoYW5kbGVyLCBtbS0+Z2V0X3VubWFwcGVkX2FyZWEo
KSwNCj4gPiB0byBmaW5kIGEgcmFuZ2UgYW5kIHRoZW4gYWxpZ25zIGl0IGZvciBhIERBWCBmaWxl
Lg0KPiA+IA0KPiA+IFRoZSBwYXRjaCBpcyBiYXNlZCBvbiBNYXR0aGV3IFdpbGNveCdzIGNoYW5n
ZSB0aGF0IGFsbG93cyBhZGRpbmcNCj4gPiBzdXBwb3J0IG9mIHRoZSBwdWQgcGFnZSBzaXplIGVh
c2lseS4NCsKgOg0KPiANCj4gUmV2aWV3ZWQtYnk6IERhbiBXaWxsaWFtcyA8ZGFuLmoud2lsbGlh
bXNAaW50ZWwuY29tPg0KDQpHcmVhdCENCg0KPiAuLi53aXRoIG9uZSBtaW5vciBuaXQ6DQo+IA0K
PiANCj4gPiANCj4gPiDCoGluY2x1ZGUvbGludXgvaHVnZV9tbS5oIHzCoMKgwqDCoDcgKysrKysr
Kw0KPiA+IMKgbW0vaHVnZV9tZW1vcnkuY8KgwqDCoMKgwqDCoMKgwqB8wqDCoMKgNDMNCj4gPiAr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrDQo+ID4gwqAyIGZpbGVz
IGNoYW5nZWQsIDUwIGluc2VydGlvbnMoKykNCj4gPiANCj4gPiBkaWZmIC0tZ2l0IGEvaW5jbHVk
ZS9saW51eC9odWdlX21tLmggYi9pbmNsdWRlL2xpbnV4L2h1Z2VfbW0uaA0KPiA+IGluZGV4IDZm
MTRkZTQuLjRmY2E1MjYgMTAwNjQ0DQo+ID4gLS0tIGEvaW5jbHVkZS9saW51eC9odWdlX21tLmgN
Cj4gPiArKysgYi9pbmNsdWRlL2xpbnV4L2h1Z2VfbW0uaA0KPiA+IEBAIC04Nyw2ICs4NywxMCBA
QCBleHRlcm4gYm9vbCBpc192bWFfdGVtcG9yYXJ5X3N0YWNrKHN0cnVjdA0KPiA+IHZtX2FyZWFf
c3RydWN0ICp2bWEpOw0KPiA+IA0KPiA+IMKgZXh0ZXJuIHVuc2lnbmVkIGxvbmcgdHJhbnNwYXJl
bnRfaHVnZXBhZ2VfZmxhZ3M7DQo+ID4gDQo+ID4gK2V4dGVybiB1bnNpZ25lZCBsb25nIHRocF9n
ZXRfdW5tYXBwZWRfYXJlYShzdHJ1Y3QgZmlsZSAqZmlscCwNCj4gPiArwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgdW5zaWduZWQgbG9uZyBhZGRyLCB1bnNpZ25lZCBsb25nIGxlbiwgdW5z
aWduZWQNCj4gPiBsb25nIHBnb2ZmLA0KPiA+ICvCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqB1bnNpZ25lZCBsb25nIGZsYWdzKTsNCj4gPiArDQo+ID4gwqBleHRlcm4gdm9pZCBwcmVwX3Ry
YW5zaHVnZV9wYWdlKHN0cnVjdCBwYWdlICpwYWdlKTsNCj4gPiDCoGV4dGVybiB2b2lkIGZyZWVf
dHJhbnNodWdlX3BhZ2Uoc3RydWN0IHBhZ2UgKnBhZ2UpOw0KPiA+IA0KPiA+IEBAIC0xNjksNiAr
MTczLDkgQEAgdm9pZCBwdXRfaHVnZV96ZXJvX3BhZ2Uodm9pZCk7DQo+ID4gwqBzdGF0aWMgaW5s
aW5lIHZvaWQgcHJlcF90cmFuc2h1Z2VfcGFnZShzdHJ1Y3QgcGFnZSAqcGFnZSkge30NCj4gPiAN
Cj4gPiDCoCNkZWZpbmUgdHJhbnNwYXJlbnRfaHVnZXBhZ2VfZmxhZ3MgMFVMDQo+ID4gKw0KPiA+
ICsjZGVmaW5lIHRocF9nZXRfdW5tYXBwZWRfYXJlYcKgwqBOVUxMDQo+IA0KPiBMZXRzIG1ha2Ug
dGhpczoNCj4gDQo+IHN0YXRpYyBpbmxpbmUgdW5zaWduZWQgbG9uZyB0aHBfZ2V0X3VubWFwcGVk
X2FyZWEoc3RydWN0IGZpbGUgKmZpbHAsDQo+IMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oHVuc2lnbmVkIGxvbmcgYWRkciwgdW5zaWduZWQgbG9uZyBsZW4sIHVuc2lnbmVkIGxvbmcNCj4g
cGdvZmYsDQo+IMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoHVuc2lnbmVkIGxvbmcgZmxh
Z3MpDQo+IHsNCj4gwqDCoMKgwqByZXR1cm4gMDsNCj4gfQ0KPiANCj4gLi4udG8gZ2V0IHNvbWUg
dHlwZSBjaGVja2luZyBpbiB0aGUgQ09ORklHX1RSQU5TUEFSRU5UX0hVR0VQQUdFPW4NCj4gY2Fz
ZS4NCj4gDQoNClBlcsKgZ2V0X3VubWFwcGVkX2FyZWEoKSBpbsKgbW0vbW1hcC5jLCBJIHRoaW5r
IHdlIG5lZWQgdG8gc2V0IGl0IHRvIE5VTEwNCndoZW4gd2UgZG8gbm90IG92ZXJyaWRlIGN1cnJl
bnQtPm1tLT5nZXRfdW5tYXBwZWRfYXJlYS4NCg0KVGhhbmtzIQ0KLVRvc2hpDQoNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
