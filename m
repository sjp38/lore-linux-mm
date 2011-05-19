Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9D5F96B0011
	for <linux-mm@kvack.org>; Thu, 19 May 2011 04:02:12 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp02.in.ibm.com (8.14.4/8.13.1) with ESMTP id p4J824IP016731
	for <linux-mm@kvack.org>; Thu, 19 May 2011 13:32:04 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4J823Ti2691146
	for <linux-mm@kvack.org>; Thu, 19 May 2011 13:32:04 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4J821ka029759
	for <linux-mm@kvack.org>; Thu, 19 May 2011 18:02:03 +1000
Date: Thu, 19 May 2011 13:31:35 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH V2 2/2] memcg: add memory.numastat api for numa
 statistics
Message-ID: <20110519080135.GE3139@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1305766511-11469-1-git-send-email-yinghan@google.com>
 <1305766511-11469-2-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1305766511-11469-2-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

* Ying Han <yinghan@google.com> [2011-05-18 17:55:11]:

> The new API exports numa_maps per-memcg basis. This is a piece of useful
> information where it exports per-memcg page distribution across real numa
> nodes.
> 
> One of the usecase is evaluating application performance by combining this
> information w/ the cpu allocation to the application.
> 
> The output of the memory.numastat tries to follow w/ simiar format of numa_maps
> like:
> 
> total=<total pages> N0=<node 0 pages> N1=<node 1 pages> ...
> file=<total file pages> N0=<node 0 pages> N1=<node 1 pages> ...
> anon=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
>

That seems like a good idea, so +1 for we need to do this.
 
> $ cat /dev/cgroup/memory/memory.numa_stat
> total=317674 N0=101850 N1=72552 N2=30120 N3=113142
> file=288219 N0=98046 N1=59220 N2=23578 N3=107375
> anon=25699 N0=3804 N1=10124 N2=6540 N3=5231
> 
> Note: I noticed <total pages> is not equal to the sum of the rest of counters.
> I might need to change the way get that counter, comments are welcomed.
> 

Can you see if the total is greater or lesser than the actual value?
Do you have any pages mlocked?

> change v2..v1:
> 1. add also the file and anon pages on per-node distribution.
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
>  mm/memcontrol.c |  109 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 109 insertions(+), 0 deletions(-)
> 
-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
