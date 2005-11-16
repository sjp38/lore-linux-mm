Message-ID: <437A9AE5.8070001@jp.fujitsu.com>
Date: Wed, 16 Nov 2005 11:35:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] Light Fragmentation Avoidance V20: 003_fragcore
References: <20051115164946.21980.2026.sendpatchset@skynet.csn.ul.ie> <20051115165002.21980.14423.sendpatchset@skynet.csn.ul.ie>
In-Reply-To: <20051115165002.21980.14423.sendpatchset@skynet.csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, mingo@elte.hu, linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Hi,

> +/* Remove an element from the buddy allocator from the fallback list */
> +static struct page *__rmqueue_fallback(struct zone *zone, int order,
> +							int alloctype)

Should we avoid this fallback as much as possible ?
I think this is a weak point of this approach.


> +		/*
> +		 * If breaking a large block of pages, place the buddies
> +		 * on the preferred allocation list
> +		 */
> +		if (unlikely(current_order >= MAX_ORDER / 2)) {
> +			alloctype = !alloctype;
> +			change_pageblock_type(zone, page);
> +			area = &zone->free_area_lists[alloctype][current_order];
> +		}
Changing RCLM_NORCLM to RLCM_EASY is okay ??
If so, I think adding similar code to free_pages_bulk() is better.

-- Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
