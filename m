Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5CFD76B0010
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 09:14:10 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id v4-v6so15532143plz.21
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 06:14:10 -0700 (PDT)
Received: from eu-smtp-delivery-151.mimecast.com (eu-smtp-delivery-151.mimecast.com. [207.82.80.151])
        by mx.google.com with ESMTPS id c191-v6si10599616pga.402.2018.10.15.06.14.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 06:14:09 -0700 (PDT)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] x86/entry/32: Fix setup of CS high bits
Date: Mon, 15 Oct 2018 13:14:06 +0000
Message-ID: <a16919d7e6504ad59a0fad828690bcb9@AcuMS.aculab.com>
References: <1531906876-13451-1-git-send-email-joro@8bytes.org>
 <1531906876-13451-11-git-send-email-joro@8bytes.org>
 <97421241-2bc4-c3f1-4128-95b3e8a230d1@siemens.com>
 <35a24feb-5970-aa03-acbf-53428a159ace@web.de>
 <CALCETrWveao7jthnfKr5F=UyEpyowP0VA20eZi5OxizgT05EDA@mail.gmail.com>
 <406a08c7-6199-a32d-d385-c032fb4c34d6@siemens.com>
In-Reply-To: <406a08c7-6199-a32d-d385-c032fb4c34d6@siemens.com>
Content-Language: en-US
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Jan Kiszka' <jan.kiszka@siemens.com>, Andy Lutomirski <luto@kernel.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave
 Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>

RnJvbTogSmFuIEtpc3prYQ0KPiBTZW50OiAxNSBPY3RvYmVyIDIwMTggMTQ6MDkNCi4uLg0KPiA+
IFRob3NlIGZpZWxkcyBhcmUgZ2VudWluZWx5IDE2IGJpdC4gIFNvIHRoZSBjb21tZW50IHNob3Vs
ZCBzYXkNCj4gPiBzb21ldGhpbmcgbGlrZSAiVGhvc2UgaGlnaCBiaXRzIGFyZSB1c2VkIGZvciBD
U19GUk9NX0VOVFJZX1NUQUNLIGFuZA0KPiA+IENTX0ZST01fVVNFUl9DUjMiLg0KPiANCj4gLyoN
Cj4gICAqIFRoZSBoaWdoIGJpdHMgb2YgdGhlIENTIGR3b3JkIChfX2NzaCkgYXJlIHVzZWQgZm9y
DQo+ICAgKiBDU19GUk9NX0VOVFJZX1NUQUNLIGFuZCBDU19GUk9NX1VTRVJfQ1IzLiBDbGVhciB0
aGVtIGluIGNhc2UNCj4gICAqIGhhcmR3YXJlIGRpZG4ndCBkbyB0aGlzIGZvciB1cy4NCj4gICAq
Lw0KDQpXaGF0J3MgYSAnZHdvcmQnID8gOi0pDQoNCk9uIGEgMzJiaXQgcHJvY2Vzc29yIGEgJ3dv
cmQnIHdpbGwgYmUgMzIgYml0cyB0byBhICdkb3VibGUtd29yZCcNCndvdWxkIGJlIDY0IGJpdHMu
DQpPbmUgb2YgdGhlIHdvcnN0IG5hbWVzIHRvIHVzZS4NCg0KCURhdmlkDQoNCi0NClJlZ2lzdGVy
ZWQgQWRkcmVzcyBMYWtlc2lkZSwgQnJhbWxleSBSb2FkLCBNb3VudCBGYXJtLCBNaWx0b24gS2V5
bmVzLCBNSzEgMVBULCBVSw0KUmVnaXN0cmF0aW9uIE5vOiAxMzk3Mzg2IChXYWxlcykNCg==
