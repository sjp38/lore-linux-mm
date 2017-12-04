Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 570AB6B0282
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 11:58:01 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id o16so4541107wmf.4
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 08:58:01 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 61si6840610wrj.503.2017.12.04.08.58.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 04 Dec 2017 08:58:00 -0800 (PST)
Date: Mon, 4 Dec 2017 17:57:32 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [patch 57/60] x86/mm/kpti: Add Kconfig
In-Reply-To: <CALCETrVfasJMa_++EB-bFm_MzHAzKqvjRPsaBo2m8YTzRomkxg@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1712041757110.1788@nanos>
References: <20171204140706.296109558@linutronix.de> <20171204150609.511885345@linutronix.de> <CALCETrVfasJMa_++EB-bFm_MzHAzKqvjRPsaBo2m8YTzRomkxg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, moritz.lipp@iaik.tugraz.at, "linux-mm@kvack.org" <linux-mm@kvack.org>, Borislav Petkov <bp@alien8.de>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Mon, 4 Dec 2017, Andy Lutomirski wrote:
> On Mon, Dec 4, 2017 at 6:08 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > --- a/security/Kconfig
> > +++ b/security/Kconfig
> > @@ -54,6 +54,16 @@ config SECURITY_NETWORK
> >           implement socket and networking access controls.
> >           If you are unsure how to answer this question, answer N.
> >
> > +config KERNEL_PAGE_TABLE_ISOLATION
> > +       bool "Remove the kernel mapping in user mode"
> > +       depends on X86_64 && JUMP_LABEL
> 
> select JUMP_LABEL perhaps?

Silly me. Yes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
