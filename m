Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EAF816B0033
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 15:54:17 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id m78so7049905wma.3
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 12:54:17 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id r2si8803785wrc.356.2017.11.20.12.54.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 20 Nov 2017 12:54:16 -0800 (PST)
Date: Mon, 20 Nov 2017 21:54:13 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 17/30] x86, kaiser: map debug IDT tables
In-Reply-To: <CALCETrUgi-q1S82Btjjhk7tpPim+M1QzicGu7a6hAva-tbBVzQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1711202152350.2348@nanos>
References: <20171110193058.BECA7D88@viggo.jf.intel.com> <20171110193138.1185728D@viggo.jf.intel.com> <CALCETrUgi-q1S82Btjjhk7tpPim+M1QzicGu7a6hAva-tbBVzQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Mon, 20 Nov 2017, Andy Lutomirski wrote:

> On Fri, Nov 10, 2017 at 11:31 AM, Dave Hansen
> <dave.hansen@linux.intel.com> wrote:
> >
> > From: Dave Hansen <dave.hansen@linux.intel.com>
> >
> > The IDT is another structure which the CPU references via a
> > virtual address.  It also obviously needs these to handle an
> > interrupt in userspace, so these need to be mapped into the user
> > copy of the page tables.
> 
> Why would the debug IDT ever be used in user mode?  IIRC it's a total
> turd related to avoiding crap nesting inside NMI.  Or am I wrong?

No. It's called from the TRACE_IRQS macros in the ASM entry code and from
do_nmi().

> If it *is* used in user mode, then we have a bug and it should be in
> the IDT to avoid address leaks just like the normal IDT.

It's not so this can go away. Good catch.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
