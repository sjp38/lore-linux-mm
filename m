Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0C96B0005
	for <linux-mm@kvack.org>; Sat, 10 Feb 2018 10:26:18 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id w10so6307861wrg.2
        for <linux-mm@kvack.org>; Sat, 10 Feb 2018 07:26:18 -0800 (PST)
Received: from smtp-out6.electric.net (smtp-out6.electric.net. [192.162.217.194])
        by mx.google.com with ESMTPS id t4si1555110edd.20.2018.02.10.07.26.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Feb 2018 07:26:16 -0800 (PST)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 09/31] x86/entry/32: Leave the kernel via trampoline stack
Date: Sat, 10 Feb 2018 15:26:51 +0000
Message-ID: <50431bff2cda445490f5242c1189c8cd@AcuMS.aculab.com>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <1518168340-9392-10-git-send-email-joro@8bytes.org>
 <CA+55aFzB9H=RT6YB3onZCephZMs9ccz4aJ_jcPcfEkKJD_YDCQ@mail.gmail.com>
 <aa52108c-4874-9810-8ff5-e6415189cd73@redhat.com>
In-Reply-To: <aa52108c-4874-9810-8ff5-e6415189cd73@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Denys Vlasenko' <dvlasenk@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H .
 Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, Eduardo
 Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will
 Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, Joerg Roedel <jroedel@suse.de>

RnJvbTogRGVueXMgVmxhc2Vua28NCj4gU2VudDogMDkgRmVicnVhcnkgMjAxOCAxNzoxNw0KPiBP
biAwMi8wOS8yMDE4IDA2OjA1IFBNLCBMaW51cyBUb3J2YWxkcyB3cm90ZToNCj4gPiBPbiBGcmks
IEZlYiA5LCAyMDE4IGF0IDE6MjUgQU0sIEpvZXJnIFJvZWRlbCA8am9yb0A4Ynl0ZXMub3JnPiB3
cm90ZToNCj4gPj4gKw0KPiA+PiArICAgICAgIC8qIENvcHkgb3ZlciB0aGUgc3RhY2stZnJhbWUg
Ki8NCj4gPj4gKyAgICAgICBjbGQNCj4gPj4gKyAgICAgICByZXAgbW92c2INCj4gPg0KPiA+IFVn
aC4gVGhpcyBpcyBnb2luZyB0byBiZSBob3JyZW5kb3VzLiBNYXliZSBub3Qgbm90aWNlYWJsZSBv
biBtb2Rlcm4NCj4gPiBDUFUncywgYnV0IHRoZSB3aG9sZSAzMi1iaXQgY29kZSBpcyBraW5kIG9m
IHBvaW50bGVzcyBvbiBhIG1vZGVybiBDUFUuDQo+ID4NCj4gPiBBdCBsZWFzdCB1c2UgInJlcCBt
b3ZzbCIuIElmIHRoZSBrZXJuZWwgc3RhY2sgaXNuJ3QgNC1ieXRlIGFsaWduZWQsDQo+ID4geW91
IGhhdmUgaXNzdWVzLg0KDQpUaGUgYWxpZ25tZW50IGRvZXNuJ3QgbWF0dGVyLCAncmVwIG1vdnNs
JyB3aWxsIHN0aWxsIHdvcmsuDQoNCj4gSW5kZWVkLCAicmVwIG1vdnMiIGhhcyBzb21lIHNldHVw
IG92ZXJoZWFkIHRoYXQgbWFrZXMgaXQgdW5kZXNpcmFibGUNCj4gZm9yIHNtYWxsIHNpemVzLiBJ
biBteSB0ZXN0aW5nLCBtb3ZpbmcgbGVzcyB0aGFuIDEyOCBieXRlcyB3aXRoICJyZXAgbW92cyIN
Cj4gaXMgYSBsb3NzLg0KDQpJdCB2ZXJ5IG11Y2ggZGVwZW5kcyBvbiB0aGUgY3B1Lg0KDQpSZWNl
bnQgKEhhc3dlbGw/KSBJbnRlbCBjcHVzIGhhdmUgaGFyZHdhcmUgc3VwcG9ydCBmb3Igb3B0aW1p
c2luZyAncmVwIG1vdnNiJw0KZm9yIGNhY2hlZCBtZW1vcnkgbG9jYXRpb25zIHNvIHRoYXQgaXQg
aXMgZmFzdCByZWdhcmRsZXNzIG9mIHRoZSBhbGlnbm1lbnRzLg0KVGhlIHNldHVwIGNvc3QgaXMg
ZmFpcmx5IHNtYWxsLg0KDQpUaGUgcHJldmlvdXMgZ2VuZXJhdGlvbiBoYWQgYW4gb3B0aW1pc2F0
aW9uIGZvciAncmVwIG1vdnNiJyBmb3IgbGVzcyB0aGFuDQo3IGJ5dGVzLCBidXQgZm9yIGxhcmdl
ciB2YWx1ZXMgdGhlIHNldHVwIGNvc3Qgd2FzIHNpZ25pZmljYW50bHkgaGlnaGVyLg0KT24gdGhl
c2UgY3B1IHlvdSBuZWVkZWQgdG8gdXNlICdyZXAgbW92c2QnICg2NCBiaXRzIGlzIGJlc3QpIGZv
ciB0aGUgYnVsaw0Kb2YgYSBjb3B5Lg0KDQpBY3R1YWxseSwgaW5zdGVhZCBvZiB1c2luZyAncmVw
IG1vdnNiJyB0byBjb3B5IHRoZSBvZGQgZmV3IGJ5dGVzLCBmb3INCm1lbWNweSgpIHlvdSBjYW4g
Y29weSB0aGUgbGFzdCAobWlzYWxpZ25lZCkgOCBieXRlcyBmaXJzdCB0aGVuIHVzZQ0KJ3JlcCBt
b3ZzZCcgZm9yIHRoZSBidWxrIG9mIHRoZSBjb3B5Lg0KDQpPbiBOZXRidXJzdCBQNCB0aGUgc2V0
dXAgY29zdCBmb3IgYW55ICdyZXAgbW92cycgd2FzIHNvbWV0aGluZyBsaWtlIDQ1IGNsb2Nrcy4N
CllvdSByZWFsbHkgZGlkbid0IHdhbnQgdG8gdXNlIHRoZW0gZm9yIHNob3J0IGNvcGllcy4NCihB
IEMgY29tcGlsZXIgZnJvbSBhIHdlbGwga25vd24gT1Mgc3VwcGxpZXIgd2lsbCAnb3B0aW1pc2Un
IGFueSBjb3B5IGxvb3ANCmludG8gJ3JlcCBtb3ZzYicgLSBub3QgZW50aXJlbHkgdGhlIGJlc3Qg
b2Ygb3B0aW1pc2F0aW9ucyEpDQoNCkkgYWxzbyBtYW5hZ2VkIHRvIG1hdGNoIHRoZSBwZXItY3lj
bGUgY29zdCBvZiAncmVwIG1vdnNsJyB3aXRoIGEgY29weQ0KbG9vcCBvbiBteSBBdGhsb24tNzAw
IChidXQgbm90IHRoZSBzZXR1cCBjb3N0LCBvbiBhIFA0IEkgbWlnaHQgaGF2ZQ0KYmVhdGVuIHRo
ZSBzZXR1cCBjb3N0IGFzIHdlbGwpLg0KDQoJRGF2aWQNCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
