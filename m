Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 67C7B6B004D
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 00:54:16 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 1 Dec 2011 00:54:14 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pB15sCOF3485696
	for <linux-mm@kvack.org>; Thu, 1 Dec 2011 00:54:12 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pB15sAtf013151
	for <linux-mm@kvack.org>; Thu, 1 Dec 2011 00:54:11 -0500
Date: Thu, 1 Dec 2011 11:22:11 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 3.2-rc2 8/30] x86: analyze instruction and determine
 fixups.
Message-ID: <20111201055211.GD18380@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
 <20111118110808.10512.72719.sendpatchset@srdronam.in.ibm.com>
 <20111130185751.GA8160@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20111130185751.GA8160@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

* Oleg Nesterov <oleg@redhat.com> [2011-11-30 19:57:51]:

> On 11/18, Srikar Dronamraju wrote:
> >
> > +static void handle_riprel_insn(struct mm_struct *mm, struct uprobe *uprobe,
> > +							struct insn *insn)
> > +{
> > [...snip...]
> > +	if (insn->immediate.nbytes) {
> > +		cursor++;
> > +		memmove(cursor, cursor + insn->displacement.nbytes,
> > +						insn->immediate.nbytes);
> > +	}
> > +	return;
> > +}
> 
> Of course I don not understand this code. But it seems that it can
> rewrite uprobe->insn ?
> 

Yes, we do rewrite the instruction for the RIP relative instructions. 
But the first byte is still intact.

> If yes, don't we need to save the original insn for unregister_uprobe?

When we unregister, we just put back the least opcode size which
happens to be the first byte for x86.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
