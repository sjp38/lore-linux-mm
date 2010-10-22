Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9B3A36B0087
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 14:47:03 -0400 (EDT)
Date: Fri, 22 Oct 2010 19:46:47 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: zone state overhead
Message-ID: <20101022184647.GH2160@csn.ul.ie>
References: <20101014120804.8B8F.A69D9226@jp.fujitsu.com> <20101018103941.GX30667@csn.ul.ie> <20101019100658.A1B3.A69D9226@jp.fujitsu.com> <20101019090803.GF30667@csn.ul.ie> <20101022141223.GF2160@csn.ul.ie> <alpine.DEB.2.00.1010221024080.20437@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1010221024080.20437@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 22, 2010 at 10:27:55AM -0500, Christoph Lameter wrote:
> On Fri, 22 Oct 2010, Mel Gorman wrote:
> 
> >
> > +void disable_pgdat_percpu_threshold(pg_data_t *pgdat)
> 
> Call this set_pgdat_stat_threshold() and make it take a calculate_pressure
> () function?
> 
> void set_pgdat_stat_threshold(pg_data_t *pgdat, int (*calculate_pressure)(struct zone *)) ?
> 
> Then  do
> 
> 	set_pgdat_stat_threshold(pgdat, threshold_normal)
> 
> 	set_pgdat_stat_threshold(pgdat, threshold_pressure)
> 
> ?
> 

I considered it but thought the indirection would look tortured and
hinder review. If we agree on the basic premise, I would do it as two
patches. Would that suit?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
