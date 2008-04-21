From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <13567392.1208782944657.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 21 Apr 2008 22:02:24 +0900 (JST)
Subject: Re: Re: [PATCH]Fix usemap for DISCONTIG/FLATMEM with not-aligned zone initilaization.
In-Reply-To: <Pine.LNX.4.64.0804211250000.16476@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <Pine.LNX.4.64.0804211250000.16476@blonde.site>
 <20080418161522.GB9147@csn.ul.ie> <48080706.50305@cn.fujitsu.com>
 <48080930.5090905@cn.fujitsu.com> <48080B86.7040200@cn.fujitsu.com>
 <20080418211214.299f91cd.kamezawa.hiroyu@jp.fujitsu.com>
 <21878461.1208539556838.kamezawa.hiroyu@jp.fujitsu.com>
 <20080421112048.78f0ec76.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Shi Weihua <shiwh@cn.fujitsu.com>, akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

thank you for review.

>> +		z = page_zone(page);
>
>Does this have to be recalculated for every page?  The function name
>"memmap_init_zone" suggests it could be done just once (but I'm on
>unfamiliar territory here, ignore any nonsense from me).
>
you're right. I will consider this again.

>> -		if ((pfn & (pageblock_nr_pages-1)))
>> +		if ((z->zone_start_pfn < pfn)
>
>Shouldn't that be <= ?
>
yes.

>> +		    && (pfn < z->zone_start_pfn + z->spanned_pages)
>> +		    && !(pfn & (pageblock_nr_pages-1)))
>
>Ah, that line (with the ! in) makes more sense than what was there
>before; but that's an unrelated (minor) bugfix which you ought to
>mention separately in the change comment.
>
Ah, ok. I'll rewrite and post again. thank you.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
