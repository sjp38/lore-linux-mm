Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 589136B0253
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 05:29:45 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x83so73328729wma.2
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 02:29:45 -0700 (PDT)
Received: from smtp-out6.electric.net (smtp-out6.electric.net. [192.162.217.195])
        by mx.google.com with ESMTPS id u15si14749770lff.104.2016.07.25.02.29.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 02:29:44 -0700 (PDT)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 02/11] mm: Hardened usercopy
Date: Mon, 25 Jul 2016 09:27:31 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F502102@AcuExch.aculab.com>
References: <1468619065-3222-1-git-send-email-keescook@chromium.org>
 <1468619065-3222-3-git-send-email-keescook@chromium.org>
 <5790711f.2350420a.b4287.2cc0SMTPIN_ADDED_BROKEN@mx.google.com>
 <CAGXu5jLCu1Vv0uugKZrsjSEsoABgXJSOJ8GkKmrHbvj9jkC2YA@mail.gmail.com>
 <20160722174551.jddle6mf7zlq6xmb@treble>
In-Reply-To: <20160722174551.jddle6mf7zlq6xmb@treble>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Josh Poimboeuf' <jpoimboe@redhat.com>, Kees Cook <keescook@chromium.org>
Cc: Jan Kara <jack@suse.cz>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, sparclinux <sparclinux@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch <linux-arch@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Russell King <linux@armlinux.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, PaX Team <pageexec@freemail.hu>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Fenghua Yu <fenghua.yu@intel.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, Brad Spengler <spender@grsecurity.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Daniel
 Micay <danielmicay@gmail.com>, Casey Schaufler <casey@schaufler-ca.com>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "David S. Miller" <davem@davemloft.net>

RnJvbTogSm9zaCBQb2ltYm9ldWYNCj4gU2VudDogMjIgSnVseSAyMDE2IDE4OjQ2DQouLg0KPiA+
ID4+ICsvKg0KPiA+ID4+ICsgKiBDaGVja3MgaWYgYSBnaXZlbiBwb2ludGVyIGFuZCBsZW5ndGgg
aXMgY29udGFpbmVkIGJ5IHRoZSBjdXJyZW50DQo+ID4gPj4gKyAqIHN0YWNrIGZyYW1lIChpZiBw
b3NzaWJsZSkuDQo+ID4gPj4gKyAqDQo+ID4gPj4gKyAqICAgMDogbm90IGF0IGFsbCBvbiB0aGUg
c3RhY2sNCj4gPiA+PiArICogICAxOiBmdWxseSB3aXRoaW4gYSB2YWxpZCBzdGFjayBmcmFtZQ0K
PiA+ID4+ICsgKiAgIDI6IGZ1bGx5IG9uIHRoZSBzdGFjayAod2hlbiBjYW4ndCBkbyBmcmFtZS1j
aGVja2luZykNCj4gPiA+PiArICogICAtMTogZXJyb3IgY29uZGl0aW9uIChpbnZhbGlkIHN0YWNr
IHBvc2l0aW9uIG9yIGJhZCBzdGFjayBmcmFtZSkNCj4gPiA+PiArICovDQo+ID4gPj4gK3N0YXRp
YyBub2lubGluZSBpbnQgY2hlY2tfc3RhY2tfb2JqZWN0KGNvbnN0IHZvaWQgKm9iaiwgdW5zaWdu
ZWQgbG9uZyBsZW4pDQo+ID4gPj4gK3sNCj4gPiA+PiArICAgICBjb25zdCB2b2lkICogY29uc3Qg
c3RhY2sgPSB0YXNrX3N0YWNrX3BhZ2UoY3VycmVudCk7DQo+ID4gPj4gKyAgICAgY29uc3Qgdm9p
ZCAqIGNvbnN0IHN0YWNrZW5kID0gc3RhY2sgKyBUSFJFQURfU0laRTsNCj4gPiA+DQo+ID4gPiBU
aGF0IGFsbG93cyBhY2Nlc3MgdG8gdGhlIGVudGlyZSBzdGFjaywgaW5jbHVkaW5nIHRoZSBzdHJ1
Y3QgdGhyZWFkX2luZm8sDQo+ID4gPiBpcyB0aGF0IHdoYXQgd2Ugd2FudCAtIGl0IHNlZW1zIGRh
bmdlcm91cz8gT3IgZGlkIEkgbWlzcyBhIGNoZWNrDQo+ID4gPiBzb21ld2hlcmUgZWxzZT8NCj4g
Pg0KPiA+IFRoYXQgc2VlbXMgbGlrZSBhIG5pY2UgaW1wcm92ZW1lbnQgdG8gbWFrZSwgeWVhaC4N
Cj4gPg0KPiA+ID4gV2UgaGF2ZSBlbmRfb2Zfc3RhY2soKSB3aGljaCBjb21wdXRlcyB0aGUgZW5k
IG9mIHRoZSBzdGFjayB0YWtpbmcNCj4gPiA+IHRocmVhZF9pbmZvIGludG8gYWNjb3VudCAoZW5k
IGJlaW5nIHRoZSBvcHBvc2l0ZSBvZiB5b3VyIGVuZCBhYm92ZSkuDQo+ID4NCj4gPiBBbXVzaW5n
bHksIHRoZSBvYmplY3RfaXNfb25fc3RhY2soKSBjaGVjayBpbiBzY2hlZC5oIGRvZXNuJ3QgdGFr
ZQ0KPiA+IHRocmVhZF9pbmZvIGludG8gYWNjb3VudCBlaXRoZXIuIDpQIFJlZ2FyZGxlc3MsIEkg
dGhpbmsgdXNpbmcNCj4gPiBlbmRfb2Zfc3RhY2soKSBtYXkgbm90IGJlIGJlc3QuIFRvIHRpZ2h0
ZW4gdGhlIGNoZWNrLCBJIHRoaW5rIHdlIGNvdWxkDQo+ID4gYWRkIHRoaXMgYWZ0ZXIgY2hlY2tp
bmcgdGhhdCB0aGUgb2JqZWN0IGlzIG9uIHRoZSBzdGFjazoNCj4gPg0KPiA+ICNpZmRlZiBDT05G
SUdfU1RBQ0tfR1JPV1NVUA0KPiA+ICAgICAgICAgc3RhY2tlbmQgLT0gc2l6ZW9mKHN0cnVjdCB0
aHJlYWRfaW5mbyk7DQo+ID4gI2Vsc2UNCj4gPiAgICAgICAgIHN0YWNrICs9IHNpemVvZihzdHJ1
Y3QgdGhyZWFkX2luZm8pOw0KPiA+ICNlbmRpZg0KPiA+DQo+ID4gZS5nLiB0aGVuIGlmIHRoZSBw
b2ludGVyIHdhcyBpbiB0aGUgdGhyZWFkX2luZm8sIHRoZSBzZWNvbmQgdGVzdCB3b3VsZA0KPiA+
IGZhaWwsIHRyaWdnZXJpbmcgdGhlIHByb3RlY3Rpb24uDQo+IA0KPiBGV0lXLCB0aGlzIHdvbid0
IHdvcmsgcmlnaHQgb24geDg2IGFmdGVyIEFuZHkncw0KPiBDT05GSUdfVEhSRUFEX0lORk9fSU5f
VEFTSyBwYXRjaGVzIGdldCBtZXJnZWQuDQoNCldoYXQgZW5kcyB1cCBpbiB0aGUgJ3RocmVhZF9p
bmZvJyBhcmVhPw0KSWYgaXQgY29udGFpbnMgdGhlIGZwIHNhdmUgYXJlYSB0aGVuIHByb2dyYW1z
IGxpa2UgZ2RiIG1heSBlbmQgdXAgcmVxdWVzdGluZw0KY29weV9pbi9vdXQgZGlyZWN0bHkgZnJv
bSB0aGF0IGFyZWEuDQoNCkludGVyZXN0aW5nbHkgdGhlIGF2eCByZWdpc3RlcnMgZG9uJ3QgbmVl
ZCBzYXZpbmcgb24gYSBub3JtYWwgc3lzdGVtIGNhbGwNCmVudHJ5ICh0aGV5IGFyZSBhbGwgY2Fs
bGVyLXNhdmVkKSBzbyB0aGUga2VybmVsIHN0YWNrIGNhbiBzYWZlbHkgb3ZlcndyaXRlDQp0aGF0
IGFyZWEuDQpTeXNjYWxsIGVudHJ5IHByb2JhYmx5IG91Z2h0IHRvIGV4ZWN1dGUgdGhlICd6ZXJv
IGFsbCBhdnggcmVnaXN0ZXJzJyBpbnN0cnVjdGlvbi4NClRoZXkgZG8gbmVlZCBzYXZpbmcgb24g
aW50ZXJydXB0IGVudHJ5IC0gYnV0IHRoZSBzdGFjayB1c2VkIHdpbGwgYmUgbGVzcy4NCg0KCURh
dmlkDQoNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
