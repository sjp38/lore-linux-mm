Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4169D6B0047
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 06:00:52 -0500 (EST)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id n1AB0VrO028044
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 22:00:31 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1AB15ST364720
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 22:01:05 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1AB0lVJ028624
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 22:00:47 +1100
Date: Tue, 10 Feb 2009 16:30:45 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: remove mem_cgroup_reclaim_imbalance() perfectly
Message-ID: <20090210110045.GE16317@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090210184538.6FCF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090210184538.6FCF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-02-10 18:50:39]:

> 
> commit 4f98a2fee8acdb4ac84545df98cccecfd130f8db (vmscan: 
> split LRU lists into anon & file sets) remove mem_cgroup_reclaim_imbalance().
> 
> but it isn't enough.
> memcontrol.h header file still have legacy parts.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
>  include/linux/memcontrol.h |    6 ------
>  1 file changed, 6 deletions(-)
>

The calc_mapped_ratio prototype should also be removed from this file. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
