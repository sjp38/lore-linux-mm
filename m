Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E39CD6B0087
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 21:44:20 -0500 (EST)
Received: by iwn1 with SMTP id 1so4764723iwn.37
        for <linux-mm@kvack.org>; Thu, 09 Dec 2010 18:44:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1291893500-12342-7-git-send-email-mel@csn.ul.ie>
References: <1291893500-12342-1-git-send-email-mel@csn.ul.ie>
	<1291893500-12342-7-git-send-email-mel@csn.ul.ie>
Date: Fri, 10 Dec 2010 11:38:23 +0900
Message-ID: <AANLkTi=4sGZjUqWm4RKs6mgQVma26FeAGUK2zOPVL2oV@mail.gmail.com>
Subject: Re: [PATCH 6/6] mm: kswapd: Use the classzone idx that kswapd was
 using for sleeping_prematurely()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 9, 2010 at 8:18 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> When kswapd is woken up for a high-order allocation, it takes account of
> the highest usable zone by the caller (the classzone idx). During
> allocation, this index is used to select the lowmem_reserve[] that
> should be applied to the watermark calculation in zone_watermark_ok().
>
> When balancing a node, kswapd considers the highest unbalanced zone to be the
> classzone index. This will always be at least be the callers classzone_idx
> and can be higher. However, sleeping_prematurely() always considers the
> lowest zone (e.g. ZONE_DMA) to be the classzone index. This means that
> sleeping_prematurely() can consider a zone to be balanced that is unusable
> by the allocation request that originally woke kswapd. This patch changes
> sleeping_prematurely() to use a classzone_idx matching the value it used
> in balance_pgdat().
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Nice catch! and it does make sense to me.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
