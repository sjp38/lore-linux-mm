Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 30F746B0005
	for <linux-mm@kvack.org>; Tue,  3 May 2016 03:59:15 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id d62so33432113iof.1
        for <linux-mm@kvack.org>; Tue, 03 May 2016 00:59:15 -0700 (PDT)
Received: from g1t5425.austin.hp.com (g1t5425.austin.hp.com. [15.216.225.55])
        by mx.google.com with ESMTPS id e37si1122612ioj.10.2016.05.03.00.59.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 May 2016 00:59:14 -0700 (PDT)
From: "Luruo, Kuthonuzo" <kuthonuzo.luruo@hpe.com>
Subject: RE: [PATCH] kasan: improve double-free detection
Date: Tue, 3 May 2016 07:58:57 +0000
Message-ID: <20E775CA4D599049A25800DE5799F6DD1F61F1DD@G9W0752.americas.hpqcorp.net>
References: <20160502094920.GA3005@cherokee.in.rdlabs.hpecorp.net>
	<CACT4Y+YV4A_YbDq5asowLJPUODottNHAKScWoRdUx6uy+TN-Uw@mail.gmail.com>
	<CACT4Y+Z_+crRUm0U89YwW3x99dtx9cfPoO+L6mD-uyzfZAMkKw@mail.gmail.com>
 <CAG_fn=U3-JxoOExtG3Zi3WJ4Xoao5OVWN-eZ-05u+hJ9Pr+kyQ@mail.gmail.com>
In-Reply-To: <CAG_fn=U3-JxoOExtG3Zi3WJ4Xoao5OVWN-eZ-05u+hJ9Pr+kyQ@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

PiA+DQo+ID4gSSBtaXNzZWQgdGhhdCBBbGV4YW5kZXIgYWxyZWFkeSBsYW5kZWQgcGF0Y2hlcyB0
aGF0IHJlZHVjZSBoZWFkZXIgc2l6ZQ0KPiA+IHRvIDE2IGJ5dGVzLg0KPiA+IEl0IGlzIG5vdCBP
SyB0byBpbmNyZWFzZSB0aGVtIGFnYWluLiBQbGVhc2UgbGVhdmUgc3RhdGUgYXMgYml0ZmllbGQN
Cj4gPiBhbmQgdXBkYXRlIGl0IHdpdGggQ0FTIChpZiB3ZSBpbnRyb2R1Y2UgaGVscGVyIGZ1bmN0
aW9ucyBmb3Igc3RhdGUNCj4gPiBtYW5pcHVsYXRpb24sIHRoZXkgd2lsbCBoaWRlIHRoZSBDQVMg
bG9vcCwgd2hpY2ggaXMgbmljZSkuDQo+IE5vdGUgdGhhdCBpbiB0aGlzIGNhc2UgeW91J2xsIHBy
b2JhYmx5IG5lZWQgdG8gdXBkYXRlIGFsbG9jX3NpemUgd2l0aA0KPiBDQVMgbG9vcCBhcyB3ZWxs
Lg0KDQpOb3Qgc3VyZSBJIHVuZGVyc3Rvb2QgdGhpczsgQW55d2F5LCByZXZpc2VkIGthc2FuX2Fs
bG9jX21ldGEgaW4gdXBjb21pbmcgcGF0Y2gNCnNob3VsZCBtYWtlIHRoaXMgdW5uZWNlc3Nhcnku
DQoNClRoYW5rcywNCg0KS3V0aG9udXpvDQoNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
