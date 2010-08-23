Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F327D6007DC
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 03:18:58 -0400 (EDT)
Date: Mon, 23 Aug 2010 08:18:43 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] vmstat : update zone stat threshold at onlining a cpu
Message-ID: <20100823071843.GN19797@csn.ul.ie>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie> <1281951733-29466-3-git-send-email-mel@csn.ul.ie> <20100818115949.c840c937.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008181050230.4025@router.home> <20100819090740.3f46aecf.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008191359400.1839@router.home> <20100820084908.10e55b76.kamezawa.hiroyu@jp.fujitsu.com> <20100820092251.2ca67f66.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100820092251.2ca67f66.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 20, 2010 at 09:22:51AM +0900, KAMEZAWA Hiroyuki wrote:
> 
> refresh_zone_stat_thresholds() calculates parameter based on
> the number of online cpus. It's called at cpu offlining but
> needs to be called at onlining, too.
> 
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
