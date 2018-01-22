Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id DBD40800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 04:54:54 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c142so4916409wmh.4
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 01:54:54 -0800 (PST)
Received: from smtp-out4.electric.net (smtp-out4.electric.net. [192.162.216.185])
        by mx.google.com with ESMTPS id h89si268936edd.471.2018.01.22.01.54.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jan 2018 01:54:53 -0800 (PST)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH 00/16] PTI support for x86-32
Date: Mon, 22 Jan 2018 09:55:31 +0000
Message-ID: <7f37ff1c10b04b2386c2044cdc8e38be@AcuMS.aculab.com>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <5D89F55C-902A-4464-A64E-7157FF55FAD0@gmail.com>
 <886C924D-668F-4007-98CA-555DB6279E4F@gmail.com>
 <9CF1DD34-7C66-4F11-856D-B5E896988E16@gmail.com>
In-Reply-To: <9CF1DD34-7C66-4F11-856D-B5E896988E16@gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Nadav Amit' <nadav.amit@gmail.com>, Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H .
 Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy
 Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh
 Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter
 Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "aliguori@amazon.com" <aliguori@amazon.com>, "daniel.gruss@iaik.tugraz.at" <daniel.gruss@iaik.tugraz.at>, "hughd@google.com" <hughd@google.com>, "keescook@google.com" <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, "jroedel@suse.de" <jroedel@suse.de>

RnJvbTogTmFkYXYgQW1pdA0KPiBTZW50OiAyMSBKYW51YXJ5IDIwMTggMjM6NDYNCj4gDQo+IEkg
d2FudGVkIHRvIHNlZSB3aGV0aGVyIHNlZ21lbnRzIHByb3RlY3Rpb24gY2FuIGJlIGEgcmVwbGFj
ZW1lbnQgZm9yIFBUSQ0KPiAoeWVzLCBleGNsdWRpbmcgU01FUCBlbXVsYXRpb24pLCBvciB3aGV0
aGVyIHNwZWN1bGF0aXZlIGV4ZWN1dGlvbiDigJxpZ25vcmVz4oCdDQo+IGxpbWl0IGNoZWNrcywg
c2ltaWxhcmx5IHRvIHRoZSB3YXkgcGFnaW5nIHByb3RlY3Rpb24gaXMgc2tpcHBlZC4NCg0KVGhh
dCdzIG1hZGUgbWUgcmVtZW1iZXIgc29tZXRoaW5nIGFib3V0IHNlZ21lbnQgbGltaXRzIGFwcGx5
aW5nIGluIDY0Yml0IG1vZGUuDQpJIHJlYWxseSBjYW4ndCByZW1lbWJlciB0aGUgZGV0YWlscyBh
dCBhbGwuDQpJJ20gc3VyZSBpdCBoYWQgc29tZXRoaW5nIHRvIGRvIHdpdGggb25lIG9mIHRoZSBW
TSBpbXBsZW1lbnRhdGlvbnMgcmVzdHJpY3RpbmcNCm1lbW9yeSBhY2Nlc3Nlcy4NCg0KCURhdmlk
DQoNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
