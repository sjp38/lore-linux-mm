Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E476A8D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 16:44:20 -0400 (EDT)
Subject: Re: [PATCH v2 2.6.38-rc8-tip 0/20] 0: Inode based uprobes
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <alpine.LFD.2.00.1103152102430.2787@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
	 <20110314163028.a05cec49.akpm@linux-foundation.org>
	 <20110314234754.GP2499@one.firstfloor.org>
	 <alpine.LFD.2.00.1103150114590.2787@localhost6.localdomain6>
	 <20110315180639.GQ2499@one.firstfloor.org>
	 <alpine.LFD.2.00.1103152038280.2787@localhost6.localdomain6>
	 <1300219261.9910.300.camel@gandalf.stny.rr.com>
	 <alpine.LFD.2.00.1103152102430.2787@localhost6.localdomain6>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Tue, 15 Mar 2011 16:44:16 -0400
Message-ID: <1300221856.9910.305.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Paul
 E. McKenney" <paulmck@linux.vnet.ibm.com>

On Tue, 2011-03-15 at 21:09 +0100, Thomas Gleixner wrote:
> On Tue, 15 Mar 2011, Steven Rostedt wrote:

> I didn't say that ptrace rocks.
> 
> All I'm saying is that we want a better argument than a single user
> which is - and yes i tried it more than once - assbackwards beyond all
> imagination.
> 
> If gdb, perf, trace can and will make use of it then we have sensible

I'm more interested in the perf/trace than gdb, as the way gdb is mostly
used (at least now) to debug problems in the code with a big hammer
(single step, look at registers/variables). That is, gdb is usually very
interactive and its best to "stop the code" from running to examine what
has happened. gdb is not something you will run on an application that
is being used by others.

With perf/trace things are different, as you want the task to be as
little affected by the tracer as it runs, perhaps even in a production
environment. This is a completely different paradigm.

If gdb uses it, great, but I don't think we should bend over backwards
to make it usable by gdb. Debugging and tracing are different, with
different requirements and needs.

> arguments enough to go there. If systemtap can use it as well then I
> have no problem with that..

Fair enough.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
