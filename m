Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1E9JHp6028921
	for <linux-mm@kvack.org>; Thu, 14 Feb 2008 14:49:17 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1E9JG6v1020020
	for <linux-mm@kvack.org>; Thu, 14 Feb 2008 14:49:16 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1E9JGww013081
	for <linux-mm@kvack.org>; Thu, 14 Feb 2008 09:19:16 GMT
Message-ID: <47B406E4.9060109@linux.vnet.ibm.com>
Date: Thu, 14 Feb 2008 14:46:20 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC] [PATCH 3/4] Reclaim from groups over their soft limit under
 memory pressure
References: <20080213151201.7529.53642.sendpatchset@localhost.localdomain> <20080213151242.7529.79924.sendpatchset@localhost.localdomain> <20080214163054.81deaf27.kamezawa.hiroyu@jp.fujitsu.com> <47B3F073.1070804@linux.vnet.ibm.com> <20080214174236.aa2aae9b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080214174236.aa2aae9b.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Herbert Poetzl <herbert@13thfloor.at>, "Eric W. Biederman" <ebiederm@xmission.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Rik Van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Thu, 14 Feb 2008 13:10:35 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>>> And I think it's big workload to relclaim all excessed pages at once.
>>>
>>> How about just reclaiming small # of pages ? like
>>> ==
>>> if (nr_bytes_over_sl <= 0)
>>> 	goto next;
>>> nr_pages = SWAP_CLUSTER_MAX;
>> I thought about this, but wanted to push back all groups over their soft limit
>> back to their soft limit quickly. I'll experiment with your suggestion and see
>> how the system behaves when we push back pages slowly. Thanks for the suggestion.
> 
> My point is an unlucky process may have to reclaim tons of pages even if
> what he wants is just 1 page. It's not good, IMO.
> 

Yes, that makes sense.

> Probably backgound-reclaim patch will be able to help this soft-limit situation,
> if a daemon can know it should reclaim or not.
> 

Yes, I agree. I might just need to schedule the daemon under memory pressure.

> Thanks,
> -Kame

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
