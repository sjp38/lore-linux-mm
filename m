Subject: Re: [Lhms-devel] [RFC]  free_area[]  bitmap elimination [0/3]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <4126B3F9.90706@jp.fujitsu.com>
References: <4126B3F9.90706@jp.fujitsu.com>
Content-Type: text/plain
Message-Id: <1093275800.3153.825.camel@nighthawk>
Mime-Version: 1.0
Date: Mon, 23 Aug 2004 08:43:21 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

A few tiny, cosmetic comments on the patch itself:

>  }
>  
> +
> +
> +
>  #endif         /* CONFIG_HUGETLB_PAGE */
>  

Be careful about adding whitespace like that

>  /*
> + *     indicates page's order in freelist
> + *      order is recorded in inveterd manner.
> + */

The comments around there tend to use a space instead of a tab in
comments like this:
/*
 * foo
 */

patch 2:
>                 area = zone->free_area + current_order;
>                 if (list_empty(&area->free_list))
>                         continue;
> -
>                 page = list_entry(area->free_list.next, struct page, lru);
>                 list_del(&page->lru);

More whitespace .

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
