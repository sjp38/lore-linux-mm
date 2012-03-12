Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 76AC56B0044
	for <linux-mm@kvack.org>; Mon, 12 Mar 2012 02:05:34 -0400 (EDT)
Date: Mon, 12 Mar 2012 07:05:03 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/7] uprobes/core: make macro names consistent.
Message-ID: <20120312060503.GA1479@elte.hu>
References: <20120310174501.19949.50137.sendpatchset@srdronam.in.ibm.com>
 <20120311140735.GA27053@elte.hu>
 <20120312055437.GH13284@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120312055437.GH13284@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>


* Srikar Dronamraju <srikar@linux.vnet.ibm.com> wrote:

> * Ingo Molnar <mingo@elte.hu> [2012-03-11 15:07:36]:
> 
> > 
> > Which tree are these patches against? They don't apply to 
> > tip:master cleanly.
> 
> To me it applied cleanly on top of 
> commit 90549600c550ab189c4611060603f7f15bda2b5e

It's a new commit:

 c94082656dac: x86: Use enum instead of literals for trap values

Interacting with this cleanup:

 x86/trivial: Rename trap_no to trap_nr in thread struct

Also, while touching the trap_nr sites please use X86_TRAP_PF 
instead of '14' and X86_TRAP_MF instead of '16', etc.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
