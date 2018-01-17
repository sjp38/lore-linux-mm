Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C20E3280281
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 02:59:47 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id q8so8036147pfh.12
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 23:59:47 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q4si3256359pgn.232.2018.01.16.23.59.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Jan 2018 23:59:46 -0800 (PST)
Date: Wed, 17 Jan 2018 08:59:24 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 06/16] x86/mm/ldt: Reserve high address-space range for
 the LDT
Message-ID: <20180117075924.GI2228@hirez.programming.kicks-ass.net>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-7-git-send-email-joro@8bytes.org>
 <20180116165213.GF2228@hirez.programming.kicks-ass.net>
 <CALCETrUgZondzbUTYF2U2YtxOiHExd2H4xD1Mjz-G=VJKzNfVw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUgZondzbUTYF2U2YtxOiHExd2H4xD1Mjz-G=VJKzNfVw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On Tue, Jan 16, 2018 at 02:51:45PM -0800, Andy Lutomirski wrote:
> On Tue, Jan 16, 2018 at 8:52 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> > On Tue, Jan 16, 2018 at 05:36:49PM +0100, Joerg Roedel wrote:
> >> From: Joerg Roedel <jroedel@suse.de>
> >>
> >> Reserve 2MB/4MB of address space for mapping the LDT to
> >> user-space.
> >
> > LDT is 64k, we need 2 per CPU, and NR_CPUS <= 64 on 32bit, that gives
> > 64K*2*64=8M > 2M.
> 
> If this works like it does on 64-bit, it only needs 128k regardless of
> the number of CPUs.  The LDT mapping is specific to the mm.

Ah, then I got my LDT things confused again... which is certainly
possible, we had a few too many variants back then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
