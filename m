Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6CF468D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 12:16:19 -0400 (EDT)
Date: Tue, 15 Mar 2011 12:15:30 -0400
From: Stephen Wilson <wilsons@start.ca>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 7/20]  7: uprobes: store/restore
	original instruction.
Message-ID: <20110315161530.GA23862@fibrous.localdomain>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6> <20110314133522.27435.45121.sendpatchset@localhost6.localdomain6> <20110314180914.GA18855@fibrous.localdomain> <20110315092247.GW24254@linux.vnet.ibm.com> <1300196879.9910.271.camel@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1300196879.9910.271.camel@gandalf.stny.rr.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Tue, Mar 15, 2011 at 09:47:59AM -0400, Steven Rostedt wrote:
> > 	rcu_read_lock()
> > 	if (mm->owner) {
> > 		get_task_struct(mm->owner)
> > 		tsk = mm->owner;
> > 	}
> > 	rcu_read_unlock()
> > 	if (!tsk)
> > 		return ret;
> > 
> > Agree?
> 
> Or:
> 
> 	rcu_read_lock();
> 	tsk = mm->owner;
> 	if (tsk)
> 		get_task_struct(tsk);
> 	rcu_read_unlock();
> 	if (!tsk)
> 		return ret;
> 
> Probably looks cleaner.

Yes, plus we should do "tsk = rcu_dereference(mm->owner);" and wrap the
whole thing in a static uprobes_get_mm_owner() or similar.


-- 
steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
