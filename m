Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0C2BD8D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 13:40:41 -0400 (EDT)
Subject: Re: [PATCH v2 2.6.38-rc8-tip 7/20]  7: uprobes: store/restore
 original instruction.
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <20110316055138.GI3410@balbir.in.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
	 <20110314133522.27435.45121.sendpatchset@localhost6.localdomain6>
	 <20110314180914.GA18855@fibrous.localdomain>
	 <20110315092247.GW24254@linux.vnet.ibm.com>
	 <1300211862.2203.302.camel@twins> <20110315185841.GH3410@balbir.in.ibm.com>
	 <1300217432.2250.0.camel@laptop>
	 <1300217560.9910.296.camel@gandalf.stny.rr.com>
	 <20110316055138.GI3410@balbir.in.ibm.com>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Wed, 16 Mar 2011 13:40:37 -0400
Message-ID: <1300297237.16880.42.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Peter Zijlstra <peterz@infradead.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Wed, 2011-03-16 at 11:21 +0530, Balbir Singh wrote:
> * Steven Rostedt <rostedt@goodmis.org> [2011-03-15 15:32:40]:
> 
> > On Tue, 2011-03-15 at 20:30 +0100, Peter Zijlstra wrote:
> > > On Wed, 2011-03-16 at 00:28 +0530, Balbir Singh wrote:
> > 
> > > > I accept the blame and am willing to fix anything incorrect found in
> > > > the code. 
> > > 
> > > :-), ok sounds right, just wasn't entirely obvious when having a quick
> > > look.
> > 
> > Does that mean we should be adding a comment there?
> >
> 
> This is what the current documentation looks like.
> 
> #ifdef CONFIG_MM_OWNER
>         /*
>          * "owner" points to a task that is regarded as the canonical
>          * user/owner of this mm. All of the following must be true in
>          * order for it to be changed:
>          *
>          * current == mm->owner
>          * current->mm != mm
>          * new_owner->mm == mm
>          * new_owner->alloc_lock is held
>          */
>         struct task_struct __rcu *owner;
> #endif
> 
> Do you want me to document the fork/exit case?
>  

Ah, looking at the code, I guess comments are not needed.

Thanks,

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
