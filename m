Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id m7SB08tV010098
	for <linux-mm@kvack.org>; Thu, 28 Aug 2008 21:00:08 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7SB11uR3506260
	for <linux-mm@kvack.org>; Thu, 28 Aug 2008 21:01:01 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7SB11M5010480
	for <linux-mm@kvack.org>; Thu, 28 Aug 2008 21:01:01 +1000
Message-ID: <48B68569.7030906@linux.vnet.ibm.com>
Date: Thu, 28 Aug 2008 16:30:57 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 7/14] memcg: add prefetch to spinlock
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com> <20080822203630.cac5c076.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080822203630.cac5c076.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Address of "mz" can be calculated in easy way.
> prefetch it (we do spin_lock.)
> 
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> Index: mmtom-2.6.27-rc3+/mm/memcontrol.c
> ===================================================================
> --- mmtom-2.6.27-rc3+.orig/mm/memcontrol.c
> +++ mmtom-2.6.27-rc3+/mm/memcontrol.c
> @@ -707,6 +707,8 @@ static int mem_cgroup_charge_common(stru
>  		}
>  	}
> 
> +	mz = mem_cgroup_zoneinfo(mem, page_to_nid(page), page_zonenum(page));
> +	prefetchw(mz);

Nice optimization!

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
