Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 656E96B005D
	for <linux-mm@kvack.org>; Mon, 18 May 2009 05:09:59 -0400 (EDT)
Date: Mon, 18 May 2009 17:09:50 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/4] zone_reclaim_mode is always 0 by default
Message-ID: <20090518090950.GA10439@localhost>
References: <20090513120155.5879.A69D9226@jp.fujitsu.com> <20090513120729.5885.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090513120729.5885.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 13, 2009 at 12:08:12PM +0900, KOSAKI Motohiro wrote:
> Index: b/mm/page_alloc.c
> ===================================================================
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2494,13 +2494,6 @@ static void build_zonelists(pg_data_t *p
>  		int distance = node_distance(local_node, node);
>  
>  		/*
> -		 * If another node is sufficiently far away then it is better
> -		 * to reclaim pages in a zone before going off node.
> -		 */
> -		if (distance > RECLAIM_DISTANCE)
> -			zone_reclaim_mode = 1;
> -

Also remove the RECLAIM_DISTANCE definitions in
include/linux/topology.h and arch/ia64/include/asm/topology.h?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
