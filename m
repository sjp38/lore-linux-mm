Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 08A1F6B0092
	for <linux-mm@kvack.org>; Wed, 23 May 2012 05:38:32 -0400 (EDT)
Message-ID: <1337765911.13348.145.camel@gandalf.stny.rr.com>
Subject: Re: [PATCH 2/3] tracing: Extract out common code for
 kprobes/uprobes traceevents
From: Steven Rostedt <rostedt@goodmis.org>
Date: Wed, 23 May 2012 05:38:31 -0400
In-Reply-To: <1337764739.13348.141.camel@gandalf.stny.rr.com>
References: <20120403010442.17852.9888.sendpatchset@srdronam.in.ibm.com>
	 <20120403010452.17852.14232.sendpatchset@srdronam.in.ibm.com>
	 <1337764739.13348.141.camel@gandalf.stny.rr.com>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

On Wed, 2012-05-23 at 05:18 -0400, Steven Rostedt wrote:
> On Tue, 2012-04-03 at 06:34 +0530, Srikar Dronamraju wrote:
> > From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> > 
> > Move parts of trace_kprobe.c that can be shared with upcoming
> > trace_uprobe.c. Common code to kernel/trace/trace_probe.h and
> > kernel/trace/trace_probe.c. There are no functional changes.
> > 
> > Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> 
> Masami,
> 
> Can you ack this patch if you agree with it.

Nevermind, it's already applied. I was looking at the wrong branch :-(

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
