Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0856A6B0005
	for <linux-mm@kvack.org>; Wed,  4 May 2016 16:13:11 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id i75so141700701ioa.3
        for <linux-mm@kvack.org>; Wed, 04 May 2016 13:13:11 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id z128si888300oiz.240.2016.05.04.13.13.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 13:13:10 -0700 (PDT)
From: "Luruo, Kuthonuzo" <kuthonuzo.luruo@hpe.com>
Subject: RE: [PATCH] kasan: improve double-free detection
Date: Wed, 4 May 2016 20:13:07 +0000
Message-ID: <20E775CA4D599049A25800DE5799F6DD1F624B08@G4W3225.americas.hpqcorp.net>
References: <20160502094920.GA3005@cherokee.in.rdlabs.hpecorp.net>
 <CACT4Y+YV4A_YbDq5asowLJPUODottNHAKScWoRdUx6uy+TN-Uw@mail.gmail.com>
 <CACT4Y+Z_+crRUm0U89YwW3x99dtx9cfPoO+L6mD-uyzfZAMkKw@mail.gmail.com>
 <20E775CA4D599049A25800DE5799F6DD1F61F1B2@G9W0752.americas.hpqcorp.net>
 <CACT4Y+azLKpGXSqs2=7PKZLNHd61LN7FiAQeWLhw3yApVHadXQ@mail.gmail.com>
In-Reply-To: <CACT4Y+azLKpGXSqs2=7PKZLNHd61LN7FiAQeWLhw3yApVHadXQ@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

PiA+PiBJIG1pc3NlZCB0aGF0IEFsZXhhbmRlciBhbHJlYWR5IGxhbmRlZCBwYXRjaGVzIHRoYXQg
cmVkdWNlIGhlYWRlciBzaXplDQo+ID4+IHRvIDE2IGJ5dGVzLg0KPiA+PiBJdCBpcyBub3QgT0sg
dG8gaW5jcmVhc2UgdGhlbSBhZ2Fpbi4gUGxlYXNlIGxlYXZlIHN0YXRlIGFzIGJpdGZpZWxkDQo+
ID4+IGFuZCB1cGRhdGUgaXQgd2l0aCBDQVMgKGlmIHdlIGludHJvZHVjZSBoZWxwZXIgZnVuY3Rp
b25zIGZvciBzdGF0ZQ0KPiA+PiBtYW5pcHVsYXRpb24sIHRoZXkgd2lsbCBoaWRlIHRoZSBDQVMg
bG9vcCwgd2hpY2ggaXMgbmljZSkuDQo+ID4+DQo+ID4NCj4gPiBBdmFpbGFibGUgQ0FTIHByaW1p
dGl2ZXMvY29tcGlsZXIgZG8gbm90IHN1cHBvcnQgQ0FTIHdpdGggYml0ZmllbGQuIEkgcHJvcG9z
ZQ0KPiA+IHRvIGNoYW5nZSBrYXNhbl9hbGxvY19tZXRhIHRvOg0KPiA+DQo+ID4gc3RydWN0IGth
c2FuX2FsbG9jX21ldGEgew0KPiA+ICAgICAgICAgc3RydWN0IGthc2FuX3RyYWNrIHRyYWNrOw0K
PiA+ICAgICAgICAgdTE2IHNpemVfZGVsdGE7ICAgICAgICAgLyogb2JqZWN0X3NpemUgLSBhbGxv
YyBzaXplICovDQo+ID4gICAgICAgICB1OCBzdGF0ZTsgICAgICAgICAgICAgICAgICAgIC8qIGVu
dW0ga2FzYW5fc3RhdGUgKi8NCj4gPiAgICAgICAgIHU4IHJlc2VydmVkMTsNCj4gPiAgICAgICAg
IHUzMiByZXNlcnZlZDI7DQo+ID4gfQ0KPiA+DQo+ID4gVGhpcyBzaHJpbmtzIF91c2VkXyBtZXRh
IG9iamVjdCBieSAxIGJ5dGUgd3J0IHRoZSBvcmlnaW5hbC4gKGJ0dywgcGF0Y2ggdjEgZG9lcw0K
PiA+IG5vdCBpbmNyZWFzZSBvdmVyYWxsIGFsbG9jIG1ldGEgb2JqZWN0IHNpemUpLiAiQWxsb2Mg
c2l6ZSIsIHdoZXJlIG5lZWRlZCwgaXMNCj4gPiBlYXNpbHkgY2FsY3VsYXRlZCBhcyBhIGRlbHRh
IGZyb20gY2FjaGUtPm9iamVjdF9zaXplLg0KPiANCj4gDQo+IFdoYXQgaXMgdGhlIG1heGltdW0g
c2l6ZSB0aGF0IHNsYWIgY2FuIGFsbG9jYXRlPw0KPiBJIHJlbWVtYmVyIHNlZWluZyBzbGFicyBh
cyBsYXJnZSBhcyA0TUIgc29tZSB0aW1lIGFnbyAob3IgZGlkIEkNCj4gY29uZnVzZSBpdCB3aXRo
IHNvbWV0aGluZyBlbHNlPykuIElmIHRoZXJlIGFyZSBzdWNoIGxhcmdlIG9iamVjdHMsDQo+IHRo
YXQgMiBieXRlcyB3b24ndCBiZSBhYmxlIHRvIGhvbGQgZXZlbiBkZWx0YS4NCj4gSG93ZXZlciwg
bm93IG9uIG15IGRlc2t0b3AgSSBkb24ndCBzZWUgc2xhYnMgbGFyZ2VyIHRoYW4gMTZLQiBpbg0K
PiAvcHJvYy9zbGFiaW5mby4NCg0KbWF4IHNpemUgZm9yIFNMQUIncyBzbGFiIGlzIDMyTUI7IGRl
ZmF1bHQgaXMgNE1CLiBJIG11c3QgaGF2ZSBnb3R0ZW4gY29uZnVzZWQgYnkNClNMVUIncyA4S0Ig
bGltaXQuIEFueXdheSwgbmV3IGthc2FuX2FsbG9jX21ldGEgaW4gcGF0Y2ggVjI6DQoNCnN0cnVj
dCBrYXNhbl9hbGxvY19tZXRhIHsNCiAgICAgICAgc3RydWN0IGthc2FuX3RyYWNrIHRyYWNrOw0K
ICAgICAgICB1bmlvbiB7DQogICAgICAgICAgICAgICAgdTggbG9jazsNCiAgICAgICAgICAgICAg
ICBzdHJ1Y3Qgew0KICAgICAgICAgICAgICAgICAgICAgICAgdTMyIGR1bW15IDogODsNCiAgICAg
ICAgICAgICAgICAgICAgICAgIHUzMiBzaXplX2RlbHRhIDogMjQ7ICAgIC8qIG9iamVjdF9zaXpl
IC0gYWxsb2Mgc2l6ZSAqLw0KICAgICAgICAgICAgICAgIH07DQogICAgICAgIH07DQogICAgICAg
IHUzMiBzdGF0ZSA6IDI7ICAgICAgICAgICAgICAgICAgICAgICAgICAvKiBlbnVtIGthc2FuX2Fs
bG9jX3N0YXRlICovDQogICAgICAgIHUzMiB1bnVzZWQgOiAzMDsNCn07DQoNClRoaXMgdXNlcyAy
IG1vcmUgYml0cyB0aGFuIGN1cnJlbnQsIGJ1dCBnaXZlbiB0aGUgY29uc3RyYWludHMgSSB0aGlu
ayB0aGlzIGlzDQpjbG9zZSB0byBvcHRpbWFsLg0KDQpLdXRob251em8NCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
