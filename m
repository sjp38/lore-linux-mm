Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 06D9E6B004D
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 11:20:37 -0400 (EDT)
Date: Tue, 21 Jul 2009 00:20:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 5/5] Memory controller soft limit reclaim on contention (v9)
In-Reply-To: <20090710130021.5610.74850.sendpatchset@balbir-laptop>
References: <20090710125950.5610.99139.sendpatchset@balbir-laptop> <20090710130021.5610.74850.sendpatchset@balbir-laptop>
Message-Id: <20090721001923.AF72.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


very sorry for the delaying.


> @@ -1918,6 +1951,7 @@ loop_again:
>  		for (i = 0; i <= end_zone; i++) {
>  			struct zone *zone = pgdat->node_zones + i;
>  			int nr_slab;
> +			int nid, zid;
>  
>  			if (!populated_zone(zone))
>  				continue;
> @@ -1932,6 +1966,15 @@ loop_again:
>  			temp_priority[i] = priority;
>  			sc.nr_scanned = 0;
>  			note_zone_scanning_priority(zone, priority);
> +
> +			nid = pgdat->node_id;
> +			zid = zone_idx(zone);
> +			/*
> +			 * Call soft limit reclaim before calling shrink_zone.
> +			 * For now we ignore the return value
> +			 */
> +			mem_cgroup_soft_limit_reclaim(zone, order, sc.gfp_mask,
> +							nid, zid);
>  			/*
>  			 * We put equal pressure on every zone, unless one
>  			 * zone has way too many pages free already.


In this part:
	Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
