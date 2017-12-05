Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1C6106B026F
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 04:34:56 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 11so11642108wrb.18
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 01:34:56 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id d82si6384041wmd.237.2017.12.05.01.34.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 05 Dec 2017 01:34:54 -0800 (PST)
Date: Tue, 5 Dec 2017 10:34:08 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [patch 57/60] x86/mm/kpti: Add Kconfig
In-Reply-To: <alpine.DEB.2.20.1712041757110.1788@nanos>
Message-ID: <alpine.DEB.2.20.1712051033010.1676@nanos>
References: <20171204140706.296109558@linutronix.de> <20171204150609.511885345@linutronix.de> <CALCETrVfasJMa_++EB-bFm_MzHAzKqvjRPsaBo2m8YTzRomkxg@mail.gmail.com> <alpine.DEB.2.20.1712041757110.1788@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, moritz.lipp@iaik.tugraz.at, "linux-mm@kvack.org" <linux-mm@kvack.org>, Borislav Petkov <bp@alien8.de>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Mon, 4 Dec 2017, Thomas Gleixner wrote:
> On Mon, 4 Dec 2017, Andy Lutomirski wrote:
> > On Mon, Dec 4, 2017 at 6:08 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > > --- a/security/Kconfig
> > > +++ b/security/Kconfig
> > > @@ -54,6 +54,16 @@ config SECURITY_NETWORK
> > >           implement socket and networking access controls.
> > >           If you are unsure how to answer this question, answer N.
> > >
> > > +config KERNEL_PAGE_TABLE_ISOLATION
> > > +       bool "Remove the kernel mapping in user mode"
> > > +       depends on X86_64 && JUMP_LABEL
> > 
> > select JUMP_LABEL perhaps?
> 
> Silly me. Yes.

Peter just pointed out that we switched everything to cpu_has() which is
using alternatives so jump label is not longer required at all.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
