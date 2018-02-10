Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 86A396B0005
	for <linux-mm@kvack.org>; Sat, 10 Feb 2018 10:40:47 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id k14so6317557wrc.14
        for <linux-mm@kvack.org>; Sat, 10 Feb 2018 07:40:47 -0800 (PST)
Received: from smtp-out4.electric.net (smtp-out4.electric.net. [192.162.216.184])
        by mx.google.com with ESMTPS id 7si2331167eds.62.2018.02.10.07.40.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Feb 2018 07:40:46 -0800 (PST)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 09/31] x86/entry/32: Leave the kernel via trampoline stack
Date: Sat, 10 Feb 2018 15:41:06 +0000
Message-ID: <aca58942b1424f83a0673318dc42c1f8@AcuMS.aculab.com>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <1518168340-9392-10-git-send-email-joro@8bytes.org>
 <CA+55aFzB9H=RT6YB3onZCephZMs9ccz4aJ_jcPcfEkKJD_YDCQ@mail.gmail.com>
 <20180209190226.lqh6twf7thfg52cq@suse.de>
 <CA+55aFzy6ZJDUpgHY0J2_z4kODaiYPgyHuOsMGiXmrhgR3kyPQ@mail.gmail.com>
 <20180209192515.qvvixkn5rz77oz6l@suse.de>
 <CA+55aFw643jQxVDrm05ZJ6YkVdqBBJ8WH-+=QCx3SDXrVN-TxA@mail.gmail.com>
In-Reply-To: <CA+55aFw643jQxVDrm05ZJ6YkVdqBBJ8WH-+=QCx3SDXrVN-TxA@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Linus Torvalds' <torvalds@linux-foundation.org>, Joerg Roedel <jroedel@suse.de>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the
 arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy
 Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh
 Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter
 Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>

RnJvbTogTGludXMgVG9ydmFsZHMNCj4gU2VudDogMDkgRmVicnVhcnkgMjAxOCAxOTo0OQ0KLi4u
DQo+IEkgdGhpbmsgdGhlIGluc3RydWN0aW9uIHNjaGVkdWxpbmcgZW5kcyB1cCBiYXNpY2FsbHkg
YnJlYWtpbmcgYXJvdW5kDQo+IG1pY3JvY29kZWQgaW5zdHJ1Y3Rpb25zLCB3aGljaCBpcyB3aHkg
eW91J2xsIGdldCBzb21ldGhpbmcgbGlrZSAxMituDQo+IGN5Y2xlcyBmb3IgInJlcCBtb3ZzIiBv
biBzb21lIHVhcmNocywgYnV0IGF0IHRoYXQgcG9pbnQgaXQncyBwcm9iYWJseQ0KPiBtb3N0bHkg
aW4gdGhlIG5vaXNlIGNvbXBhcmVkIHRvIGFsbCB0aGUgb3RoZXIgbmFzdHkgUFRJIHRoaW5ncy4N
Cg0KT3IgNDgrbiBvbiBQNA0KDQo+IFlvdSB3b24ndCBzZWUgYW55IG9mIHRoZSBfcmVhbF8gYWR2
YW50YWdlcyAod2hpY2ggYXJlIGFib3V0IG1vdmluZw0KPiBjYWNoZWxpbmVzIGF0IGEgdGltZSks
IHNvIHdpdGggc21hbGxpc2ggY29waWVzIHlvdSByZWFsbHkgb25seSBzZWUgdGhlDQo+IGRvd25z
aWRlcyBvZiAicmVwIG1vdnMiLCB3aGljaCBpcyBtYWlubHkgdGhhdCBpbnN0cnVjdGlvbiBzY2hl
ZHVsaW5nDQo+IGhpY2t1cCB3aXRoIGFueSBtaW9jcm9jb2RlLg0KDQpJIHRob3VnaHQgdGhhdCB0
aGUgaGFyZHdhcmUgb3B0aW1pc2F0aW9uIGZvciAncmVwIG1vdnNiJyBvbiByZWNlbnQNCkludGVs
IGNwdXMgZ2VuZXJhdGVkIHdvcmQgc2l6ZWQgbWVtb3J5IGFjY2Vzc2VzIGV2ZW4gZm9yIG1pc2Fs
aWduZWQNCnNob3J0IHRyYW5zZmVycy4NCk15IHRob3VnaHRzIHdlcmUgdGhhdCB0aGV5J2QgaW1w
bGVtZW50ZWQgYSBjYWNoZSBsaW5lIHNpemVkIGJhcnJlbA0Kc2hpZnQgcmVnaXN0ZXIuDQpJZiB0
aGF0IGlzbid0IHRydWUgdGhlbiB1c2luZyBpdCBmb3IgYWxsIG1lbWNweSgpIGlzIHByb2JhYmx5
IHN0dXBpZA0KKGJ1dCBub3QgYXMgc3R1cGlkIGFzIGRvaW5nIGFsbCBtZW1jcHkgYmFja3dhcmRz
ISkNCg0KCURhdmlkDQoNCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
