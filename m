Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7A26B0033
	for <linux-mm@kvack.org>; Sat, 22 Oct 2011 03:20:48 -0400 (EDT)
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ananth@in.ibm.com>;
	Sat, 22 Oct 2011 03:20:45 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9M7KNS1221034
	for <linux-mm@kvack.org>; Sat, 22 Oct 2011 03:20:23 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9M7KKhh031408
	for <linux-mm@kvack.org>; Sat, 22 Oct 2011 03:20:22 -0400
Date: Sat, 22 Oct 2011 12:50:30 +0530
From: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Subject: Re: [PATCH 13/X] uprobes: introduce UTASK_SSTEP_TRAPPED logic
Message-ID: <20111022072030.GB24475@in.ibm.com>
Reply-To: ananth@in.ibm.com
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20111015190007.GA30243@redhat.com> <20111019215139.GA16395@redhat.com> <20111019215344.GG16395@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111019215344.GG16395@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 19, 2011 at 11:53:44PM +0200, Oleg Nesterov wrote:
> Finally, add UTASK_SSTEP_TRAPPED state/code to handle the case when
> xol insn itself triggers the signal.
> 
> In this case we should restart the original insn even if the task is
> already SIGKILL'ed (say, the coredump should report the correct ip).
> This is even more important if the task has a handler for SIGSEGV/etc,
> The _same_ instruction should be repeated again after return from the
> signal handler, and SSTEP can never finish in this case.

Oleg,

Not sure I understand this completely...

When you say 'correct ip' you mean the original vaddr where we now have
a uprobe breakpoint and not the xol copy, right?

Coredump needs to report the correct ip, but should it also not report
correctly the instruction that caused the signal? Ergo, shouldn't we
put the original instruction back at the uprobed vaddr?

Ananth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
