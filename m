Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E20886B0006
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 16:05:21 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id x2-v6so870340pgr.15
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 13:05:21 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q61-v6si1556183plb.93.2018.07.17.13.05.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 13:05:20 -0700 (PDT)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 323852084A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 20:05:20 +0000 (UTC)
Received: by mail-wm0-f54.google.com with SMTP id h20-v6so557830wmb.4
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 13:05:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180717070544.xok34ro76f7m32ha@suse.de>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
 <1531308586-29340-4-git-send-email-joro@8bytes.org> <823BAA9B-FACA-4E91-BE56-315FF569297C@amacapital.net>
 <20180713094849.5bsfpwhxzo5r5exk@8bytes.org> <CALCETrUP1QUKPLPJg6_L5=Mzmq33cSvq+NMaYW01wTCepdjCyg@mail.gmail.com>
 <CALCETrUBR-TGPY7wF4UwRb7jW39H+rJ4XFen35dgJRysk9sYTQ@mail.gmail.com> <20180717070544.xok34ro76f7m32ha@suse.de>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 17 Jul 2018 13:04:57 -0700
Message-ID: <CALCETrVza8cpwKPzH1hXUSuassq117MZN7pJaBD89CA=FvuTsw@mail.gmail.com>
Subject: Re: [PATCH 03/39] x86/entry/32: Load task stack from x86_tss.sp1 in
 SYSENTER handler
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <jroedel@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>

On Tue, Jul 17, 2018 at 12:05 AM, Joerg Roedel <jroedel@suse.de> wrote:
> On Fri, Jul 13, 2018 at 04:17:40PM -0700, Andy Lutomirski wrote:
>> I re-read it again.  How about keeping TSS_entry_stack but making it
>> be the offset from the TSS to the entry stack.  Then do the arithmetic
>> in asm.
>
> Hmm, I think its better to keep the arithmetic in the C file for better
> readability. How about renaming it to TSS_entry2task_stack?

That's okay with me.

>
>
> Regards,
>
>         Joerg
