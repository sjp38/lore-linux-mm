Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 30F096B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 09:24:55 -0400 (EDT)
Date: Mon, 8 Jun 2009 15:43:46 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] Do not unconditionally treat zones that fail
	zone_reclaim() as full
Message-ID: <20090608144346.GH15070@csn.ul.ie>
References: <1244466090-10711-1-git-send-email-mel@csn.ul.ie> <1244466090-10711-4-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0906081030280.21954@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0906081030280.21954@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 08, 2009 at 10:32:12AM -0400, Christoph Lameter wrote:
> Ok this patch addresses a bug in zone reclaim introduced by Paul Jackson
> in commit 9276b1bc96a132f4068fdee00983c532f43d3a26. Before that commit
> zone reclaim would not mark a zone as full if it failed but simply
> continue scanning.
> 

Well spotted. I hadn't checked out the history as to when this problem
was introduced but it looks like this bug was introduced way back around
2.6.19.

> Acked-by: Christoph Lameter <cl@linux-foundation.org>
> 

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
