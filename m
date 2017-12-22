Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6893B6B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 11:34:40 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id a45so16838995wra.14
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 08:34:40 -0800 (PST)
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id j49si11072188wra.537.2017.12.22.08.34.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 08:34:39 -0800 (PST)
Received: from smtp03.buh.bitdefender.org (smtp.bitdefender.biz [10.17.80.77])
	by mx-sr.buh.bitdefender.com (Postfix) with ESMTP id 432687FBED
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 18:34:38 +0200 (EET)
From: Mircea CIRJALIU-MELIU <mcirjaliu@bitdefender.com>
Subject: RE: [RFC PATCH v4 08/18] kvm: add the VM introspection subsystem
Date: Fri, 22 Dec 2017 16:34:37 +0000
Message-ID: <737fa4bfb8e74ac096a8d7f5c0de1c34@mb1xmail.bitdefender.biz>
References: <20171218190642.7790-1-alazar@bitdefender.com>
 <20171218190642.7790-9-alazar@bitdefender.com>
 <936b9c5c-a7b2-4f11-c049-00b3cb0985cc@redhat.com>
In-Reply-To: <936b9c5c-a7b2-4f11-c049-00b3cb0985cc@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>, =?utf-8?B?QWRhbGJlciBMYXrEg3I=?= <alazar@bitdefender.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, =?utf-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, =?utf-8?B?TWloYWkgRG9uyJt1?= <mdontu@bitdefender.com>, Nicusor CITU <ncitu@bitdefender.com>, Marian
 Cristian ROTARIU <mrotariu@bitdefender.com>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogUGFvbG8gQm9uemluaSBb
bWFpbHRvOnBib256aW5pQHJlZGhhdC5jb21dDQo+IFNlbnQ6IEZyaWRheSwgMjIgRGVjZW1iZXIg
MjAxNyAxODowOQ0KPiBUbzogQWRhbGJlciBMYXrEg3IgPGFsYXphckBiaXRkZWZlbmRlci5jb20+
OyBrdm1Admdlci5rZXJuZWwub3JnDQo+IENjOiBsaW51eC1tbUBrdmFjay5vcmc7IFJhZGltIEty
xI1tw6HFmSA8cmtyY21hckByZWRoYXQuY29tPjsgWGlhbw0KPiBHdWFuZ3JvbmcgPGd1YW5ncm9u
Zy54aWFvQGxpbnV4LmludGVsLmNvbT47IE1paGFpIERvbsibdQ0KPiA8bWRvbnR1QGJpdGRlZmVu
ZGVyLmNvbT47IE5pY3Vzb3IgQ0lUVSA8bmNpdHVAYml0ZGVmZW5kZXIuY29tPjsNCj4gTWlyY2Vh
IENJUkpBTElVLU1FTElVIDxtY2lyamFsaXVAYml0ZGVmZW5kZXIuY29tPjsgTWFyaWFuIENyaXN0
aWFuDQo+IFJPVEFSSVUgPG1yb3Rhcml1QGJpdGRlZmVuZGVyLmNvbT4NCj4gU3ViamVjdDogUmU6
IFtSRkMgUEFUQ0ggdjQgMDgvMThdIGt2bTogYWRkIHRoZSBWTSBpbnRyb3NwZWN0aW9uIHN1YnN5
c3RlbQ0KPiANCj4gT24gMTgvMTIvMjAxNyAyMDowNiwgQWRhbGJlciBMYXrEg3Igd3JvdGU6DQo+
ID4gKwlwcmludF9oZXhfZHVtcF9kZWJ1Zygia3ZtaTogbmV3IHRva2VuICIsIERVTVBfUFJFRklY
X05PTkUsDQo+ID4gKwkJCSAgICAgMzIsIDEsIHRva2VuLCBzaXplb2Yoc3RydWN0DQo+IGt2bWlf
bWFwX21lbV90b2tlbiksDQo+ID4gKwkJCSAgICAgZmFsc2UpOw0KPiA+ICsNCj4gPiArCXRlcCA9
IGttYWxsb2Moc2l6ZW9mKHN0cnVjdCB0b2tlbl9lbnRyeSksIEdGUF9LRVJORUwpOw0KPiA+ICsJ
aWYgKHRlcCA9PSBOVUxMKQ0KPiA+ICsJCXJldHVybiAtRU5PTUVNOw0KPiA+ICsNCj4gPiArCUlO
SVRfTElTVF9IRUFEKCZ0ZXAtPnRva2VuX2xpc3QpOw0KPiA+ICsJbWVtY3B5KCZ0ZXAtPnRva2Vu
LCB0b2tlbiwgc2l6ZW9mKHN0cnVjdA0KPiBrdm1pX21hcF9tZW1fdG9rZW4pKTsNCj4gPiArCXRl
cC0+a3ZtID0ga3ZtOw0KPiA+ICsNCj4gPiArCXNwaW5fbG9jaygmdG9rZW5fbG9jayk7DQo+ID4g
KwlsaXN0X2FkZF90YWlsKCZ0ZXAtPnRva2VuX2xpc3QsICZ0b2tlbl9saXN0KTsNCj4gPiArCXNw
aW5fdW5sb2NrKCZ0b2tlbl9sb2NrKTsNCj4gPiArDQo+ID4gKwlyZXR1cm4gMDsNCj4gDQo+IFRo
aXMgYWxsb3dzIHVubGltaXRlZCBhbGxvY2F0aW9ucyBvbiB0aGUgaG9zdCBmcm9tIHRoZSBpbnRy
b3NwZWN0b3INCj4gZ3Vlc3QuICBZb3UgbXVzdCBvbmx5IGFsbG93IGEgZml4ZWQgbnVtYmVyIG9m
IHVuY29uc3VtZWQgdG9rZW5zIChlLmcuIDY0KS4NCj4gDQoNCkEgZmV3IGNvbW1pdHMgYWdvIEFk
YWxiZXJ0IExhemFyIHN1Z2dlc3RlZCBvbmx5IG9uZSB0b2tlbiBmb3IgZXZlcnkgVk0gKEkgZ3Vl
c3MgaW50cm9zcGVjdGVkIFZNKS4NCk9yaWdpbmFsIHRleHQgaGVyZToNCi8qIFRPRE86IFNob3Vs
ZCB3ZSBsaW1pdCB0aGUgbnVtYmVyIG9mIHRoZXNlIHRva2Vucz8NCiAqIEhhdmUgb25seSBvbmUg
Zm9yIGV2ZXJ5IFZNPw0KICovDQoNCkkgc3VnZ2VzdCB1c2luZyB0aGUgdG9rZW4gYXMgYW4gYXV0
aGVudGljYXRpb24ga2V5IHdpdGggZmluaXRlIGxpZmUtdGltZSAoc2ltaWxhciB0byBhIGJhbmtp
bmcgdG9rZW4pLg0KVGhlIGludHJvc3BlY3RvciAocHJvY2Vzcy90aHJlYWQpIGNhbiByZXF1ZXN0
IGEgbmV3IHRva2VuIGFzIHNvb24gYXMgdGhlIG9sZCBvbmUgZXhwaXJlcy4NClRoZSBpbnRyb3Nw
ZWN0ZWQgbWFjaGluZSBzaG91bGRuJ3QgYmUgYXNzb2NpYXRlZCB3aXRoIHRoZSB0b2tlbiBpbiB0
aGlzIGNhc2UuDQoNCj4gVGhhbmtzLA0KPiANCj4gUGFvbG8NCj4gDQo+IF9fX19fX19fX19fX19f
X19fX19fX19fXw0KPiBUaGlzIGVtYWlsIHdhcyBzY2FubmVkIGJ5IEJpdGRlZmVuZGVyDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
