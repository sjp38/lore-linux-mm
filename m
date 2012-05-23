Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 34C4B6B0092
	for <linux-mm@kvack.org>; Wed, 23 May 2012 05:59:15 -0400 (EDT)
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 23 May 2012 05:59:13 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 434776E804C
	for <linux-mm@kvack.org>; Wed, 23 May 2012 05:58:50 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4N9woQp134912
	for <linux-mm@kvack.org>; Wed, 23 May 2012 05:58:50 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4N9wm7l010950
	for <linux-mm@kvack.org>; Wed, 23 May 2012 06:58:50 -0300
Date: Wed, 23 May 2012 15:27:38 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] tracing: Provide traceevents interface for uprobes
Message-ID: <20120523095738.GA15587@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20120403010442.17852.9888.sendpatchset@srdronam.in.ibm.com>
 <20120403010502.17852.58528.sendpatchset@srdronam.in.ibm.com>
 <1337764783.13348.142.camel@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1337764783.13348.142.camel@gandalf.stny.rr.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

> > 
> > Implements trace_event support for uprobes. In its current form it can
> > be used to put probes at a specified offset in a file and dump the
> > required registers when the code flow reaches the probed address.
> > 
> > The following example shows how to dump the instruction pointer and %ax
> > a register at the probed text address.  Here we are trying to probe
> > zfree in /bin/zsh
> > 
> 
> Masami,
> 
> Can you ack this patch as well (only if you agree)
> 

Masami already acked the patches and its now part of the -tip tree.

https://lkml.org/lkml/2012/4/12/163
and 

http://lkml.org/lkml/2012/4/12/164

and 

https://lkml.org/lkml/2012/4/16/115


and these patches got picked into -tip  on May 7 

f3f096c tracing: Provide trace events interface for uprobes
8ab83f5 tracing: Extract out common code for kprobes/uprobes trace events
3a6b766 tracing: Modify is_delete, is_return from int to bool

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
