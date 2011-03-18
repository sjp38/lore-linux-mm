Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7B6008D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 14:31:55 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2IIT2OY016675
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 12:29:02 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2IIVevb083066
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 12:31:40 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2IIVcx6031440
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 12:31:39 -0600
Date: Fri, 18 Mar 2011 23:54:57 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 6/20] 6: x86: analyze instruction and
 determine fixups.
Message-ID: <20110318182457.GA24048@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
 <20110314133507.27435.71382.sendpatchset@localhost6.localdomain6>
 <alpine.LFD.2.00.1103151529130.2787@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1103151529130.2787@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

> 
> > +	ret = handle_riprel_insn(uprobe, &insn);
> > +	if (ret == -1)
> > +		/* rip-relative; can't XOL */
> > +		return 0;
> 
> So we return -1 from handle_riprel_insn() and return success?


handle_riprel_insn() returns 0 if the instruction is not rip-relative
returns 1 if its rip-relative but can use XOL slots.
returns -1 if its rip-relative but cannot use XOL.

We dont see any instructions that are rip-relative and cannot use XOL.
so the check and return are redundant and I will remove that in the next
patch.


Btw how
> deals handle_riprel_insn() with 32bit user space ?
> 

handle_riprel_insn() calls insn_rip_relative() which fails if
instruction isnot rip-relative and handle_riprel_insn returns
immediately.

The rest of your suggestions for this patch are taken.

> > +#endif
> > +	prepare_fixups(uprobe, &insn);
> > +	return 0;
> 

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
