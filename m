Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vb0-f51.google.com (mail-vb0-f51.google.com [209.85.212.51])
	by kanga.kvack.org (Postfix) with ESMTP id ADE9C6B0031
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 12:26:53 -0500 (EST)
Received: by mail-vb0-f51.google.com with SMTP id 11so8906248vbe.24
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 09:26:53 -0800 (PST)
Received: from exchange10.columbia.tresys.com (exchange10.columbia.tresys.com. [216.30.191.171])
        by mx.google.com with ESMTPS id yt16si29736818vcb.42.2014.01.06.09.26.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 06 Jan 2014 09:26:52 -0800 (PST)
From: William Roberts <WRoberts@tresys.com>
Subject: RE: [RFC][PATCH 3/3] audit: Audit proc cmdline value
Date: Mon, 6 Jan 2014 17:26:15 +0000
Message-ID: <A8856C6323EFE0459533E910625AB9303DC9C7@Exchange10.columbia.tresys.com>
References: <1389022230-24664-1-git-send-email-wroberts@tresys.com>
 <1389022230-24664-3-git-send-email-wroberts@tresys.com>
 <20140106170855.GA1828@mguzik.redhat.com>
In-Reply-To: <20140106170855.GA1828@mguzik.redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mateusz Guzik <mguzik@redhat.com>, William Roberts <bill.c.roberts@gmail.com>
Cc: "linux-audit@redhat.com" <linux-audit@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rgb@redhat.com" <rgb@redhat.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "sds@tycho.nsa.gov" <sds@tycho.nsa.gov>

DQoNCi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQpGcm9tOiBNYXRldXN6IEd1emlrIFttYWls
dG86bWd1emlrQHJlZGhhdC5jb21dIA0KU2VudDogTW9uZGF5LCBKYW51YXJ5IDA2LCAyMDE0IDk6
MDkgQU0NClRvOiBXaWxsaWFtIFJvYmVydHMNCkNjOiBsaW51eC1hdWRpdEByZWRoYXQuY29tOyBs
aW51eC1tbUBrdmFjay5vcmc7IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmc7IHJnYkByZWRo
YXQuY29tOyB2aXJvQHplbml2LmxpbnV4Lm9yZy51azsgYWtwbUBsaW51eC1mb3VuZGF0aW9uLm9y
Zzsgc2RzQHR5Y2hvLm5zYS5nb3Y7IFdpbGxpYW0gUm9iZXJ0cw0KU3ViamVjdDogUmU6IFtSRkNd
W1BBVENIIDMvM10gYXVkaXQ6IEF1ZGl0IHByb2MgY21kbGluZSB2YWx1ZQ0KDQpJIGNhbid0IGNv
bW1lbnQgb24gdGhlIGNvbmNlcHQsIGJ1dCBoYXZlIG9uZSBuaXQuDQoNCk9uIE1vbiwgSmFuIDA2
LCAyMDE0IGF0IDA3OjMwOjMwQU0gLTA4MDAsIFdpbGxpYW0gUm9iZXJ0cyB3cm90ZToNCj4gK3N0
YXRpYyB2b2lkIGF1ZGl0X2xvZ19jbWRsaW5lKHN0cnVjdCBhdWRpdF9idWZmZXIgKmFiLCBzdHJ1
Y3QgdGFza19zdHJ1Y3QgKnRzaywNCj4gKwkJCSBzdHJ1Y3QgYXVkaXRfY29udGV4dCAqY29udGV4
dCkNCj4gK3sNCj4gKwlpbnQgcmVzOw0KPiArCWNoYXIgKmJ1ZjsNCj4gKwljaGFyICptc2cgPSAi
KG51bGwpIjsNCj4gKwlhdWRpdF9sb2dfZm9ybWF0KGFiLCAiIGNtZGxpbmU9Iik7DQo+ICsNCj4g
KwkvKiBOb3QgIGNhY2hlZCAqLw0KPiArCWlmICghY29udGV4dC0+Y21kbGluZSkgew0KPiArCQli
dWYgPSBrbWFsbG9jKFBBVEhfTUFYLCBHRlBfS0VSTkVMKTsNCj4gKwkJaWYgKCFidWYpDQo+ICsJ
CQlnb3RvIG91dDsNCj4gKwkJcmVzID0gZ2V0X2NtZGxpbmUodHNrLCBidWYsIFBBVEhfTUFYKTsN
Cj4gKwkJLyogRW5zdXJlIE5VTEwgdGVybWluYXRlZCAqLw0KPiArCQlpZiAoYnVmW3Jlcy0xXSAh
PSAnXDAnKQ0KPiArCQkJYnVmW3Jlcy0xXSA9ICdcMCc7DQoNClRoaXMgYWNjZXNzZXMgbWVtb3J5
IGJlbG93IHRoZSBidWZmZXIgaWYgZ2V0X2NtZGxpbmUgcmV0dXJuZWQgMCwgd2hpY2ggSSBiZWxp
ZXZlIHdpbGwgYmUgdGhlIGNhc2Ugd2hlbiBzb21lb25lIGpva2luZ2x5IHVubWFwcyB0aGUgYXJl
YSAoYWxsIG1heWJlIHdoZW4gaXQgaXMgc3dhcHBlZCBvdXQgYnV0IGNhbid0IGJlIHN3YXBwZWQg
aW4gZHVlIHRvIEkvTyBlcnJvcnMpLg0KW1dpbGxpYW0gUm9iZXJ0c10gDQpTb3JyeSBmb3IgdGhl
IHdlaXJkIGlubGluZSBwb3N0aW5nIChUaGFua3MgTVMgT3V0bG9vayBvZiBkb29tKS4gQW55d2F5
cywgdGhpcyBpc27igJl0IGEgbml0LiBUaGlzIGlzIGEgbWFqb3IgaXNzdWUgdGhhdCBzaG91bGQg
YmUgZGVhbHQgd2l0aC4gVGhhbmtzLg0KDQpBbHNvIHNpbmNlIHlvdSBhcmUganVzdCBwdXR0aW5n
IDAgaW4gdGhlcmUgYW55d2F5IEkgZG9uJ3Qgc2VlIG11Y2ggcG9pbnQgaW4gdGVzdGluZyBmb3Ig
aXQuDQoNCj4gKwkJY29udGV4dC0+Y21kbGluZSA9IGJ1ZjsNCj4gKwl9DQo+ICsJbXNnID0gY29u
dGV4dC0+Y21kbGluZTsNCj4gK291dDoNCj4gKwlhdWRpdF9sb2dfdW50cnVzdGVkc3RyaW5nKGFi
LCBtc2cpOw0KPiArfQ0KPiArDQoNCg0KDQotLQ0KTWF0ZXVzeiBHdXppaw0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
