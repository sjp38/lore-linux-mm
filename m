Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C61F66B0005
	for <linux-mm@kvack.org>; Tue,  3 May 2016 03:53:22 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 77so23753208pfz.3
        for <linux-mm@kvack.org>; Tue, 03 May 2016 00:53:22 -0700 (PDT)
Received: from g1t5425.austin.hp.com (g1t5425.austin.hp.com. [15.216.225.55])
        by mx.google.com with ESMTPS id s3si3115526pac.47.2016.05.03.00.53.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 May 2016 00:53:22 -0700 (PDT)
From: "Luruo, Kuthonuzo" <kuthonuzo.luruo@hpe.com>
Subject: RE: [PATCH] kasan: improve double-free detection
Date: Tue, 3 May 2016 07:53:17 +0000
Message-ID: <20E775CA4D599049A25800DE5799F6DD1F61F1B2@G9W0752.americas.hpqcorp.net>
References: <20160502094920.GA3005@cherokee.in.rdlabs.hpecorp.net>
 <CACT4Y+YV4A_YbDq5asowLJPUODottNHAKScWoRdUx6uy+TN-Uw@mail.gmail.com>
 <CACT4Y+Z_+crRUm0U89YwW3x99dtx9cfPoO+L6mD-uyzfZAMkKw@mail.gmail.com>
In-Reply-To: <CACT4Y+Z_+crRUm0U89YwW3x99dtx9cfPoO+L6mD-uyzfZAMkKw@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

PiBJIG1pc3NlZCB0aGF0IEFsZXhhbmRlciBhbHJlYWR5IGxhbmRlZCBwYXRjaGVzIHRoYXQgcmVk
dWNlIGhlYWRlciBzaXplDQo+IHRvIDE2IGJ5dGVzLg0KPiBJdCBpcyBub3QgT0sgdG8gaW5jcmVh
c2UgdGhlbSBhZ2Fpbi4gUGxlYXNlIGxlYXZlIHN0YXRlIGFzIGJpdGZpZWxkDQo+IGFuZCB1cGRh
dGUgaXQgd2l0aCBDQVMgKGlmIHdlIGludHJvZHVjZSBoZWxwZXIgZnVuY3Rpb25zIGZvciBzdGF0
ZQ0KPiBtYW5pcHVsYXRpb24sIHRoZXkgd2lsbCBoaWRlIHRoZSBDQVMgbG9vcCwgd2hpY2ggaXMg
bmljZSkuDQo+IA0KDQpBdmFpbGFibGUgQ0FTIHByaW1pdGl2ZXMvY29tcGlsZXIgZG8gbm90IHN1
cHBvcnQgQ0FTIHdpdGggYml0ZmllbGQuIEkgcHJvcG9zZQ0KdG8gY2hhbmdlIGthc2FuX2FsbG9j
X21ldGEgdG86DQoNCnN0cnVjdCBrYXNhbl9hbGxvY19tZXRhIHsNCiAgICAgICAgc3RydWN0IGth
c2FuX3RyYWNrIHRyYWNrOw0KICAgICAgICB1MTYgc2l6ZV9kZWx0YTsgICAgICAgICAvKiBvYmpl
Y3Rfc2l6ZSAtIGFsbG9jIHNpemUgKi8NCiAgICAgICAgdTggc3RhdGU7ICAgICAgICAgICAgICAg
ICAgICAvKiBlbnVtIGthc2FuX3N0YXRlICovDQogICAgICAgIHU4IHJlc2VydmVkMTsNCiAgICAg
ICAgdTMyIHJlc2VydmVkMjsNCn0NCg0KVGhpcyBzaHJpbmtzIF91c2VkXyBtZXRhIG9iamVjdCBi
eSAxIGJ5dGUgd3J0IHRoZSBvcmlnaW5hbC4gKGJ0dywgcGF0Y2ggdjEgZG9lcw0Kbm90IGluY3Jl
YXNlIG92ZXJhbGwgYWxsb2MgbWV0YSBvYmplY3Qgc2l6ZSkuICJBbGxvYyBzaXplIiwgd2hlcmUg
bmVlZGVkLCBpcw0KZWFzaWx5IGNhbGN1bGF0ZWQgYXMgYSBkZWx0YSBmcm9tIGNhY2hlLT5vYmpl
Y3Rfc2l6ZS4NCg0KS3V0aG9udXpvDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
