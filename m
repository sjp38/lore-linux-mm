Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 14F4A6B004D
	for <linux-mm@kvack.org>; Fri,  6 Jan 2012 06:16:41 -0500 (EST)
Received: from /spool/local
	by e5.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 6 Jan 2012 06:16:38 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q06BFfgw409118
	for <linux-mm@kvack.org>; Fri, 6 Jan 2012 06:15:41 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q06BFdUJ009957
	for <linux-mm@kvack.org>; Fri, 6 Jan 2012 09:15:41 -0200
Date: Fri, 6 Jan 2012 16:38:24 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v8 3.2.0-rc5 1/9] uprobes: Install and remove
 breakpoints.
Message-ID: <20120106110824.GD14946@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20111216122756.2085.95791.sendpatchset@srdronam.in.ibm.com>
 <20111216122808.2085.76986.sendpatchset@srdronam.in.ibm.com>
 <1325695788.2697.3.camel@twins>
 <20120106061407.GC14946@linux.vnet.ibm.com>
 <1325847461.2442.4.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1325847461.2442.4.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>

* Peter Zijlstra <peterz@infradead.org> [2012-01-06 11:57:41]:

> On Fri, 2012-01-06 at 11:44 +0530, Srikar Dronamraju wrote:
> >         - consumers for the uprobe is NULL, so mmap_uprobe will not
> >           insert new breakpoints which correspond to this uprobe until
> >           or unless another consumer gets added for the same probe.
> > 
> >         - If a new consumer gets added for this probe, we reuse the
> >           uprobe struct.
> 
> Ok, and when we install a new 'first' consumer we'll again try and
> install all breakpoints ignoring those that were already there?
> 

Yes, We install breakpoints as if its the first time a probe has been
requested to be installed, including setting the UPROBES_RUN_HANDLER
flag.

We do check if existing breakpoints are around during the actual
insertion, in which case install_breakpoint() will return -EEXIST.
However register assumes EEXIST to be non-fatal, and continues as if its
successful.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
