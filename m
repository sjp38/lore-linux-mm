Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id mB3DjcG7003887
	for <linux-mm@kvack.org>; Thu, 4 Dec 2008 00:45:38 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB3DeR0a226804
	for <linux-mm@kvack.org>; Thu, 4 Dec 2008 00:40:27 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mB3DeRcB031536
	for <linux-mm@kvack.org>; Thu, 4 Dec 2008 00:40:27 +1100
Date: Wed, 3 Dec 2008 19:10:25 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] Unused check for thread group leader in
	mem_cgroup_move_task
Message-ID: <20081203134024.GD17701@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <200811291259.27681.knikanth@suse.de> <20081201101208.08e0aa98.kamezawa.hiroyu@jp.fujitsu.com> <200812010951.36392.knikanth@suse.de> <20081201133030.0a330c7b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20081201133030.0a330c7b.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Nikanth Karthikesan <knikanth@suse.de>, containers@lists.linux-foundation.org, xemul@openvz.org, linux-mm@kvack.org, nikanth@gmail.com
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-12-01 13:30:30]:

> On Mon, 1 Dec 2008 09:51:35 +0530
> Nikanth Karthikesan <knikanth@suse.de> wrote:
> 
> > Ok. Then should we remove the unused code which simply checks for thread group 
> > leader but does nothing?
> >  
> > Thanks
> > Nikanth
> > 
> Hmm, it seem that code is obsolete. thanks.
> Balbir, how do you think ?
> 
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Anyway we have to visit here, again.

Sorry, I did not review this patch. The correct thing was nikanth did
at first, move this to can_attach(). Why would we allow threads to
exist in different groups, but still mark them as being accounted to
the thread group leader.

It can be a bit confusing for end users, it can be helpful when all
controllers are mounted together. I agree we did not do anything
useful in move_task(). The correct check now, should be for mm->owner.

If the common case is going to be that memory and cpu are mounted
together, then this patch is correct, but it can be confusing to users
who look at tasks/threads, but as the threads consume memory, the
accounting will happen with mm->owner.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
