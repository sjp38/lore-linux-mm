Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AE505900086
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 06:58:51 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3J6mBvb025530
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 02:48:11 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3J6wnpG331814
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 02:58:49 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3J6wl3n032746
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 03:58:49 -0300
Date: Tue, 19 Apr 2011 12:15:11 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 2.6.39-rc1-tip 9/26]  9: uprobes: mmap and fork
 hooks.
Message-ID: <20110419064511.GC10698@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
 <20110401143413.15455.75831.sendpatchset@localhost6.localdomain6>
 <1303144163.32491.875.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1303144163.32491.875.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>

* Peter Zijlstra <peterz@infradead.org> [2011-04-18 18:29:23]:

> On Fri, 2011-04-01 at 20:04 +0530, Srikar Dronamraju wrote:
> > +               if (vaddr > ULONG_MAX)
> > +                       /*
> > +                        * We cannot have a virtual address that is
> > +                        * greater than ULONG_MAX
> > +                        */
> > +                       continue; 
> 
> I'm having trouble with those checks.. while they're not wrong they're
> not correct either. Mostly the top address space is where the kernel
> lives and on 32-on-64 compat the boundary is much lower still. Ideally
> it'd be TASK_SIZE, but that doesn't work since it assumes you're testing
> for the current task.
> 

Guess I can use TASK_SIZE_OF(tsk) instead of ULONG_MAX ?
I think TASK_SIZE_OF handles 32-on-64 correctly.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
