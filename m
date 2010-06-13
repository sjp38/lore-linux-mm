Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9FC566B01B5
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 07:25:02 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5DBP0Il022723
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 13 Jun 2010 20:25:00 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 307FA45DE51
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:25:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E69D45DD77
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:25:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EAE8C1DB8038
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:59 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9861E1DB803E
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 18/18] oom: deprecate oom_adj tunable
In-Reply-To: <20100608161844.04d2f2a1.akpm@linux-foundation.org>
References: <20100608194514.7654.A69D9226@jp.fujitsu.com> <20100608161844.04d2f2a1.akpm@linux-foundation.org>
Message-Id: <20100613201922.619C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Sun, 13 Jun 2010 20:24:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue,  8 Jun 2010 20:42:02 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > +	/*
> > > +	 * Warn that /proc/pid/oom_adj is deprecated, see
> > > +	 * Documentation/feature-removal-schedule.txt.
> > > +	 */
> > > +	printk_once(KERN_WARNING "%s (%d): /proc/%d/oom_adj is deprecated, "
> > > +			"please use /proc/%d/oom_score_adj instead.\n",
> > > +			current->comm, task_pid_nr(current),
> > > +			task_pid_nr(task), task_pid_nr(task));
> > >  	task->signal->oom_adj = oom_adjust;
> > 
> > Sorry, we can't accept this. oom_adj is one of most freqently used
> > tuning knob. putting this one makes a lot of confusion.
> > 
> > In addition, this knob is used from some applications (please google
> > by google code search or something else). that said, an enduser can't
> > stop the warning. that makes a lot of frustration. NO.
> > 
> 
> I think it's OK.  We made a mistake in adding oom_adj in the first
> place and now we get to live with the consequences.
> 
> We'll be stuck with oom_adj for the next 200 years if we don't tell
> people to stop using it, and a printk_once() is a good way of doing
> that.
> 
> It could be that in two years time we decide that we can't remove oom_adj
> yet because too many people are still using it.  Maybe it will take ten
> years - but unless we add the above printk, oom_adj will remain
> forever.

But oom_score_adj have no benefit form end-uses view. That's problem.
Please consider to make end-user friendly good patch at first.

I mean, I'm not against better knob deprecate old one. but I require
'better' mean end-users better.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
