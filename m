Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id AD4456B0035
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 01:36:25 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lf10so5611824pab.36
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 22:36:25 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id hi9si20799673pac.72.2014.09.14.22.36.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 14 Sep 2014 22:36:24 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Mon, 15 Sep 2014 13:36:13 +0800
Subject: RE: [RFC] Free the reserved memblock when free cma pages
Message-ID: <35FD53F367049845BC99AC72306C23D103D6DB4915FD@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103CDBFBFB016@CNBJMBX05.corpusers.net>
 <20140915052151.GI2160@bbox>
In-Reply-To: <20140915052151.GI2160@bbox>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>
Cc: "'mhocko@suse.cz'" <mhocko@suse.cz>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'akpm@linux-foundation.org'" <akpm@linux-foundation.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, "hughd@google.com" <hughd@google.com>, "b.zolnierkie@samsung.com" <b.zolnierkie@samsung.com>

SGkgS2ltLA0KDQpJIHRoaW5rIG1vdmUgbWVtYmxvY2tfZnJlZSBpbnRvIGluaXRfY21hX3Jlc2Vy
dmVkX3BhZ2VibG9jaw0KSXMgbm90IGEgZ29vZCBpZGVhLA0KQmVjYXVzZSB0aGlzIHdpbGwgbmVl
ZCBjYWxsIG1lbWJsb2NrX2ZyZWUgZm9yDQpFdmVyeSBwYWdlIHJlbGVhc2UsDQpUaGluayB0aGF0
IGZvciBhIDRNQiBtZW1vcnksIG5lZWQgY2FsbCBtZW1ibG9ja19mcmVlDQoxMDI0IHRpbWVzICwg
aW5zdGVhZCwgd2UganVzdCBjYWxsIG1lbWJsb2NrX2ZyZWUgb25lDQpUaW1lIGZvciBldmVyeSBw
YWdlYmxvY2tfbnJfcGFnZXMgcGFnZXMgLg0KDQpJIHdpbGwgYWRkIHNvbWUgZGVzY3JpcHRpb25z
IGluIGNtYV9kZWNsYXJlX2NvbnRpZ3VvdXMNCkZvciBwYXRjaCB2ZXJzaW9uIDIgLg0KDQpUaGFu
a3MNCg0KLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCkhlbGxvLA0KDQpPbiBUdWUsIFNlcCAw
OSwgMjAxNCBhdCAwMjoxMzo1OFBNICswODAwLCBXYW5nLCBZYWxpbiB3cm90ZToNCj4gVGhpcyBw
YXRjaCBhZGQgbWVtYmxvY2tfZnJlZSB0byBhbHNvIGZyZWUgdGhlIHJlc2VydmVkIG1lbWJsb2Nr
LCBzbyANCj4gdGhhdCB0aGUgY21hIHBhZ2VzIGFyZSBub3QgbWFya2VkIGFzIHJlc2VydmVkIG1l
bW9yeSBpbiANCj4gL3N5cy9rZXJuZWwvZGVidWcvbWVtYmxvY2svcmVzZXJ2ZWQgZGVidWcgZmls
ZQ0KPiANCj4gU2lnbmVkLW9mZi1ieTogWWFsaW4gV2FuZyA8eWFsaW4ud2FuZ0Bzb255bW9iaWxl
LmNvbT4NCj4gLS0tDQo+ICBtbS9jbWEuYyB8IDIgKysNCj4gIDEgZmlsZSBjaGFuZ2VkLCAyIGlu
c2VydGlvbnMoKykNCj4gDQo+IGRpZmYgLS1naXQgYS9tbS9jbWEuYyBiL21tL2NtYS5jDQo+IGlu
ZGV4IGMxNzc1MWMuLmYzZWM3NTYgMTAwNjQ0DQo+IC0tLSBhL21tL2NtYS5jDQo+ICsrKyBiL21t
L2NtYS5jDQo+IEBAIC0xMTQsNiArMTE0LDggQEAgc3RhdGljIGludCBfX2luaXQgY21hX2FjdGl2
YXRlX2FyZWEoc3RydWN0IGNtYSAqY21hKQ0KPiAgCQkJCWdvdG8gZXJyOw0KPiAgCQl9DQo+ICAJ
CWluaXRfY21hX3Jlc2VydmVkX3BhZ2VibG9jayhwZm5fdG9fcGFnZShiYXNlX3BmbikpOw0KPiAr
CQltZW1ibG9ja19mcmVlKF9fcGZuX3RvX3BoeXMoYmFzZV9wZm4pLA0KPiArCQkJCXBhZ2VibG9j
a19ucl9wYWdlcyAqIFBBR0VfU0laRSk7DQoNCk5pdHBpY2s6DQoNCkNvdWxkbid0IHdlIGFkZCBt
ZW1ibG9ja19mcmVlIGludG8gaW5pdF9jbWFfcmVzZXJ2ZWRfcGFnZWJsb2NrPw0KQmVjYXVzZSBp
dCBzaG91bGQgYmUgcGFpciB3aXRoIENsZWFyUGFnZVJlc2VydmVkLCBJIHRoaW5rLg0KDQpJbiBh
ZGRpdGlvbiwgcGxlYXNlIGFkZCBkZXNjcmlwdGlvbiBvbiBtZW1vcnkgcmVzZXJ2ZSBwYXJ0IGlu
IGNtYV9kZWNsYXJlX2NvbnRpZ3VvdXMuDQoNCj4gIAl9IHdoaWxlICgtLWkpOw0KPiAgDQo+ICAJ
bXV0ZXhfaW5pdCgmY21hLT5sb2NrKTsNCj4gLS0NCj4gMi4xLjANCj4gDQo+IC0tDQo+IFRvIHVu
c3Vic2NyaWJlLCBzZW5kIGEgbWVzc2FnZSB3aXRoICd1bnN1YnNjcmliZSBsaW51eC1tbScgaW4g
dGhlIGJvZHkgDQo+IHRvIG1ham9yZG9tb0BrdmFjay5vcmcuICBGb3IgbW9yZSBpbmZvIG9uIExp
bnV4IE1NLA0KPiBzZWU6IGh0dHA6Ly93d3cubGludXgtbW0ub3JnLyAuDQo+IERvbid0IGVtYWls
OiA8YSBocmVmPW1haWx0bzoiZG9udEBrdmFjay5vcmciPiBlbWFpbEBrdmFjay5vcmcgPC9hPg0K
DQotLQ0KS2luZCByZWdhcmRzLA0KTWluY2hhbiBLaW0NCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
