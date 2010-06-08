Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BE4546B01B2
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 19:19:30 -0400 (EDT)
Date: Tue, 8 Jun 2010 16:18:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 18/18] oom: deprecate oom_adj tunable
Message-Id: <20100608161844.04d2f2a1.akpm@linux-foundation.org>
In-Reply-To: <20100608194514.7654.A69D9226@jp.fujitsu.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006061527320.32225@chino.kir.corp.google.com>
	<20100608194514.7654.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue,  8 Jun 2010 20:42:02 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > +	/*
> > +	 * Warn that /proc/pid/oom_adj is deprecated, see
> > +	 * Documentation/feature-removal-schedule.txt.
> > +	 */
> > +	printk_once(KERN_WARNING "%s (%d): /proc/%d/oom_adj is deprecated, "
> > +			"please use /proc/%d/oom_score_adj instead.\n",
> > +			current->comm, task_pid_nr(current),
> > +			task_pid_nr(task), task_pid_nr(task));
> >  	task->signal->oom_adj = oom_adjust;
> 
> Sorry, we can't accept this. oom_adj is one of most freqently used
> tuning knob. putting this one makes a lot of confusion.
> 
> In addition, this knob is used from some applications (please google
> by google code search or something else). that said, an enduser can't
> stop the warning. that makes a lot of frustration. NO.
> 

I think it's OK.  We made a mistake in adding oom_adj in the first
place and now we get to live with the consequences.

We'll be stuck with oom_adj for the next 200 years if we don't tell
people to stop using it, and a printk_once() is a good way of doing
that.

It could be that in two years time we decide that we can't remove oom_adj
yet because too many people are still using it.  Maybe it will take ten
years - but unless we add the above printk, oom_adj will remain
forever.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
