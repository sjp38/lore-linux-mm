Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 584316B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 17:53:18 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id p144so12747438itc.9
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 14:53:18 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id d93si22226631ioj.24.2017.11.27.14.53.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 14:53:17 -0800 (PST)
Date: Mon, 27 Nov 2017 23:53:06 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 4/5] x86/mm/kaiser: Remove superfluous SWITCH_TO_KERNEL
Message-ID: <20171127225306.6f7iueus7fq2hg7h@hirez.programming.kicks-ass.net>
References: <20171127223110.479550152@infradead.org>
 <20171127223405.329572992@infradead.org>
 <b96a07a3-9fd5-f4c1-a4d5-433c590d006e@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b96a07a3-9fd5-f4c1-a4d5-433c590d006e@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Mon, Nov 27, 2017 at 02:47:08PM -0800, Dave Hansen wrote:
> On 11/27/2017 02:31 PM, Peter Zijlstra wrote:
> > We never use this code-path with KAISER enabled.
> ...
> > @@ -201,14 +201,6 @@ ENTRY(entry_SYSCALL_64)
> >  
> >  	swapgs
> >  	movq	%rsp, PER_CPU_VAR(rsp_scratch)
> > -
> > -	/*
> > -	 * The kernel CR3 is needed to map the process stack, but we
> > -	 * need a scratch register to be able to load CR3.  %rsp is
> > -	 * clobberable right now, so use it as a scratch register.
> > -	 * %rsp will look crazy here for a couple instructions.
> > -	 */
> > -	SWITCH_TO_KERNEL_CR3 scratch_reg=%rsp
> >  	movq	PER_CPU_VAR(cpu_current_top_of_stack), %rsp
> 
> What's the mechanism that we use to switch between the two versions of
> the SYSCALL entry?  It wasn't obvious from some grepping.

the next patch, the code in tip will in fact never use this code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
