Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 18E126B0005
	for <linux-mm@kvack.org>; Tue,  3 May 2016 05:24:58 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 4so27574551pfw.0
        for <linux-mm@kvack.org>; Tue, 03 May 2016 02:24:58 -0700 (PDT)
Received: from g1t5425.austin.hp.com (g1t5425.austin.hp.com. [15.216.225.55])
        by mx.google.com with ESMTPS id zz12si3587353pab.3.2016.05.03.02.24.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 May 2016 02:24:57 -0700 (PDT)
From: "Luruo, Kuthonuzo" <kuthonuzo.luruo@hpe.com>
Subject: RE: [PATCH] kasan: improve double-free detection
Date: Tue, 3 May 2016 09:24:52 +0000
Message-ID: <20E775CA4D599049A25800DE5799F6DD1F61F2B7@G9W0752.americas.hpqcorp.net>
References: <20160502094920.GA3005@cherokee.in.rdlabs.hpecorp.net>
 <CACT4Y+YV4A_YbDq5asowLJPUODottNHAKScWoRdUx6uy+TN-Uw@mail.gmail.com>
 <20E775CA4D599049A25800DE5799F6DD1F61EF48@G9W0752.americas.hpqcorp.net>
 <CACT4Y+Y5n0u=qLA9A=89B07gMVRiQ+6nQaob2_rk_mOOt57iQw@mail.gmail.com>
In-Reply-To: <CACT4Y+Y5n0u=qLA9A=89B07gMVRiQ+6nQaob2_rk_mOOt57iQw@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

PiANCj4gV2UgY2FuIHVzZSBwZXItaGVhZGVyIGxvY2sgYnkgc2V0dGluZyBzdGF0dXMgdG8gS0FT
QU5fU1RBVEVfTE9DS0VELiAgQQ0KPiB0aHJlYWQgY2FuIENBUyBhbnkgc3RhdHVzIHRvIEtBU0FO
X1NUQVRFX0xPQ0tFRCB3aGljaCBtZWFucyB0aGF0IGl0DQo+IGxvY2tlZCB0aGUgaGVhZGVyLiBJ
ZiBhbnkgdGhyZWFkIHRyaWVkIHRvIG1vZGlmeS9yZWFkIHRoZSBzdGF0dXMgYW5kDQo+IHRoZSBz
dGF0dXMgaXMgS0FTQU5fU1RBVEVfTE9DS0VELCB0aGVuIHRoZSB0aHJlYWQgd2FpdHMuDQoNClRo
YW5rcywgRG1pdHJ5LiBJJ3ZlIHN1Y2Nlc3NmdWxseSB0ZXN0ZWQgd2l0aCB0aGUgY29uY3VycmVu
dCBmcmVlIHNsYWJfdGVzdCB0ZXN0DQooYWxsb2Mgb24gY3B1IDA7IHRoZW4gY29uY3VycmVudCBm
cmVlcyBvbiBhbGwgb3RoZXIgY3B1cyBvbiBhIDEyLXZjcHUgS1ZNKSB1c2luZzoNCg0Kc3RhdGlj
IGlubGluZSBib29sIGthc2FuX2FsbG9jX3N0YXRlX2xvY2soc3RydWN0IGthc2FuX2FsbG9jX21l
dGEgKmFsbG9jX2luZm8pDQp7DQogICAgICAgIGlmIChjbXB4Y2hnKCZhbGxvY19pbmZvLT5zdGF0
ZSwgS0FTQU5fU1RBVEVfQUxMT0MsDQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIEtB
U0FOX1NUQVRFX0xPQ0tFRCkgPT0gS0FTQU5fU1RBVEVfQUxMT0MpDQogICAgICAgICAgICAgICAg
cmV0dXJuIHRydWU7DQogICAgICAgIHJldHVybiBmYWxzZTsNCn0NCg0Kc3RhdGljIGlubGluZSB2
b2lkIGthc2FuX2FsbG9jX3N0YXRlX3VubG9ja193YWl0KHN0cnVjdCBrYXNhbl9hbGxvY19tZXRh
DQogICAgICAgICAgICAgICAgKmFsbG9jX2luZm8pDQp7DQogICAgICAgIHdoaWxlIChhbGxvY19p
bmZvLT5zdGF0ZSA9PSBLQVNBTl9TVEFURV9MT0NLRUQpDQogICAgICAgICAgICAgICAgY3B1X3Jl
bGF4KCk7DQp9DQoNClJhY2UgIndpbm5lciIgc2V0cyBzdGF0ZSB0byBxdWFyYW50aW5lIGFzIHRo
ZSBsYXN0IHN0ZXA6DQoNCiAgICAgICAgaWYgKGthc2FuX2FsbG9jX3N0YXRlX2xvY2soYWxsb2Nf
aW5mbykpIHsNCiAgICAgICAgICAgICAgICBmcmVlX2luZm8gPSBnZXRfZnJlZV9pbmZvKGNhY2hl
LCBvYmplY3QpOw0KICAgICAgICAgICAgICAgIHF1YXJhbnRpbmVfcHV0KGZyZWVfaW5mbywgY2Fj
aGUpOw0KICAgICAgICAgICAgICAgIHNldF90cmFjaygmZnJlZV9pbmZvLT50cmFjaywgR0ZQX05P
V0FJVCk7DQogICAgICAgICAgICAgICAga2FzYW5fcG9pc29uX3NsYWJfZnJlZShjYWNoZSwgb2Jq
ZWN0KTsNCiAgICAgICAgICAgICAgICBhbGxvY19pbmZvLT5zdGF0ZSA9IEtBU0FOX1NUQVRFX1FV
QVJBTlRJTkU7DQogICAgICAgICAgICAgICAgcmV0dXJuIHRydWU7DQogICAgICAgIH0gZWxzZQ0K
ICAgICAgICAgICAgICAgIGthc2FuX2FsbG9jX3N0YXRlX3VubG9ja193YWl0KGFsbG9jX2luZm8p
Ow0KDQpOb3csIEknbSBub3Qgc3VyZSB3aGV0aGVyIG9uIGN1cnJlbnQgS0FTQU4tc3VwcG9ydGVk
IGFyY2hzLCBzdGF0ZSBieXRlIGxvYWQgaW4NCnRoZSBidXN5LXdhaXQgbG9vcCBpcyBhdG9taWMg
d3J0IHRoZSBLQVNBTl9TVEFURV9RVUFSQU5USU5FIGJ5dGUgc3RvcmUuDQpXb3VsZCB5b3UgYWR2
aXNlIHVzaW5nIENBUyBwcmltaXRpdmVzIGZvciBsb2FkL3N0b3JlIGhlcmUgdG9vPw0KDQo+ID4N
Cj4gPiBTdXJlLCBhIG5ldyB0ZXN0IGNhbiBiZSBhZGRlZCBmb3IgdGVzdF9rYXNhbi5rby4gVW5s
aWtlIHRoZSBvdGhlciB0ZXN0cywgYQ0KPiA+IGRvdWJsZS1mcmVlIHdvdWxkIGxpa2VseSBwYW5p
YyB0aGUgc3lzdGVtIGR1ZSB0byBzbGFiIGNvcnJ1cHRpb24uIFdvdWxkIGl0IHN0aWxsDQo+ID4g
YmUgIktBU0FOaWMiIGZvciBrYXNhbl9zbGFiX2ZyZWUoKSB0byByZXR1cm4gdHJ1ZSBhZnRlciBy
ZXBvcnRpbmcgZG91YmxlLWZyZWUNCj4gPiBhdHRlbXB0IGVycm9yIHNvIHRocmVhZCB3aWxsIG5v
dCBjYWxsIGludG8gX19jYWNoZV9mcmVlKCk/IEhvdyBkb2VzIEFTQU4NCj4gPiBoYW5kbGUgdGhp
cz8NCj4gDQo+IFllcywgc3VyZSwgaXQgaXMgT0sgdG8gcmV0dXJuIHRydWUgZnJvbSBrYXNhbl9z
bGFiX2ZyZWUoKSBpbiBzdWNoIGNhc2UuDQo+IFVzZS1zcGFjZSBBU0FOIHRlcm1pbmF0ZXMgdGhl
IHByb2Nlc3MgYWZ0ZXIgdGhlIGZpcnN0IHJlcG9ydC4gV2UndmUNCj4gZGVjaWRlZCB0aGF0IGlu
IGtlcm5lbCB3ZSBiZXR0ZXIgY29udGludWUgaW4gYmVzdC1lZmZvcnQgbWFubmVyLiBCdXQNCj4g
YWZ0ZXIgdGhlIGZpcnN0IHJlcG9ydCBhbGwgYmV0cyBhcmUgbW9zdGx5IG9mZiAobGVha2luZyBh
biBvYmplY3QgaXMNCj4gZGVmaW5pdGVseSBPSykuDQoNCnNvdW5kcyBnb29kOyBJJ20gYWxzbyAi
cHJvbW90aW5nIiBkb3VibGUtZnJlZSBwcl9lcnIoKSB0byBrYXNhbl9yZXBvcnQoKS4NCg0KS3V0
aG9udXpvDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
