Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 76AC26B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 11:18:41 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id p8so12802848wrh.17
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 08:18:41 -0800 (PST)
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id j127si6502017wma.144.2017.12.22.08.18.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 08:18:40 -0800 (PST)
Received: from smtp03.buh.bitdefender.org (smtp.bitdefender.biz [10.17.80.77])
	by mx-sr.buh.bitdefender.com (Postfix) with ESMTP id 43DFA7FBED
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 18:18:39 +0200 (EET)
From: Mircea CIRJALIU-MELIU <mcirjaliu@bitdefender.com>
Subject: RE: [RFC PATCH v4 08/18] kvm: add the VM introspection subsystem
Date: Fri, 22 Dec 2017 16:18:38 +0000
Message-ID: <06e5932438614d7092d67b88e336d3d8@mb1xmail.bitdefender.biz>
References: <20171218190642.7790-1-alazar@bitdefender.com>
 <20171218190642.7790-9-alazar@bitdefender.com>
 <533d5a75-1ac7-4cd4-347d-237a3c9a54c5@redhat.com>
In-Reply-To: <533d5a75-1ac7-4cd4-347d-237a3c9a54c5@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>, =?utf-8?B?QWRhbGJlciBMYXrEg3I=?= <alazar@bitdefender.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, =?utf-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, =?utf-8?B?TWloYWkgRG9uyJt1?= <mdontu@bitdefender.com>, Nicusor CITU <ncitu@bitdefender.com>, Marian Cristian ROTARIU <mrotariu@bitdefender.com>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogUGFvbG8gQm9uemluaSBb
bWFpbHRvOnBib256aW5pQHJlZGhhdC5jb21dDQo+IFNlbnQ6IEZyaWRheSwgMjIgRGVjZW1iZXIg
MjAxNyAxODowMg0KPiBUbzogQWRhbGJlciBMYXrEg3IgPGFsYXphckBiaXRkZWZlbmRlci5jb20+
OyBrdm1Admdlci5rZXJuZWwub3JnDQo+IENjOiBsaW51eC1tbUBrdmFjay5vcmc7IFJhZGltIEty
xI1tw6HFmSA8cmtyY21hckByZWRoYXQuY29tPjsgWGlhbw0KPiBHdWFuZ3JvbmcgPGd1YW5ncm9u
Zy54aWFvQGxpbnV4LmludGVsLmNvbT47IE1paGFpIERvbsibdQ0KPiA8bWRvbnR1QGJpdGRlZmVu
ZGVyLmNvbT47IE5pY3Vzb3IgQ0lUVSA8bmNpdHVAYml0ZGVmZW5kZXIuY29tPjsNCj4gTWlyY2Vh
IENJUkpBTElVLU1FTElVIDxtY2lyamFsaXVAYml0ZGVmZW5kZXIuY29tPjsgTWFyaWFuIENyaXN0
aWFuDQo+IFJPVEFSSVUgPG1yb3Rhcml1QGJpdGRlZmVuZGVyLmNvbT4NCj4gU3ViamVjdDogUmU6
IFtSRkMgUEFUQ0ggdjQgMDgvMThdIGt2bTogYWRkIHRoZSBWTSBpbnRyb3NwZWN0aW9uIHN1YnN5
c3RlbQ0KPiANCj4gT24gMTgvMTIvMjAxNyAyMDowNiwgQWRhbGJlciBMYXrEg3Igd3JvdGU6DQo+
ID4gKwkvKiBWTUFzIHdpbGwgYmUgbW9kaWZpZWQgKi8NCj4gPiArCWRvd25fd3JpdGUoJnJlcV9t
bS0+bW1hcF9zZW0pOw0KPiA+ICsJZG93bl93cml0ZSgmbWFwX21tLT5tbWFwX3NlbSk7DQo+ID4g
Kw0KPiANCj4gSXMgdGhlcmUgYSBsb2NraW5nIHJ1bGUgd2hlbiBsb2NraW5nIG11bHRpcGxlIG1t
YXBfc2VtcyBhdCB0aGUgc2FtZQ0KPiB0aW1lPyAgQXMgaXQncyB3cml0dGVuLCB0aGlzIGNhbiBj
YXVzZSBkZWFkbG9ja3MuDQoNCkZpcnN0IHJlcV9tbSwgc2Vjb25kIG1hcF9tbS4NClRoZSBvdGhl
ciBmdW5jdGlvbiB1c2VzIHRoZSBzYW1lIG5lc3RpbmcuDQoNCj4gDQo+IFBhb2xvDQo+IA0KPiBf
X19fX19fX19fX19fX19fX19fX19fX18NCj4gVGhpcyBlbWFpbCB3YXMgc2Nhbm5lZCBieSBCaXRk
ZWZlbmRlcg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
