Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E79CB83200
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 14:16:40 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id v125so92945557qkh.5
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 11:16:40 -0800 (PST)
Received: from us-smtp-delivery-194.mimecast.com (us-smtp-delivery-194.mimecast.com. [216.205.24.194])
        by mx.google.com with ESMTPS id e15si3705241qte.166.2017.03.08.11.16.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 Mar 2017 11:16:38 -0800 (PST)
From: Trond Myklebust <trondmy@primarydata.com>
Subject: Re: [PATCH v2 6/9] mm: set mapping error when launder_pages fails
Date: Wed, 8 Mar 2017 19:16:32 +0000
Message-ID: <1489000588.3098.8.camel@primarydata.com>
References: <20170308162934.21989-1-jlayton@redhat.com>
	 <20170308162934.21989-7-jlayton@redhat.com>
	 <1488996103.3098.4.camel@primarydata.com>
	 <1488998288.2802.25.camel@redhat.com>
In-Reply-To: <1488998288.2802.25.camel@redhat.com>
Content-Language: en-US
Content-ID: <86D654C6A10F1C4D81696080C0DA62EE@namprd11.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "jlayton@redhat.com" <jlayton@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-nilfs@vger.kernel.org" <linux-nilfs@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "neilb@suse.com" <neilb@suse.com>, "konishi.ryusuke@lab.ntt.co.jp" <konishi.ryusuke@lab.ntt.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "adilger@dilger.ca" <adilger@dilger.ca>, "James.Bottomley@HansenPartnership.com" <James.Bottomley@HansenPartnership.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

T24gV2VkLCAyMDE3LTAzLTA4IGF0IDEzOjM4IC0wNTAwLCBKZWZmIExheXRvbiB3cm90ZToNCj4g
T24gV2VkLCAyMDE3LTAzLTA4IGF0IDE4OjAxICswMDAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6
DQo+ID4gT24gV2VkLCAyMDE3LTAzLTA4IGF0IDExOjI5IC0wNTAwLCBKZWZmIExheXRvbiB3cm90
ZToNCj4gPiA+IElmIGxhdW5kZXJfcGFnZSBmYWlscywgdGhlbiB3ZSBoaXQgYSBwcm9ibGVtIHdy
aXRpbmcgYmFjayBzb21lDQo+ID4gPiBpbm9kZQ0KPiA+ID4gZGF0YS4gRW5zdXJlIHRoYXQgd2Ug
Y29tbXVuaWNhdGUgdGhhdCBmYWN0IGluIGEgc3Vic2VxdWVudCBmc3luYw0KPiA+ID4gc2luY2UN
Cj4gPiA+IGFub3RoZXIgdGFzayBjb3VsZCBzdGlsbCBoYXZlIGl0IG9wZW4gZm9yIHdyaXRlLg0K
PiA+ID4gDQo+ID4gPiBTaWduZWQtb2ZmLWJ5OiBKZWZmIExheXRvbiA8amxheXRvbkByZWRoYXQu
Y29tPg0KPiA+ID4gLS0tDQo+ID4gPiDCoG1tL3RydW5jYXRlLmMgfCA2ICsrKysrLQ0KPiA+ID4g
wqAxIGZpbGUgY2hhbmdlZCwgNSBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9uKC0pDQo+ID4gPiAN
Cj4gPiA+IGRpZmYgLS1naXQgYS9tbS90cnVuY2F0ZS5jIGIvbW0vdHJ1bmNhdGUuYw0KPiA+ID4g
aW5kZXggNjI2M2FmZmRlZjg4Li4yOWFlNDIwYTViZjkgMTAwNjQ0DQo+ID4gPiAtLS0gYS9tbS90
cnVuY2F0ZS5jDQo+ID4gPiArKysgYi9tbS90cnVuY2F0ZS5jDQo+ID4gPiBAQCAtNTk0LDExICs1
OTQsMTUgQEAgaW52YWxpZGF0ZV9jb21wbGV0ZV9wYWdlMihzdHJ1Y3QNCj4gPiA+IGFkZHJlc3Nf
c3BhY2UNCj4gPiA+ICptYXBwaW5nLCBzdHJ1Y3QgcGFnZSAqcGFnZSkNCj4gPiA+IMKgDQo+ID4g
PiDCoHN0YXRpYyBpbnQgZG9fbGF1bmRlcl9wYWdlKHN0cnVjdCBhZGRyZXNzX3NwYWNlICptYXBw
aW5nLCBzdHJ1Y3QNCj4gPiA+IHBhZ2UgKnBhZ2UpDQo+ID4gPiDCoHsNCj4gPiA+ICsJaW50IHJl
dDsNCj4gPiA+ICsNCj4gPiA+IMKgCWlmICghUGFnZURpcnR5KHBhZ2UpKQ0KPiA+ID4gwqAJCXJl
dHVybiAwOw0KPiA+ID4gwqAJaWYgKHBhZ2UtPm1hcHBpbmcgIT0gbWFwcGluZyB8fCBtYXBwaW5n
LT5hX29wcy0NCj4gPiA+ID5sYXVuZGVyX3BhZ2XCoA0KPiA+ID4gPT0gTlVMTCkNCj4gPiA+IMKg
CQlyZXR1cm4gMDsNCj4gPiA+IC0JcmV0dXJuIG1hcHBpbmctPmFfb3BzLT5sYXVuZGVyX3BhZ2Uo
cGFnZSk7DQo+ID4gPiArCXJldCA9IG1hcHBpbmctPmFfb3BzLT5sYXVuZGVyX3BhZ2UocGFnZSk7
DQo+ID4gPiArCW1hcHBpbmdfc2V0X2Vycm9yKG1hcHBpbmcsIHJldCk7DQo+ID4gPiArCXJldHVy
biByZXQ7DQo+ID4gPiDCoH0NCj4gPiA+IMKgDQo+ID4gPiDCoC8qKg0KPiA+IA0KPiA+IE5vLiBB
dCB0aGF0IGxheWVyLCB5b3UgZG9uJ3Qga25vdyB0aGF0IHRoaXMgaXMgYSBwYWdlIGVycm9yLiBJ
biB0aGUNCj4gPiBORlMNCj4gPiBjYXNlLCBpdCBjb3VsZCwgZm9yIGluc3RhbmNlLCBqdXN0IGFz
IHdlbGwgYmUgYSBmYXRhbCBzaWduYWwuDQo+ID4gDQo+IA0KPiBPay4uLmRvbid0IHdlIGhhdmUg
dGhlIHNhbWUgcHJvYmxlbSB3aXRoIHdyaXRlcGFnZSB0aGVuPyBNb3N0IG9mIHRoZQ0KPiB3cml0
ZXBhZ2UgY2FsbGVycyB3aWxsIHNldCBhbiBlcnJvciBpbiB0aGUgbWFwcGluZyBpZiB3cml0ZXBh
Z2UNCj4gcmV0dXJucw0KPiBhbnkgc29ydCBvZiBlcnJvcj8gQSBmYXRhbCBzaWduYWwgaW4gdGhh
dCBjb2RlcGF0aCBjb3VsZCBjYXVzZSB0aGUNCj4gc2FtZQ0KPiBwcm9ibGVtLCBpdCBzZWVtcy4g
V2UgZG9uJ3QgZGlwIGludG8gZGlyZWN0IHJlY2xhaW0gc28gbXVjaCBhbnltb3JlLA0KPiBzbw0K
PiBtYXliZSBzaWduYWxzIGFyZW4ndCBhbiBpc3N1ZSB0aGVyZT8NCg0KSWYgd3JpdGVwYWdlKCkg
ZmFpbHMgZHVlIHRvIGEgc2lnbmFsLCB0aGVuIGl0IGhhcyB0aGUgb3B0aW9uIG9mIG1hcmtpbmcN
CnRoZSBwYWdlIGFzIGRpcnR5IGFuZCByZXR1cm5pbmcgQU9QX1dSSVRFUEFHRV9BQ1RJVkFURS4g
VGhhdCdzIG5vdA0KcG9zc2libGUgZm9yIGxhdW5kZXJfcGFnZSgpLg0KDQo+IFRoZSBhbHRlcm5h
dGl2ZSBoZXJlIHdvdWxkIGJlIHRvIHB1c2ggdGhpcyBkb3duIGludG8gdGhlIGNhbGxlcnMuIEkN
Cj4gd29ycnkgYSBiaXQgdGhvdWdoIGFib3V0IGdldHRpbmcgdGhpcyByaWdodCBhY3Jvc3MgZmls
ZXN5c3RlbXMNCj4gdGhvdWdoLg0KPiBJdCdkIGJlIHByZWZlcmFibGUgaXQgaWYgd2UgY291bGQg
a2VlcCB0aGUgbWFwcGluZ19zZXRfZXJyb3IgY2FsbCBpbg0KPiBnZW5lcmljIFZGUyBjb2RlIGlu
c3RlYWQsIGJ1dCBpZiBub3QgdGhlbiBJJ2xsIGp1c3QgcGxhbiB0byBkbyB0aGF0Lg0KPiANCg0K
DQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIFBy
aW1hcnlEYXRhDQp0cm9uZC5teWtsZWJ1c3RAcHJpbWFyeWRhdGEuY29tDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
