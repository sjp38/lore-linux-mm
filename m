Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 28E688D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 15:28:52 -0400 (EDT)
Received: from canuck.infradead.org ([2001:4978:20e::1])
	by bombadil.infradead.org with esmtps (Exim 4.72 #1 (Red Hat Linux))
	id 1PzZvF-0007Ee-58
	for linux-mm@kvack.org; Tue, 15 Mar 2011 19:28:49 +0000
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by canuck.infradead.org with esmtpsa (Exim 4.72 #1 (Red Hat Linux))
	id 1PzZvA-0004Ss-2k
	for linux-mm@kvack.org; Tue, 15 Mar 2011 19:28:44 +0000
Subject: Re: [PATCH v2 2.6.38-rc8-tip 7/20]  7: uprobes: store/restore
 original instruction.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110315185841.GH3410@balbir.in.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
	 <20110314133522.27435.45121.sendpatchset@localhost6.localdomain6>
	 <20110314180914.GA18855@fibrous.localdomain>
	 <20110315092247.GW24254@linux.vnet.ibm.com>
	 <1300211862.2203.302.camel@twins> <20110315185841.GH3410@balbir.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 15 Mar 2011 20:30:32 +0100
Message-ID: <1300217432.2250.0.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Wed, 2011-03-16 at 00:28 +0530, Balbir Singh wrote:
> 
> mm->owner should be under rcu_read_lock, unless the task is exiting
> and mm_count is 1. mm->owner is updated under task_lock().
> 
> > Also, the assignments in kernel/fork.c and kernel/exit.c don't use
> > rcu_assign_pointer() and therefore lack the needed write barrier.
> >
> 
> Those are paths when the only context using the mm->owner is single
>  
> > Git blames Balbir for this.
> 
> I accept the blame and am willing to fix anything incorrect found in
> the code. 

:-), ok sounds right, just wasn't entirely obvious when having a quick
look.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
