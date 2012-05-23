Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id B44186B0092
	for <linux-mm@kvack.org>; Wed, 23 May 2012 05:41:31 -0400 (EDT)
Message-ID: <1337766088.13348.146.camel@gandalf.stny.rr.com>
Subject: Re: [PATCH 3/3] tracing: Provide traceevents interface for uprobes
From: Steven Rostedt <rostedt@goodmis.org>
Date: Wed, 23 May 2012 05:41:28 -0400
In-Reply-To: <1337764783.13348.142.camel@gandalf.stny.rr.com>
References: <20120403010442.17852.9888.sendpatchset@srdronam.in.ibm.com>
	 <20120403010502.17852.58528.sendpatchset@srdronam.in.ibm.com>
	 <1337764783.13348.142.camel@gandalf.stny.rr.com>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

On Wed, 2012-05-23 at 05:19 -0400, Steven Rostedt wrote:
> On Tue, 2012-04-03 at 06:35 +0530, Srikar Dronamraju wrote:
> > From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
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

Ignore this too, sorry for the noise. This is what I get for trying to
do work while struggling with insomnia :-p

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
