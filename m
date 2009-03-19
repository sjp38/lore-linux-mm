Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CBA596B003D
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 11:09:17 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3555082C76D
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 11:16:14 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id BwEf5GWHm3Z8 for <linux-mm@kvack.org>;
	Thu, 19 Mar 2009 11:16:08 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1EE3182C764
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 11:16:08 -0400 (EDT)
Date: Thu, 19 Mar 2009 11:05:48 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 24/27] Convert gfp_zone() to use a table of precalculated
 values
In-Reply-To: <20090319090456.fb11e23c.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0903191105090.8100@qirst.com>
References: <1237226020-14057-1-git-send-email-mel@csn.ul.ie> <1237226020-14057-25-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0903161500280.20024@qirst.com> <20090318135222.GA4629@csn.ul.ie> <alpine.DEB.1.10.0903181011210.7901@qirst.com>
 <20090318153508.GA24462@csn.ul.ie> <alpine.DEB.1.10.0903181300540.15570@qirst.com> <20090318181717.GC24462@csn.ul.ie> <alpine.DEB.1.10.0903181507120.10154@qirst.com> <20090318194604.GD24462@csn.ul.ie>
 <20090319090456.fb11e23c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Mar 2009, KAMEZAWA Hiroyuki wrote:

> I wonder why you have to make the bad caller work insane way ?
> Is this bad ?
> ==
> const int gfp_zone_table[GFP_ZONEMASK] = {
> 	ZONE_NORMAL,		/* 00 No flags set */
> 	ZONE_DMA,		/* 01 Only GFP_DMA set */
> 	ZONE_HIGHMEM,		/* 02 Only GFP_HIGHMEM set */
> 	BAD_ZONE,		/* 03 GFP_HIGHMEM and GFP_DMA set */
> 	ZONE_DMA32,		/* 04 Only GFP_DMA32 set */
> 	BAD_ZONE,		/* 05 GFP_DMA and GFP_DMA32 set */
> 	BAD_ZONE,		/* 06 GFP_DMA32 and GFP_HIGHMEM set */
> 	BAD_ZONE,		/* 07 GFP_DMA, GFP_DMA32 and GFP_DMA32 set */
> 	ZONE_MOVABLE,		/* 08 Only ZONE_MOVABLE set */
> 	ZONE_DMA,		/* 09 MOVABLE + DMA */
> 	ZONE_MOVABLE,		/* 0A MOVABLE + HIGHMEM */
> 	BAD_ZONE,		/* 0B MOVABLE + DMA + HIGHMEM */
> 	ZONE_DMA32,		/* 0C MOVABLE + DMA32 */
> 	BAD_ZONE,		/* 0D MOVABLE + DMA + DMA32 */
> 	BAD_ZONE,		/* 0E MOVABLE + DMA32 + HIGHMEM */
> 	BAD_ZONE		/* 0F MOVABLE + DMA32 + HIGHMEM + DMA
> };
> ==

It would work if we could check for BAD_ZONE with a VM_BUG_ON or a
BUILD_BUG_ON. If I get some time I will look into this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
