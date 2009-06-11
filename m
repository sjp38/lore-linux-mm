Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AECF86B004D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 06:51:26 -0400 (EDT)
Date: Thu, 11 Jun 2009 11:53:00 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH for mmotm 0/5] introduce swap-backed-file-mapped count
	and fix
	vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch
Message-ID: <20090611105259.GC7302@csn.ul.ie>
References: <20090611192114.6D4A.A69D9226@jp.fujitsu.com> <20090611103837.GB7302@csn.ul.ie> <20090611194141.6D5C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090611194141.6D5C.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 11, 2009 at 07:42:33PM +0900, KOSAKI Motohiro wrote:
> > On Thu, Jun 11, 2009 at 07:25:09PM +0900, KOSAKI Motohiro wrote:
> > > Recently, Wu Fengguang pointed out vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch
> > > has underflow problem.
> > > 
> > 
> > Can you drop this aspect of the patchset please? I'm doing a final test
> > on the scan-avoidance heuristic that incorporates this patch and the
> > underflow fix. Ram (the tester of the malloc()-stall) confirms the patch
> > fixes his problem.
> 
> OK.
> insted, I'll join to review your patch :)
> 

Thanks. You should have it now. In particular, I'm interested in hearing you
opinion about patch 1 of the series "Fix malloc() stall in zone_reclaim()
and bring behaviour more in line with expectations V3" and if addresses;

1. Does patch 1 address the problem that first led you to develop the patch
vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch?

2. Do you think patch 1 should merge with and replace
vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch?

> > > This patch series introduce new vmstat of swap-backed-file-mapped and fix above
> > > patch by it.
> 

I don't think the patch above needs to be fixed by another counter. At
least, once the underflow was fixed up, it handled the malloc-stall without
additional counters. If we need to account swap-backed-file-mapped, we need
another failure case that it addresses to be sure we're doing the right thing.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
