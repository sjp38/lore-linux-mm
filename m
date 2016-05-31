Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id B9A56828E1
	for <linux-mm@kvack.org>; Tue, 31 May 2016 09:10:56 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id x1so317277241pav.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 06:10:56 -0700 (PDT)
Received: from mx0b-0016f401.pphosted.com (mx0b-0016f401.pphosted.com. [67.231.156.173])
        by mx.google.com with ESMTPS id q27si43766004pfj.25.2016.05.31.06.10.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 06:10:55 -0700 (PDT)
From: Yehuda Yitschak <yehuday@marvell.com>
Subject: RE: [BUG] Page allocation failures with newest kernels
Date: Tue, 31 May 2016 13:10:44 +0000
Message-ID: <60e8df74202e40b28a4d53dbc7fd0b22@IL-EXCH02.marvell.com>
References: <CAPv3WKcVsWBgHHC3UPNcbka2JUmN4CTw1Ym4BR1=1V9=B9av5Q@mail.gmail.com>
	<574D64A0.2070207@arm.com>
 <CAPv3WKdYdwpi3k5eY86qibfprMFwkYOkDwHOsNydp=0sTV3mgg@mail.gmail.com>
In-Reply-To: <CAPv3WKdYdwpi3k5eY86qibfprMFwkYOkDwHOsNydp=0sTV3mgg@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcin Wojtas <mw@semihalf.com>, Robin Murphy <robin.murphy@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Lior Amsalem <alior@marvell.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Catalin Marinas <catalin.marinas@arm.com>, Arnd Bergmann <arnd@arndb.de>, Grzegorz Jaszczyk <jaz@semihalf.com>, Will Deacon <will.deacon@arm.com>, Nadav Haklai <nadavh@marvell.com>, Tomasz Nowicki <tn@semihalf.com>, =?utf-8?B?R3JlZ29yeSBDbMOpbWVudA==?= <gregory.clement@free-electrons.com>

SGkgUm9iaW4gDQoNCkR1cmluZyBzb21lIG9mIHRoZSBzdHJlc3MgdGVzdHMgd2UgYWxzbyBjYW1l
IGFjcm9zcyBhIGRpZmZlcmVudCB3YXJuaW5nIGZyb20gdGhlIGFybTY0ICBwYWdlIG1hbmFnZW1l
bnQgY29kZQ0KSXQgbG9va3MgbGlrZSBhIHJhY2UgaXMgZGV0ZWN0ZWQgYmV0d2VlbiBIVyBhbmQg
U1cgbWFya2luZyBhIGJpdCBpbiB0aGUgUFRFDQoNCk5vdCBzdXJlIGl0J3MgcmVhbGx5IHJlbGF0
ZWQgYnV0IEkgdGhvdWdodCBpdCBtaWdodCBnaXZlIGEgY2x1ZSBvbiB0aGUgaXNzdWUNCmh0dHA6
Ly9wYXN0ZWJpbi5jb20vQVN2MTl2WlANCg0KVGhhbmtzDQoNClllaHVkYSANCg0KDQo+IC0tLS0t
T3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+IEZyb206IE1hcmNpbiBXb2p0YXMgW21haWx0bzptd0Bz
ZW1paGFsZi5jb21dDQo+IFNlbnQ6IFR1ZXNkYXksIE1heSAzMSwgMjAxNiAxMzozMA0KPiBUbzog
Um9iaW4gTXVycGh5DQo+IENjOiBsaW51eC1tbUBrdmFjay5vcmc7IGxpbnV4LWtlcm5lbEB2Z2Vy
Lmtlcm5lbC5vcmc7IGxpbnV4LWFybS0NCj4ga2VybmVsQGxpc3RzLmluZnJhZGVhZC5vcmc7IExp
b3IgQW1zYWxlbTsgVGhvbWFzIFBldGF6em9uaTsgWWVodWRhDQo+IFlpdHNjaGFrOyBDYXRhbGlu
IE1hcmluYXM7IEFybmQgQmVyZ21hbm47IEdyemVnb3J6IEphc3pjenlrOyBXaWxsIERlYWNvbjsN
Cj4gTmFkYXYgSGFrbGFpOyBUb21hc3ogTm93aWNraTsgR3JlZ29yeSBDbMOpbWVudA0KPiBTdWJq
ZWN0OiBSZTogW0JVR10gUGFnZSBhbGxvY2F0aW9uIGZhaWx1cmVzIHdpdGggbmV3ZXN0IGtlcm5l
bHMNCj4gDQo+IEhpIFJvYmluLA0KPiANCj4gPg0KPiA+IEkgcmVtZW1iZXIgdGhlcmUgd2VyZSBz
b21lIGlzc3VlcyBhcm91bmQgNC4yIHdpdGggdGhlIHJldmlzaW9uIG9mIHRoZQ0KPiA+IGFybTY0
IGF0b21pYyBpbXBsZW1lbnRhdGlvbnMgYWZmZWN0aW5nIHRoZSBjbXB4Y2hnX2RvdWJsZSgpIGlu
IFNMVUIsDQo+ID4gYnV0IHRob3NlIHNob3VsZCBhbGwgYmUgZml4ZWQgKGFuZCB0aGUgc3ltcHRv
bXMgdGVuZGVkIHRvIGJlDQo+IGNvbnNpZGVyYWJseSBtb3JlIGZhdGFsKS4NCj4gPiBBIHN0cm9u
Z2VyIGNhbmRpZGF0ZSB3b3VsZCBiZSA5NzMwMzQ4MDc1M2UgKHdoaWNoIGxhbmRlZCBpbiA0LjQp
LA0KPiA+IHdoaWNoIGhhcyB2YXJpb3VzIGtub2NrLW9uIGVmZmVjdHMgb24gdGhlIGxheW91dCBv
ZiBTTFVCIGludGVybmFscyAtDQo+ID4gZG9lcyBmaWRkbGluZyB3aXRoIEwxX0NBQ0hFX1NISUZU
IG1ha2UgYW55IGRpZmZlcmVuY2U/DQo+ID4NCj4gDQo+IEknbGwgY2hlY2sgdGhlIGNvbW1pdHMs
IHRoYW5rcy4gSSBmb3Jnb3QgdG8gYWRkIEwxX0NBQ0hFX1NISUZUIHdhcyBteSBmaXJzdA0KPiBz
dXNwZWN0IC0gSSBoYWQgc3BlbnQgYSBsb25nIHRpbWUgZGVidWdnaW5nIG5ldHdvcmsgY29udHJv
bGxlciwgd2hpY2gNCj4gc3RvcHBlZCB3b3JraW5nIGJlY2F1c2Ugb2YgdGhpcyBjaGFuZ2UgLSBM
MV9DQUNIRV9CWVRFUyAoYW5kIGhlbmNlDQo+IE5FVF9TS0JfUEFEKSBub3QgZml0dGluZyBIVyBj
b25zdHJhaW50cy4gQW55d2F5IHJldmVydGluZyBpdCBkaWRuJ3QgaGVscCBhdA0KPiBhbGwgZm9y
IHBhZ2UgYWxsb2MgaXNzdWUuDQo+IA0KPiBCZXN0IHJlZ2FyZHMsDQo+IE1hcmNpbg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
