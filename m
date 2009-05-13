Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B3F266B00F1
	for <linux-mm@kvack.org>; Wed, 13 May 2009 07:28:37 -0400 (EDT)
Date: Wed, 13 May 2009 13:26:40 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/4] vmscan: zone_reclaim use may_swap
Message-ID: <20090513112640.GC2254@cmpxchg.org>
References: <20090513120155.5879.A69D9226@jp.fujitsu.com> <20090513120651.5882.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090513120651.5882.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 13, 2009 at 12:07:30PM +0900, KOSAKI Motohiro wrote:
> Subject: [PATCH] vmscan: zone_reclaim use may_swap
> 
> Documentation/sysctl/vm.txt says
> 
> 	zone_reclaim_mode:
> 
> 	Zone_reclaim_mode allows someone to set more or less aggressive approaches to
> 	reclaim memory when a zone runs out of memory. If it is set to zero then no
> 	zone reclaim occurs. Allocations will be satisfied from other zones / nodes
> 	in the system.
> 
> 	This is value ORed together of
> 
> 	1	= Zone reclaim on
> 	2	= Zone reclaim writes dirty pages out
> 	4	= Zone reclaim swaps pages
> 
> 
> So, "(zone_reclaim_mode & RECLAIM_SWAP) == 0" mean we don't want to reclaim
> swap-backed pages. not mapped file.
> 
> Thus, may_swap is better than may_unmap.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: Rik van Riel <riel@redhat.com>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
