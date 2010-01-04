Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1496D6005A4
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 16:02:34 -0500 (EST)
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id o04L2VEd010685
	for <linux-mm@kvack.org>; Mon, 4 Jan 2010 13:02:31 -0800
Received: from fxm28 (fxm28.prod.google.com [10.184.13.28])
	by spaceape9.eur.corp.google.com with ESMTP id o04L2QTe021163
	for <linux-mm@kvack.org>; Mon, 4 Jan 2010 13:02:30 -0800
Received: by fxm28 with SMTP id 28so6801559fxm.26
        for <linux-mm@kvack.org>; Mon, 04 Jan 2010 13:02:26 -0800 (PST)
Date: Mon, 4 Jan 2010 13:02:17 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/page_alloc: fix the range check for backward
 merging
In-Reply-To: <20100103120435.GA3576@epsilou.com>
Message-ID: <alpine.DEB.2.00.1001041302130.20593@chino.kir.corp.google.com>
References: <20100103120435.GA3576@epsilou.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Kazuhisa Ichikawa <ki@epsilou.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 3 Jan 2010, Kazuhisa Ichikawa wrote:

> From: Kazuhisa Ichikawa <ki@epsilou.com>
> 
> The current check for 'backward merging' within add_active_range()
> does not seem correct.  start_pfn must be compared against
> early_node_map[i].start_pfn (and NOT against .end_pfn) to find out
> whether the new region is backward-mergeable with the existing range.
> 
> Signed-off-by: Kazuhisa Ichikawa <ki@epsilou.com>
> ---
>  (This patch applies to linux-2.6.33-rc2)
> 
> --- a/mm/page_alloc.c	2009-12-25 06:09:41.000000000 +0900
> +++ b/mm/page_alloc.c	2010-01-03 19:20:36.000000000 +0900
> @@ -3998,7 +3998,7 @@ void __init add_active_range(unsigned in
>  		}
>  
>  		/* Merge backward if suitable */
> -		if (start_pfn < early_node_map[i].end_pfn &&
> +		if (start_pfn < early_node_map[i].start_pfn &&
>  				end_pfn >= early_node_map[i].start_pfn) {
>  			early_node_map[i].start_pfn = start_pfn;
>  			return;

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
