Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8FDBD8D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:31:35 -0400 (EDT)
Date: Mon, 14 Mar 2011 16:30:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 0/20]  0: Inode based uprobes
Message-Id: <20110314163028.a05cec49.akpm@linux-foundation.org>
In-Reply-To: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Mon, 14 Mar 2011 19:04:03 +0530
Srikar Dronamraju <srikar@linux.vnet.ibm.com> wrote:

> Advantages of uprobes over conventional debugging include:
> 
> 1. Non-disruptive.
> Unlike current ptrace based mechanisms, uprobes tracing wouldnt
> involve signals, stopping threads and context switching between the
> tracer and tracee.
> 
> 2. Much better handling of multithreaded programs because of XOL.
> Current ptrace based mechanisms use single stepping inline, i.e they
> copy back the original instruction on hitting a breakpoint.  In such
> mechanisms tracers have to stop all the threads on a breakpoint hit or
> tracers will not be able to handle all hits to the location of
> interest. Uprobes uses execution out of line, where the instruction to
> be traced is analysed at the time of breakpoint insertion and a copy
> of instruction is stored at a different location.  On breakpoint hit,
> uprobes jumps to that copied location and singlesteps the same
> instruction and does the necessary fixups post singlestepping.
> 
> 3. Multiple tracers for an application.
> Multiple uprobes based tracer could work in unison to trace an
> application. There could one tracer that could be interested in
> generic events for a particular set of process. While there could be
> another tracer that is just interested in one specific event of a
> particular process thats part of the previous set of process.
> 
> 4. Corelating events from kernels and userspace.
> Uprobes could be used with other tools like kprobes, tracepoints or as
> part of higher level tools like perf to give a consolidated set of
> events from kernel and userspace.  In future we could look at a single
> backtrace showing application, library and kernel calls.

How do you envisage these features actually get used?  For example,
will gdb be modified?  Will other debuggers be modified or written?

IOW, I'm trying to get an understanding of how you expect this feature
will actually become useful to end users - the kernel patch is only
part of the story.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
