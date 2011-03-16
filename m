Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7C9078D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 13:44:12 -0400 (EDT)
Subject: Re: [PATCH v2 2.6.38-rc8-tip 0/20] 0: Inode based uprobes
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <m3lj0f2cq1.fsf@fleche.redhat.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
	 <20110314163028.a05cec49.akpm@linux-foundation.org>
	 <20110314234754.GP2499@one.firstfloor.org>
	 <alpine.LFD.2.00.1103150114590.2787@localhost6.localdomain6>
	 <20110315180639.GQ2499@one.firstfloor.org>
	 <alpine.LFD.2.00.1103152038280.2787@localhost6.localdomain6>
	 <1300219261.9910.300.camel@gandalf.stny.rr.com>
	 <alpine.LFD.2.00.1103152102430.2787@localhost6.localdomain6>
	 <1300221856.9910.305.camel@gandalf.stny.rr.com>
	 <m3lj0f2cq1.fsf@fleche.redhat.com>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Wed, 16 Mar 2011 13:44:09 -0400
Message-ID: <1300297449.16880.45.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Tromey <tromey@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Paul
 E. McKenney" <paulmck@linux.vnet.ibm.com>

On Wed, 2011-03-16 at 11:32 -0600, Tom Tromey wrote:
> Steve> I'm more interested in the perf/trace than gdb, as the way gdb is mostly
> Steve> used (at least now) to debug problems in the code with a big hammer
> Steve> (single step, look at registers/variables). That is, gdb is usually very
> Steve> interactive and its best to "stop the code" from running to examine what
> Steve> has happened. gdb is not something you will run on an application that
> Steve> is being used by others.
> 
> It depends.  People do in fact do this stuff.  In recent years gdb got
> its own implementation of "always inserted" breakpoints (basically the
> same idea as uprobes) to support some trickier multi-thread debugging
> scenarios.

Like I said, if it helps out gdb then great! My concern is that we will
want it to replace ptrace, where it may not be designed to, then people
will start NAKing it.

I hope that gdb uses it, and we don't add another interface that nobody
uses. But I don't see that happening with uprobes.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
