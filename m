Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4D7608D0047
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 01:33:43 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp06.in.ibm.com (8.14.4/8.13.1) with ESMTP id p2U5XUCH015696
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 11:03:30 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2U5XTcj3940522
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 11:03:29 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2U5XUtk001129
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 11:03:31 +0530
Date: Wed, 30 Mar 2011 08:17:43 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH V3] Add the pagefault count into memcg stats
Message-ID: <20110330024743.GI2879@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1301379384-17568-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1301379384-17568-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Tejun Heo <tj@kernel.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

* Ying Han <yinghan@google.com> [2011-03-28 23:16:24]:

> Two new stats in per-memcg memory.stat which tracks the number of
> page faults and number of major page faults.
> 
> "pgfault"
> "pgmajfault"
> 
> They are different from "pgpgin"/"pgpgout" stat which count number of
> pages charged/discharged to the cgroup and have no meaning of reading/
> writing page to disk.
> 
> It is valuable to track the two stats for both measuring application's
> performance as well as the efficiency of the kernel page reclaim path.
> Counting pagefaults per process is useful, but we also need the aggregated
> value since processes are monitored and controlled in cgroup basis in memcg.
> 
> Functional test: check the total number of pgfault/pgmajfault of all
> memcgs and compare with global vmstat value:
>

Looks much better


Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 
 
-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
