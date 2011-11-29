Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 331B86B0055
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 02:51:33 -0500 (EST)
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 29 Nov 2011 02:51:32 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAT7pUmo272696
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 02:51:30 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAT7pSfW007101
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 02:51:30 -0500
Date: Tue, 29 Nov 2011 13:19:48 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 3.2-rc2 9/30] uprobes: Background page replacement.
Message-ID: <20111129074948.GB13445@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
 <20111118110823.10512.74338.sendpatchset@srdronam.in.ibm.com>
 <1322489609.2921.132.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1322489609.2921.132.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

* Peter Zijlstra <peterz@infradead.org> [2011-11-28 15:13:29]:

> On Fri, 2011-11-18 at 16:38 +0530, Srikar Dronamraju wrote:
> > +/**
> > + * is_bkpt_insn - check if instruction is breakpoint instruction.
> > + * @insn: instruction to be checked.
> > + * Default implementation of is_bkpt_insn
> > + * Returns true if @insn is a breakpoint instruction.
> > + */
> > +bool __weak is_bkpt_insn(u8 *insn)
> > +{
> > +       return (insn[0] == UPROBES_BKPT_INSN);
> >  } 
> 
> This seems wrong, UPROBES_BKPT_INSN basically defined to be of
> uprobe_opcode_t type, not u8.
> 
> So:
> 
> bool __weak is_bkpt_insn(uprobe_opcode_t *insn)
> {
> 	return *insn == UPROBE_BKPT_INSN;
> }
> 
> seems like the right way to write this.
> 

Agree, will fix this. 
Thanks for bringing this up.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
