Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2F51B8D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 01:51:51 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp02.au.ibm.com (8.14.4/8.13.1) with ESMTP id p2G5kOlC017249
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 16:46:24 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2G5pkT82039950
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 16:51:46 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2G5pidH021412
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 16:51:46 +1100
Date: Wed, 16 Mar 2011 11:21:39 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 7/20]  7: uprobes: store/restore
 original instruction.
Message-ID: <20110316055138.GI3410@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
 <20110314133522.27435.45121.sendpatchset@localhost6.localdomain6>
 <20110314180914.GA18855@fibrous.localdomain>
 <20110315092247.GW24254@linux.vnet.ibm.com>
 <1300211862.2203.302.camel@twins>
 <20110315185841.GH3410@balbir.in.ibm.com>
 <1300217432.2250.0.camel@laptop>
 <1300217560.9910.296.camel@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1300217560.9910.296.camel@gandalf.stny.rr.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

* Steven Rostedt <rostedt@goodmis.org> [2011-03-15 15:32:40]:

> On Tue, 2011-03-15 at 20:30 +0100, Peter Zijlstra wrote:
> > On Wed, 2011-03-16 at 00:28 +0530, Balbir Singh wrote:
> 
> > > I accept the blame and am willing to fix anything incorrect found in
> > > the code. 
> > 
> > :-), ok sounds right, just wasn't entirely obvious when having a quick
> > look.
> 
> Does that mean we should be adding a comment there?
>

This is what the current documentation looks like.

#ifdef CONFIG_MM_OWNER
        /*
         * "owner" points to a task that is regarded as the canonical
         * user/owner of this mm. All of the following must be true in
         * order for it to be changed:
         *
         * current == mm->owner
         * current->mm != mm
         * new_owner->mm == mm
         * new_owner->alloc_lock is held
         */
        struct task_struct __rcu *owner;
#endif

Do you want me to document the fork/exit case?
 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
