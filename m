Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3B68F6B02A5
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 07:02:11 -0400 (EDT)
Date: Thu, 22 Jul 2010 12:01:54 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/7] memcg: nid and zid can be calculated from zone
Message-ID: <20100722110154.GG13117@csn.ul.ie>
References: <20100716191418.7372.A69D9226@jp.fujitsu.com> <20100716105648.GG13117@csn.ul.ie> <20100721223349.870D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100721223349.870D.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 21, 2010 at 10:33:56PM +0900, KOSAKI Motohiro wrote:
> > > +static inline int zone_nid(struct zone *zone)
> > > +{
> > > +	return zone->zone_pgdat->node_id;
> > > +}
> > > +
> > 
> > hmm, adding a helper and not converting the existing users of
> > zone->zone_pgdat may be a little confusing particularly as both types of
> > usage would exist in the same file e.g. in mem_cgroup_zone_nr_pages.
> 
> I see. here is incrementa patch.
> 

Looks grand. Thanks

> From 62cf765251af257c98fc92a58215d101d200e7ef Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Tue, 20 Jul 2010 11:30:14 +0900
> Subject: [PATCH] memcg: convert to zone_nid() from bare zone->zone_pgdat->node_id
> 
> Now, we have zone_nid(). this patch convert all existing users of
> zone->zone_pgdat.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>
> <SNIP>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
