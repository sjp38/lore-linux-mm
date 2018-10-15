Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id A414B6B0269
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 09:29:36 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id f124-v6so12747155wme.5
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 06:29:36 -0700 (PDT)
Received: from eu-smtp-delivery-151.mimecast.com (eu-smtp-delivery-151.mimecast.com. [207.82.80.151])
        by mx.google.com with ESMTPS id f10-v6si8209922wro.14.2018.10.15.06.29.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 06:29:35 -0700 (PDT)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] x86/entry/32: Fix setup of CS high bits
Date: Mon, 15 Oct 2018 13:29:34 +0000
Message-ID: <b3e6472fba2f4c5494dddc3ac48aba9b@AcuMS.aculab.com>
References: <1531906876-13451-1-git-send-email-joro@8bytes.org>
 <1531906876-13451-11-git-send-email-joro@8bytes.org>
 <97421241-2bc4-c3f1-4128-95b3e8a230d1@siemens.com>
 <35a24feb-5970-aa03-acbf-53428a159ace@web.de>
 <CALCETrWveao7jthnfKr5F=UyEpyowP0VA20eZi5OxizgT05EDA@mail.gmail.com>
 <406a08c7-6199-a32d-d385-c032fb4c34d6@siemens.com>
 <a16919d7e6504ad59a0fad828690bcb9@AcuMS.aculab.com>
 <1246b176-02bf-3c04-5470-69333951263b@siemens.com>
In-Reply-To: <1246b176-02bf-3c04-5470-69333951263b@siemens.com>
Content-Language: en-US
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Jan Kiszka' <jan.kiszka@siemens.com>, Andy Lutomirski <luto@kernel.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave
 Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>

RnJvbTogSmFuIEtpc3prYQ0KPiBPbiAxNS4xMC4xOCAxNToxNCwgRGF2aWQgTGFpZ2h0IHdyb3Rl
Og0KPiA+IEZyb206IEphbiBLaXN6a2ENCj4gPj4gU2VudDogMTUgT2N0b2JlciAyMDE4IDE0OjA5
DQo+ID4gLi4uDQo+ID4+PiBUaG9zZSBmaWVsZHMgYXJlIGdlbnVpbmVseSAxNiBiaXQuICBTbyB0
aGUgY29tbWVudCBzaG91bGQgc2F5DQo+ID4+PiBzb21ldGhpbmcgbGlrZSAiVGhvc2UgaGlnaCBi
aXRzIGFyZSB1c2VkIGZvciBDU19GUk9NX0VOVFJZX1NUQUNLIGFuZA0KPiA+Pj4gQ1NfRlJPTV9V
U0VSX0NSMyIuDQo+ID4+DQo+ID4+IC8qDQo+ID4+ICAgICogVGhlIGhpZ2ggYml0cyBvZiB0aGUg
Q1MgZHdvcmQgKF9fY3NoKSBhcmUgdXNlZCBmb3INCj4gPj4gICAgKiBDU19GUk9NX0VOVFJZX1NU
QUNLIGFuZCBDU19GUk9NX1VTRVJfQ1IzLiBDbGVhciB0aGVtIGluIGNhc2UNCj4gPj4gICAgKiBo
YXJkd2FyZSBkaWRuJ3QgZG8gdGhpcyBmb3IgdXMuDQo+ID4+ICAgICovDQo+ID4NCj4gPiBXaGF0
J3MgYSAnZHdvcmQnID8gOi0pDQo+ID4NCj4gPiBPbiBhIDMyYml0IHByb2Nlc3NvciBhICd3b3Jk
JyB3aWxsIGJlIDMyIGJpdHMgdG8gYSAnZG91YmxlLXdvcmQnDQo+ID4gd291bGQgYmUgNjQgYml0
cy4NCj4gPiBPbmUgb2YgdGhlIHdvcnN0IG5hbWVzIHRvIHVzZS4NCj4gDQo+IFRoYXQncyBpYTMy
IG5vbWVuY2xhdHVyZTogYSBkb3VibGV3b3JkIChkd29yZCkgaXMgYSAzMi1iaXQgdmFsdWUuDQoN
CkkgdGhpbmsgeW91IG1pc3NlZCB0aGUgOi0pDQpJIGRvbid0IHRoaW5rIGxpbnV4IHVzZXMgdGhh
dCB0ZXJtIHZlcnkgb2Z0ZW4uDQoNCkFueSBndWVzc2VzIGFzIHRvIHdoYXQgdHlwZSBEV09SRF9Q
VFIgaXM/DQooaW4gYSB3ZWxsIGtub3cgNjRiaXQgZW52aXJvbm1lbnQgdGhhdCB1c2VzIFVQUEVS
X0NBU0UgZm9yIHR5cGVzKS4NCg0KCURhdmlkDQoNCi0NClJlZ2lzdGVyZWQgQWRkcmVzcyBMYWtl
c2lkZSwgQnJhbWxleSBSb2FkLCBNb3VudCBGYXJtLCBNaWx0b24gS2V5bmVzLCBNSzEgMVBULCBV
Sw0KUmVnaXN0cmF0aW9uIE5vOiAxMzk3Mzg2IChXYWxlcykNCg==
