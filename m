Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 1B7136B0078
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 01:55:02 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p595V3l3024398
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 01:31:03 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p595t0Fv103992
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 01:55:00 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p595swPc000993
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 01:55:00 -0400
Date: Thu, 9 Jun 2011 11:17:54 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 13/22] 13: uprobes: Handing int3 and
 singlestep exception.
Message-ID: <20110609054754.GD6123@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
 <20110607130051.28590.68088.sendpatchset@localhost6.localdomain6>
 <20110608221141.GB9965@wicker.gateway.2wire.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110608221141.GB9965@wicker.gateway.2wire.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Wilson <wilsons@start.ca>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

> > + */
> > +int uprobe_post_notifier(struct pt_regs *regs)
> > +{
> > +	struct uprobe *uprobe;
> > +	struct uprobe_task *utask;
> > +
> > +	if (!current->mm || !current->utask || !current->utask->active_uprobe)
> > +		/* task is currently not uprobed */
> > +		return 0;
> > +
> > +	utask = current->utask;
> > +	uprobe = utask->active_uprobe;
> > +	if (!uprobe)
> > +		return 0;
> > +
> > +	set_thread_flag(TIF_UPROBE);
> > +	return 1;
> > +}
> 
> Looks like this can be simplified.  If current->utask->active_uprobe is
> non-null then surely the assignment to uprobe will be too?
> 

Yes, the two lines where we check for !uprobe and return are redundant
and can be removed. Will be corrected in the next patchset.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
