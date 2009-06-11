Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E6BE46B005D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 06:37:30 -0400 (EDT)
Date: Thu, 11 Jun 2009 11:38:37 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH for mmotm 0/5] introduce swap-backed-file-mapped count
	and fix
	vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch
Message-ID: <20090611103837.GB7302@csn.ul.ie>
References: <20090611192114.6D4A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090611192114.6D4A.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 11, 2009 at 07:25:09PM +0900, KOSAKI Motohiro wrote:
> Recently, Wu Fengguang pointed out vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch
> has underflow problem.
> 

Can you drop this aspect of the patchset please? I'm doing a final test
on the scan-avoidance heuristic that incorporates this patch and the
underflow fix. Ram (the tester of the malloc()-stall) confirms the patch
fixes his problem.

> This patch series introduce new vmstat of swap-backed-file-mapped and fix above
> patch by it.
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
