Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CDBAC9400BF
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 13:57:58 -0400 (EDT)
Date: Wed, 5 Oct 2011 19:53:53 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 5/26]   Uprobes: copy of the original
	instruction.
Message-ID: <20111005175353.GA5475@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20110920120057.25326.63780.sendpatchset@srdronam.in.ibm.com> <20111003162905.GA3752@redhat.com> <20111005160934.GC806@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111005160934.GC806@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>

On 10/05, Srikar Dronamraju wrote:
>
> * Oleg Nesterov <oleg@redhat.com> [2011-10-03 18:29:05]:
>
> > But I am starting to think I simply do not understand this change.
> > To the point, I do not underestand why do we need copy_insn() at all.
> > We are going to replace this page, can't we save/analyze ->insn later
> > when we copy the content of the old page? Most probably I missed
> > something simple...
> >
>
> Copying the instruction at the time we replace the original instruction
> would have been ideal. However there are a few irritants to handle.
>
> ...
>    How do we distinguish if the
>    breakpoint instruction was around in the text or somebody inserted a
>    breakpoint in that address-space? Since we read from the page-cache,
>    we can easily resolve this.

Ah. I see.

> -  On archs like x86, with variable size instructions, the original
>    instruction can be across 2 pages.

Heh. Indeed ;)

Thanks Srikar.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
