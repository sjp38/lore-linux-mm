Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 375E528024A
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 17:52:08 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id q1so6936247plr.15
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:52:08 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y12si2768612pff.4.2018.01.16.14.52.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 14:52:07 -0800 (PST)
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id DF7F821781
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 22:52:06 +0000 (UTC)
Received: by mail-io0-f169.google.com with SMTP id w188so18619307iod.10
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:52:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180116165213.GF2228@hirez.programming.kicks-ass.net>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-7-git-send-email-joro@8bytes.org> <20180116165213.GF2228@hirez.programming.kicks-ass.net>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 16 Jan 2018 14:51:45 -0800
Message-ID: <CALCETrUgZondzbUTYF2U2YtxOiHExd2H4xD1Mjz-G=VJKzNfVw@mail.gmail.com>
Subject: Re: [PATCH 06/16] x86/mm/ldt: Reserve high address-space range for
 the LDT
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On Tue, Jan 16, 2018 at 8:52 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Tue, Jan 16, 2018 at 05:36:49PM +0100, Joerg Roedel wrote:
>> From: Joerg Roedel <jroedel@suse.de>
>>
>> Reserve 2MB/4MB of address space for mapping the LDT to
>> user-space.
>
> LDT is 64k, we need 2 per CPU, and NR_CPUS <= 64 on 32bit, that gives
> 64K*2*64=8M > 2M.

If this works like it does on 64-bit, it only needs 128k regardless of
the number of CPUs.  The LDT mapping is specific to the mm.

How are you dealing with PAE here?  That is, what's your pagetable
layout?  What parts of the address space are owned by what code?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
