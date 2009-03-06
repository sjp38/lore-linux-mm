Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 822926B010E
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 05:05:42 -0500 (EST)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp09.in.ibm.com (8.13.1/8.13.1) with ESMTP id n269fsK6026037
	for <linux-mm@kvack.org>; Fri, 6 Mar 2009 15:11:54 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n26A5ipY4202584
	for <linux-mm@kvack.org>; Fri, 6 Mar 2009 15:35:44 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id n26A5ZO5022485
	for <linux-mm@kvack.org>; Fri, 6 Mar 2009 21:05:36 +1100
Date: Fri, 6 Mar 2009 15:35:34 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/4] Memory controller soft limit patches (v4)
Message-ID: <20090306100534.GD5482@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090306092323.21063.93169.sendpatchset@localhost.localdomain> <20090306185440.66b92ca3.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090306185440.66b92ca3.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-06 18:54:40]:

> On Fri, 06 Mar 2009 14:53:23 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > 
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> > New Feature: Soft limits for memory resource controller.
> > 
> > Changelog v4...v3
> > 1. Adopted suggestions from Kamezawa to do a per-zone-per-node reclaim
> >    while doing soft limit reclaim. We don't record priorities while
> >    doing soft reclaim
> > 2. Some of the overheads associated with soft limits (like calculating
> >    excess each time) is eliminated
> > 3. The time_after(jiffies, 0) bug has been fixed
> > 4. Tasks are throttled if the mem cgroup they belong to is being soft reclaimed
> >    and at the same time tasks are increasing the memory footprint and causing
> >    the mem cgroup to exceed its soft limit.
> > 
> I don't think this "4" is necessary.
>

I responded to it and I had asked for review for this. Lets discuss it
there. I am open to doing this or not.
 
> 
> > Changelog v3...v2
> > 1. Implemented several review comments from Kosaki-San and Kamezawa-San
> >    Please see individual changelogs for changes
> > 
> > Changelog v2...v1
> > 1. Soft limits now support hierarchies
> > 2. Use spinlocks instead of mutexes for synchronization of the RB tree
> > 
> > Here is v4 of the new soft limit implementation. Soft limits is a new feature
> > for the memory resource controller, something similar has existed in the
> > group scheduler in the form of shares. The CPU controllers interpretation
> > of shares is very different though. 
> > 
> > Soft limits are the most useful feature to have for environments where
> > the administrator wants to overcommit the system, such that only on memory
> > contention do the limits become active. The current soft limits implementation
> > provides a soft_limit_in_bytes interface for the memory controller and not
> > for memory+swap controller. The implementation maintains an RB-Tree of groups
> > that exceed their soft limit and starts reclaiming from the group that
> > exceeds this limit by the maximum amount.
> > 
> > If there are no major objections to the patches, I would like to get them
> > included in -mm.
> > 
> You got Nack from me, again ;) And you know why.
> I'll post my one later, I hope that one will be good input for you.
>

Lets discuss the patches and your objections. I suspect it is because
of 4 above, but I don't want to keep guessing. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
