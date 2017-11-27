Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id EACC16B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 07:50:08 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id x63so35029729ioe.18
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 04:50:08 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id t6si16383001ioa.218.2017.11.27.04.50.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 04:50:07 -0800 (PST)
Date: Mon, 27 Nov 2017 13:49:52 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [patch V2 5/5] x86/kaiser: Add boottime disable switch
Message-ID: <20171127124952.m6rw72kkufzyneco@hirez.programming.kicks-ass.net>
References: <20171126231403.657575796@linutronix.de>
 <20171126232414.645128754@linutronix.de>
 <20171127094846.gl6zo3rftiyucvny@hirez.programming.kicks-ass.net>
 <20171127102241.oj225ycxkc7rfvft@hirez.programming.kicks-ass.net>
 <alpine.DEB.2.20.1711271250001.1799@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1711271250001.1799@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Mon, Nov 27, 2017 at 12:50:45PM +0100, Thomas Gleixner wrote:
> On Mon, 27 Nov 2017, Peter Zijlstra wrote:
> > On Mon, Nov 27, 2017 at 10:48:46AM +0100, Peter Zijlstra wrote:

> > > So in patch 15 Andy notes that we should probably also disable the
> > > SYSCALL trampoline when we disable KAISER.
> > > 
> > >   https://lkml.kernel.org/r/20171124172411.19476-16-mingo@kernel.org
> > 
> > Could be a simple as this.. but I've not tested.
> 
> That's only one part of it. I think we need to fiddle with the exit side as
> well.

So I assumed that the patches were bisectable. From that I figured the
exit path (patch 14 in that set) would work either way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
