Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3F86F280247
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 15:14:06 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id q18so7544866ioh.4
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 12:14:06 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n25sor9047939iob.176.2018.01.22.12.14.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jan 2018 12:14:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <143DE376-A8A4-4A91-B4FF-E258D578242D@zytor.com>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <5D89F55C-902A-4464-A64E-7157FF55FAD0@gmail.com> <886C924D-668F-4007-98CA-555DB6279E4F@gmail.com>
 <9CF1DD34-7C66-4F11-856D-B5E896988E16@gmail.com> <CA+55aFz4cUhqhmWg-F8NXGjowVGXkMA126H-mQ4n1A0ywtQ_tg@mail.gmail.com>
 <143DE376-A8A4-4A91-B4FF-E258D578242D@zytor.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 22 Jan 2018 12:14:03 -0800
Message-ID: <CA+55aFxg5H38Ef4DUgMQ7KrsUtWdaKYKCRFZ8rangUrZ=OgCEw@mail.gmail.com>
Subject: Re: [RFC PATCH 00/16] PTI support for x86-32
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Anvin <hpa@zytor.com>
Cc: Nadav Amit <nadav.amit@gmail.com>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On Sun, Jan 21, 2018 at 6:20 PM,  <hpa@zytor.com> wrote:
>
> No idea about Intel, but at least on Transmeta CPUs the limit check was asynchronous with the access.

Yes, but TMTA had a really odd uarch and didn't check segment limits natively.

When you do it in hardware. the limit check is actually fairly natural
to do early rather than late (since it acts on the linear address
_before_ base add and TLB lookup).

So it's not like it can't be done late, but there are reasons why a
traditional microarchitecture might always end up doing the limit
check early and so segmentation might be a good defense against
meltdown on 32-bit Intel.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
