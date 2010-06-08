Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2963E6B01D8
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 15:00:13 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o58J0AqP023484
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 12:00:10 -0700
Received: from pxi12 (pxi12.prod.google.com [10.243.27.12])
	by wpaz17.hot.corp.google.com with ESMTP id o58J09l0005274
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 12:00:09 -0700
Received: by pxi12 with SMTP id 12so1975983pxi.28
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 12:00:09 -0700 (PDT)
Date: Tue, 8 Jun 2010 12:00:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 18/18] oom: deprecate oom_adj tunable
In-Reply-To: <20100608194514.7654.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006081158220.18848@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061527320.32225@chino.kir.corp.google.com> <20100608194514.7654.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, KOSAKI Motohiro wrote:

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

We?  Who are you representing?

The deprecation of this tunable was suggested by Andrew since it is 
replaced with a more powerful and finer-grained tunable, oom_score_adj.  
The deprecation date is two years from now which gives plenty of 
opportunity for users to use the new, well-documented interface.

> In addition, this knob is used from some applications (please google
> by google code search or something else). that said, an enduser can't
> stop the warning. that makes a lot of frustration. NO.
> 

They can report it over the two year period and hopefully get it fixed 
up, this isn't a BUG(), it's a printk_once().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
