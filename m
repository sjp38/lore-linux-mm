Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 43D948D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 22:03:35 -0400 (EDT)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2F1dGQg016781
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 21:39:16 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 376556E8036
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 22:03:33 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2F23VjC2773236
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 22:03:31 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2F23UMG031996
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 23:03:31 -0300
Date: Tue, 15 Mar 2011 07:27:40 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 0/20]  0: Inode based uprobes
Message-ID: <20110315015739.GS24254@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
 <20110314163028.a05cec49.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110314163028.a05cec49.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

> > 
> > 4. Corelating events from kernels and userspace.
> > Uprobes could be used with other tools like kprobes, tracepoints or as
> > part of higher level tools like perf to give a consolidated set of
> > events from kernel and userspace.  In future we could look at a single
> > backtrace showing application, library and kernel calls.
> 
> How do you envisage these features actually get used?  For example,
> will gdb be modified?  Will other debuggers be modified or written?
> 
> IOW, I'm trying to get an understanding of how you expect this feature
> will actually become useful to end users - the kernel patch is only
> part of the story.
> 

Right, So I am looking at having perf probe for uprobes and also at
having a syscall so that perf probe and other ptrace users can use this
infrastructure. Ingo has already asked for a syscall for the same in
one of his replies to my previous patchset. From whatever
discussions I had with ptrace users, they have shown interest in
using this breakpoint infrastructure.

I am still not sure if this feature should be exposed thro a new
operation to ptrace syscall (something like SET_BP) or a completely new
syscall or both. I would be happy if people here could give inputs on
which route to go forward.

We had perf probe for uprobes implemented in few of the previous
patchset. When the underlying implementation changed from a
pid:vaddr to a file:offset, the way we invoke perf probe changed.

Previously we would do 
"perf probe -p 3692 zfree@zsh"

Now we would be doing 
"perf probe -u zfree@zsh"

The perf probe for uprobes is still WIP. Will post the patches when it
is in usable fashion. This should be pretty soon.

If you have suggestions on how this infrastructure could be used
above perf probe and syscall, then please do let me know.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
