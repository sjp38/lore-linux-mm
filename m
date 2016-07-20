Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 193866B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 05:54:17 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p129so28525204wmp.3
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 02:54:17 -0700 (PDT)
Received: from smtp-out6.electric.net (smtp-out6.electric.net. [192.162.217.186])
        by mx.google.com with ESMTPS id g193si1079003lfb.86.2016.07.20.02.54.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jul 2016 02:54:15 -0700 (PDT)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 00/11] mm: Hardened usercopy
Date: Wed, 20 Jul 2016 09:52:25 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4FD6A3@AcuExch.aculab.com>
References: <1468619065-3222-1-git-send-email-keescook@chromium.org>
In-Reply-To: <1468619065-3222-1-git-send-email-keescook@chromium.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Kees Cook' <keescook@chromium.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Jan Kara <jack@suse.cz>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Andrea
 Arcangeli <aarcange@redhat.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Russell King <linux@armlinux.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, PaX Team <pageexec@freemail.hu>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Fenghua Yu <fenghua.yu@intel.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, Brad Spengler <spender@grsecurity.net>, Ard
 Biesheuvel <ard.biesheuvel@linaro.org>, Pekka Enberg <penberg@kernel.org>, Daniel Micay <danielmicay@gmail.com>, Casey Schaufler <casey@schaufler-ca.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "David S.
 Miller" <davem@davemloft.net>

RnJvbTogS2VlcyBDb29rDQo+IFNlbnQ6IDE1IEp1bHkgMjAxNiAyMjo0NA0KPiBUaGlzIGlzIGEg
c3RhcnQgb2YgdGhlIG1haW5saW5lIHBvcnQgb2YgUEFYX1VTRVJDT1BZWzFdLiANCi4uLg0KPiAt
IGlmIGFkZHJlc3MgcmFuZ2UgaXMgaW4gdGhlIGN1cnJlbnQgcHJvY2VzcyBzdGFjaywgaXQgbXVz
dCBiZSB3aXRoaW4gdGhlDQo+ICAgY3VycmVudCBzdGFjayBmcmFtZSAoaWYgc3VjaCBjaGVja2lu
ZyBpcyBwb3NzaWJsZSkgb3IgYXQgbGVhc3QgZW50aXJlbHkNCj4gICB3aXRoaW4gdGhlIGN1cnJl
bnQgcHJvY2VzcydzIHN0YWNrLg0KLi4uDQoNClRoYXQgZGVzY3JpcHRpb24gZG9lc24ndCBzZWVt
IHF1aXRlIHJpZ2h0IHRvIG1lLg0KSSBwcmVzdW1lIHRoZSBjaGVjayBpczoNCiAgV2l0aGluIHRo
ZSBjdXJyZW50IHByb2Nlc3MncyBzdGFjayBhbmQgbm90IGNyb3NzaW5nIHRoZSBlbmRzIG9mIHRo
ZQ0KICBjdXJyZW50IHN0YWNrIGZyYW1lLg0KDQpUaGUgJ2N1cnJlbnQnIHN0YWNrIGZyYW1lIGlz
IGxpa2VseSB0byBiZSB0aGF0IG9mIGNvcHlfdG8vZnJvbV91c2VyKCkuDQpFdmVuIGlmIHlvdSB1
c2UgdGhlIHN0YWNrIG9mIHRoZSBjYWxsZXIsIGFueSBwcm9ibGVtYXRpYyBidWZmZXJzDQphcmUg
bGlrZWx5IHRvIGhhdmUgYmVlbiBwYXNzZWQgaW4gZnJvbSBhIGNhbGxpbmcgZnVuY3Rpb24uDQpT
byB1bmxlc3MgeW91IGFyZSBnb2luZyB0byB3YWxrIHRoZSBzdGFjayAoZ29vZCBsdWNrIG9uIHRo
YXQpDQpJJ20gbm90IHN1cmUgY2hlY2tpbmcgdGhlIHN0YWNrIGZyYW1lcyBpcyB3b3J0aCBpdC4N
Cg0KSSdkIGFsc28gZ3Vlc3MgdGhhdCBhIGxvdCBvZiBjb3BpZXMgYXJlIGZyb20gdGhlIG1pZGRs
ZSBvZiBzdHJ1Y3R1cmVzDQpzbyBjYW5ub3QgZmFpbCB0aGUgdGVzdHMgeW91IGFyZSBhZGRpbmcu
DQoNCglEYXZpZA0KDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
