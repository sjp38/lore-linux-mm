Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5BA006B0038
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 16:17:55 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 144so569880525pfv.5
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 13:17:55 -0800 (PST)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0097.outbound.protection.outlook.com. [104.47.40.97])
        by mx.google.com with ESMTPS id l6si20876179pli.336.2016.12.06.13.17.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 06 Dec 2016 13:17:54 -0800 (PST)
From: Matthew Wilcox <mawilcox@microsoft.com>
Subject: RE: [PATCH v3 33/33] Reimplement IDR and IDA using the radix tree
Date: Tue, 6 Dec 2016 21:17:52 +0000
Message-ID: <CY1PR21MB0071D603E8B6F6A7F820492BCB820@CY1PR21MB0071.namprd21.prod.outlook.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
	<1480369871-5271-34-git-send-email-mawilcox@linuxonhyperv.com>
 <20161206124453.3d3ce26a1526fedd70988ab8@linux-foundation.org>
In-Reply-To: <20161206124453.3d3ce26a1526fedd70988ab8@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@linuxonhyperv.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Konstantin
 Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>

RnJvbTogQW5kcmV3IE1vcnRvbiBbbWFpbHRvOmFrcG1AbGludXgtZm91bmRhdGlvbi5vcmddDQo+
IE9uIE1vbiwgMjggTm92IDIwMTYgMTM6NTA6MzcgLTA4MDAgTWF0dGhldyBXaWxjb3gNCj4gPG1h
d2lsY294QGxpbnV4b25oeXBlcnYuY29tPiB3cm90ZToNCj4gPiAgaW5jbHVkZS9saW51eC9pZHIu
aCAgICAgICAgICAgICAgICAgICAgIHwgIDEzMiArKy0tDQo+ID4gIGluY2x1ZGUvbGludXgvcmFk
aXgtdHJlZS5oICAgICAgICAgICAgICB8ICAgIDUgKy0NCj4gPiAgaW5pdC9tYWluLmMgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgIHwgICAgMyArLQ0KPiA+ICBsaWIvaWRyLmMgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgfCAxMDc4IC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0NCj4gPiAgbGliL3JhZGl4LXRyZWUuYyAgICAgICAgICAgICAgICAgICAgICAgIHwgIDYzMiAr
KysrKysrKysrKysrKysrLS0NCj4gDQo+IGhtLiAgSXQncyBqdXN0IGEgY29zbWV0aWMgaXNzdWUs
IGJ1dCBwZXJoYXBzIHRoZSBpZHINCj4gd3JhcHBlcnMtYXJvdW5kLXJhZGl4LXRyZWUgY29kZSBz
aG91bGQgYmUgaW4gYSBkaWZmZXJlbnQgLmMgZmlsZS4NCg0KSSBjYW4gcHV0IHNvbWUgb2YgdGhl
bSBiYWNrIGludG8gaWRyLmMgLS0gdGhlcmUncyBhIGNvdXBsZSBvZiByb3V0aW5lcyBsZWZ0IGlu
IHRoZXJlIHN0aWxsLCBzbyBhZGRpbmcgc29tZSBtb3JlIHdvbid0IGh1cnQuDQoNCj4gQmVmb3Jl
Og0KPiANCj4gYWtwbTM6L3Vzci9zcmMvMjU+IHNpemUgbGliL2lkci5vIGxpYi9yYWRpeC10cmVl
Lm8NCj4gICAgdGV4dCAgICBkYXRhICAgICBic3MgICAgIGRlYyAgICAgaGV4IGZpbGVuYW1lDQo+
ICAgIDY1NjYgICAgICA4OSAgICAgIDE2ICAgIDY2NzEgICAgMWEwZiBsaWIvaWRyLm8NCj4gICAx
MTgxMSAgICAgMTE3ICAgICAgIDggICAxMTkzNiAgICAyZWEwIGxpYi9yYWRpeC10cmVlLm8NCj4g
DQo+IEFmdGVyOg0KPiANCj4gICAgdGV4dCAgICBkYXRhICAgICBic3MgICAgIGRlYyAgICAgaGV4
IGZpbGVuYW1lDQo+ICAgMTQxNTEgICAgIDExOCAgICAgICA4ICAgMTQyNzcgICAgMzdjNSBsaWIv
cmFkaXgtdHJlZS5vDQo+IA0KPiANCj4gU28gNDUwMCBieXRlcyBzYXZlZC4gIERlY2VudC4NCg0K
Tm90IGJhZC4gIDBkYXkgaGFzIGJlZW4gc2VuZGluZyBtZSBlbWFpbCB0ZWxsaW5nIG1lIHRoYXQg
SSBzYXZlZCBzb21ldGhpbmcgbW9yZSBsaWtlIDE1MDAgYnl0ZXMsIGJ1dCB0aGF0J3Mgb24gYSBt
aW5pbWFsIGNvbmZpZy4gIChhbHNvIGEgY291cGxlIG9mIHJvdXRpbmVzIHN0YXllZCBpbiBpZHIu
Yywgc28geW91J3JlIG92ZXJzdGF0aW5nIGhvdyBtdWNoIEkgc2F2ZWQpDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
