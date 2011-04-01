Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 16C3B8D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 09:12:32 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp07.in.ibm.com (8.14.4/8.13.1) with ESMTP id p31DCOfE007969
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 18:42:24 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p31DCMmK1990840
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 18:42:22 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p31DCLOq016401
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 00:12:22 +1100
Date: Fri, 1 Apr 2011 18:42:15 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/3] Unmapped page cache control (v5)
Message-ID: <20110401131214.GS2879@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20110331144145.0ECA.A69D9226@jp.fujitsu.com>
 <20110331082813.GN2879@balbir.in.ibm.com>
 <20110401165752.A889.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110401165752.A889.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2011-04-01 16:56:57]:

> Hi
> 
> > > 1) zone reclaim doesn't work if the system has multiple node and the
> > >    workload is file cache oriented (eg file server, web server, mail server, et al). 
> > >    because zone recliam make some much free pages than zone->pages_min and
> > >    then new page cache request consume nearest node memory and then it
> > >    bring next zone reclaim. Then, memory utilization is reduced and
> > >    unnecessary LRU discard is increased dramatically.
> > > 
> > >    SGI folks added CPUSET specific solution in past. (cpuset.memory_spread_page)
> > >    But global recliam still have its issue. zone recliam is HPC workload specific 
> > >    feature and HPC folks has no motivation to don't use CPUSET.
> > 
> > I am afraid you misread the patches and the intent. The intent to
> > explictly enable control of unmapped pages and has nothing
> > specifically to do with multiple nodes at this point. The control is
> > system wide and carefully enabled by the administrator.
> 
> Hm. OK, I may misread.
> Can you please explain the reason why de-duplication feature need to selectable and
> disabled by defaut. "explicity enable" mean this feature want to spot corner case issue??
>

Yes, because given a selection of choices (including what you
mentioned in the review), it would be nice to have
this selectable.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
