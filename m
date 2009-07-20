Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4A60F6B004D
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 11:54:05 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n6KFhqqO014828
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 09:43:52 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n6KFlM4B146570
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 09:47:22 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6KFlLpM017998
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 09:47:22 -0600
Date: Mon, 20 Jul 2009 21:17:19 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 5/5] Memory controller soft limit reclaim on
	contention (v9)
Message-ID: <20090720154719.GH24157@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090710125950.5610.99139.sendpatchset@balbir-laptop> <20090710130021.5610.74850.sendpatchset@balbir-laptop> <20090721001923.AF72.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090721001923.AF72.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-07-21 00:20:38]:

> 
> very sorry for the delaying.
>

No problem, thanks for the review and ack
 
> 
> > @@ -1918,6 +1951,7 @@ loop_again:
> >  		for (i = 0; i <= end_zone; i++) {
> >  			struct zone *zone = pgdat->node_zones + i;
> >  			int nr_slab;
> > +			int nid, zid;
> >  
> >  			if (!populated_zone(zone))
> >  				continue;
> > @@ -1932,6 +1966,15 @@ loop_again:
> >  			temp_priority[i] = priority;
> >  			sc.nr_scanned = 0;
> >  			note_zone_scanning_priority(zone, priority);
> > +
> > +			nid = pgdat->node_id;
> > +			zid = zone_idx(zone);
> > +			/*
> > +			 * Call soft limit reclaim before calling shrink_zone.
> > +			 * For now we ignore the return value
> > +			 */
> > +			mem_cgroup_soft_limit_reclaim(zone, order, sc.gfp_mask,
> > +							nid, zid);
> >  			/*
> >  			 * We put equal pressure on every zone, unless one
> >  			 * zone has way too many pages free already.
> 
> 
> In this part:
> 	Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> 
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
