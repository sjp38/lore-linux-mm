Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2DB726B002D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 03:10:04 -0500 (EST)
Received: from /spool/local
	by e6.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 15 Nov 2011 03:10:00 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAF89ncH281396
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 03:09:49 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAF89lZ5019357
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 03:09:49 -0500
Date: Tue, 15 Nov 2011 13:14:06 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 3.2-rc1 28/28]   uprobes: introduce
 UTASK_SSTEP_TRAPPED logic
Message-ID: <20111115074406.GE4243@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20111110183725.11361.57827.sendpatchset@srdronam.in.ibm.com>
 <20111110184307.11361.8163.sendpatchset@srdronam.in.ibm.com>
 <20111114163953.GA29399@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20111114163953.GA29399@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

> >
> > +void __weak abort_xol(struct pt_regs *regs, struct uprobe_task *utask)
> > +{
> > +	set_instruction_pointer(regs, utask->vaddr);
> > +}
> 
> OK, this is fine on 32bit. But X86_64 should also handle
> UPROBES_FIX_RIP_AX/CX?
> 
> IOW, shouldn't we also do
> 
> 	if (uprobe->fixups & UPROBES_FIX_RIP_AX)
> 		regs->ax = tskinfo->saved_scratch_register;
> 	else if (uprobe->fixups & UPROBES_FIX_RIP_CX)
> 		regs->cx = tskinfo->saved_scratch_register;
> 
> on 64bit?

Yes, we should be doing this on x86_64. Since abort_xol is a weak
function, I will have x86_64 specific abort_xol.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
