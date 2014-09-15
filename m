Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 1BC016B0035
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 01:46:49 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id bj1so5597755pad.9
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 22:46:48 -0700 (PDT)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id gw10si20560183pac.240.2014.09.14.22.46.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 14 Sep 2014 22:46:48 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Mon, 15 Sep 2014 13:46:40 +0800
Subject: RE: [RFC] Free the reserved memblock when free cma pages
Message-ID: <35FD53F367049845BC99AC72306C23D103D6DB4915FE@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103CDBFBFB016@CNBJMBX05.corpusers.net>
 <20140915052151.GI2160@bbox>
 <35FD53F367049845BC99AC72306C23D103D6DB4915FD@CNBJMBX05.corpusers.net>
 <20140915054236.GJ2160@bbox>
In-Reply-To: <20140915054236.GJ2160@bbox>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>
Cc: "'mhocko@suse.cz'" <mhocko@suse.cz>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'akpm@linux-foundation.org'" <akpm@linux-foundation.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, "hughd@google.com" <hughd@google.com>, "b.zolnierkie@samsung.com" <b.zolnierkie@samsung.com>

SGkgS2ltLA0KDQpPaCwgbXkgbWlzdGFrZSwNCkkgc2VlIHlvdXIgbWVhbmluZywNCkkgd2lsbCBy
ZXNlbmQgYSBuZXcgcGF0Y2guDQoNClRoYW5rcyBmb3IgeW91ciBhZHZpY2UuDQoNCi0tLS0tT3Jp
Z2luYWwgTWVzc2FnZS0tLS0tDQpPbiBNb24sIFNlcCAxNSwgMjAxNCBhdCAwMTozNjoxM1BNICsw
ODAwLCBXYW5nLCBZYWxpbiB3cm90ZToNCj4gSGkgS2ltLA0KPiANCj4gSSB0aGluayBtb3ZlIG1l
bWJsb2NrX2ZyZWUgaW50byBpbml0X2NtYV9yZXNlcnZlZF9wYWdlYmxvY2sgSXMgbm90IGEgDQo+
IGdvb2QgaWRlYSwgQmVjYXVzZSB0aGlzIHdpbGwgbmVlZCBjYWxsIG1lbWJsb2NrX2ZyZWUgZm9y
IEV2ZXJ5IHBhZ2UgDQo+IHJlbGVhc2UsIFRoaW5rIHRoYXQgZm9yIGEgNE1CIG1lbW9yeSwgbmVl
ZCBjYWxsIG1lbWJsb2NrX2ZyZWUNCj4gMTAyNCB0aW1lcyAsIGluc3RlYWQsIHdlIGp1c3QgY2Fs
bCBtZW1ibG9ja19mcmVlIG9uZSBUaW1lIGZvciBldmVyeSANCj4gcGFnZWJsb2NrX25yX3BhZ2Vz
IHBhZ2VzIC4NCg0KV2h5Pw0KDQpkaWZmIC0tZ2l0IGEvbW0vcGFnZV9hbGxvYy5jIGIvbW0vcGFn
ZV9hbGxvYy5jIGluZGV4IDE5NTNhMjQzODM2Yi4uODc2Yjc4OTM3OGFmIDEwMDY0NA0KLS0tIGEv
bW0vcGFnZV9hbGxvYy5jDQorKysgYi9tbS9wYWdlX2FsbG9jLmMNCkBAIC04NDgsNiArODQ4LDkg
QEAgdm9pZCBfX2luaXQgaW5pdF9jbWFfcmVzZXJ2ZWRfcGFnZWJsb2NrKHN0cnVjdCBwYWdlICpw
YWdlKQ0KIAl9DQogDQogCWFkanVzdF9tYW5hZ2VkX3BhZ2VfY291bnQocGFnZSwgcGFnZWJsb2Nr
X25yX3BhZ2VzKTsNCisJbWVtYmxvY2tfZnJlZShwYWdlX3RvX3BoeXMocGFnZSksDQorCQkJCXBh
Z2VibG9ja19ucl9wYWdlcyAqIFBBR0VfU0laRSk7DQorDQogfQ0KICNlbmRpZg0KIA0KPiANCj4g
SSB3aWxsIGFkZCBzb21lIGRlc2NyaXB0aW9ucyBpbiBjbWFfZGVjbGFyZV9jb250aWd1b3VzIEZv
ciBwYXRjaCANCj4gdmVyc2lvbiAyIC4NCj4gDQo+IFRoYW5rcw0KPiANCj4gLS0tLS1PcmlnaW5h
bCBNZXNzYWdlLS0tLS0NCj4gSGVsbG8sDQo+IA0KPiBPbiBUdWUsIFNlcCAwOSwgMjAxNCBhdCAw
MjoxMzo1OFBNICswODAwLCBXYW5nLCBZYWxpbiB3cm90ZToNCj4gPiBUaGlzIHBhdGNoIGFkZCBt
ZW1ibG9ja19mcmVlIHRvIGFsc28gZnJlZSB0aGUgcmVzZXJ2ZWQgbWVtYmxvY2ssIHNvIA0KPiA+
IHRoYXQgdGhlIGNtYSBwYWdlcyBhcmUgbm90IG1hcmtlZCBhcyByZXNlcnZlZCBtZW1vcnkgaW4g
DQo+ID4gL3N5cy9rZXJuZWwvZGVidWcvbWVtYmxvY2svcmVzZXJ2ZWQgZGVidWcgZmlsZQ0KPiA+
IA0KPiA+IFNpZ25lZC1vZmYtYnk6IFlhbGluIFdhbmcgPHlhbGluLndhbmdAc29ueW1vYmlsZS5j
b20+DQo+ID4gLS0tDQo+ID4gIG1tL2NtYS5jIHwgMiArKw0KPiA+ICAxIGZpbGUgY2hhbmdlZCwg
MiBpbnNlcnRpb25zKCspDQo+ID4gDQo+ID4gZGlmZiAtLWdpdCBhL21tL2NtYS5jIGIvbW0vY21h
LmMNCj4gPiBpbmRleCBjMTc3NTFjLi5mM2VjNzU2IDEwMDY0NA0KPiA+IC0tLSBhL21tL2NtYS5j
DQo+ID4gKysrIGIvbW0vY21hLmMNCj4gPiBAQCAtMTE0LDYgKzExNCw4IEBAIHN0YXRpYyBpbnQg
X19pbml0IGNtYV9hY3RpdmF0ZV9hcmVhKHN0cnVjdCBjbWEgKmNtYSkNCj4gPiAgCQkJCWdvdG8g
ZXJyOw0KPiA+ICAJCX0NCj4gPiAgCQlpbml0X2NtYV9yZXNlcnZlZF9wYWdlYmxvY2socGZuX3Rv
X3BhZ2UoYmFzZV9wZm4pKTsNCj4gPiArCQltZW1ibG9ja19mcmVlKF9fcGZuX3RvX3BoeXMoYmFz
ZV9wZm4pLA0KPiA+ICsJCQkJcGFnZWJsb2NrX25yX3BhZ2VzICogUEFHRV9TSVpFKTsNCj4gDQo+
IE5pdHBpY2s6DQo+IA0KPiBDb3VsZG4ndCB3ZSBhZGQgbWVtYmxvY2tfZnJlZSBpbnRvIGluaXRf
Y21hX3Jlc2VydmVkX3BhZ2VibG9jaz8NCj4gQmVjYXVzZSBpdCBzaG91bGQgYmUgcGFpciB3aXRo
IENsZWFyUGFnZVJlc2VydmVkLCBJIHRoaW5rLg0KPiANCj4gSW4gYWRkaXRpb24sIHBsZWFzZSBh
ZGQgZGVzY3JpcHRpb24gb24gbWVtb3J5IHJlc2VydmUgcGFydCBpbiBjbWFfZGVjbGFyZV9jb250
aWd1b3VzLg0KPiANCj4gPiAgCX0gd2hpbGUgKC0taSk7DQo+ID4gIA0KPiA+ICAJbXV0ZXhfaW5p
dCgmY21hLT5sb2NrKTsNCj4gPiAtLQ0KPiA+IDIuMS4wDQo+ID4gDQo+ID4gLS0NCj4gPiBUbyB1
bnN1YnNjcmliZSwgc2VuZCBhIG1lc3NhZ2Ugd2l0aCAndW5zdWJzY3JpYmUgbGludXgtbW0nIGlu
IHRoZSANCj4gPiBib2R5IHRvIG1ham9yZG9tb0BrdmFjay5vcmcuICBGb3IgbW9yZSBpbmZvIG9u
IExpbnV4IE1NLA0KPiA+IHNlZTogaHR0cDovL3d3dy5saW51eC1tbS5vcmcvIC4NCj4gPiBEb24n
dCBlbWFpbDogPGEgaHJlZj1tYWlsdG86ImRvbnRAa3ZhY2sub3JnIj4gZW1haWxAa3ZhY2sub3Jn
IDwvYT4NCj4gDQo+IC0tDQo+IEtpbmQgcmVnYXJkcywNCj4gTWluY2hhbiBLaW0NCg0KLS0NCktp
bmQgcmVnYXJkcywNCk1pbmNoYW4gS2ltDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
