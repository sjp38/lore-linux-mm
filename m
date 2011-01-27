Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3B9CF8D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 15:33:50 -0500 (EST)
Message-ID: <4D41D690.2000705@redhat.com>
Date: Thu, 27 Jan 2011 15:33:20 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: too big min_free_kbytes
References: <1295841406.1949.953.camel@sli10-conroe> <20110124150033.GB9506@random.random> <20110126141746.GS18984@csn.ul.ie> <20110126152302.GT18984@csn.ul.ie> <20110126154203.GS926@random.random> <20110126163655.GU18984@csn.ul.ie> <20110126174236.GV18984@csn.ul.ie> <20110127134057.GA32039@csn.ul.ie> <20110127152755.GB30919@random.random> <20110127160301.GA29291@csn.ul.ie> <20110127185215.GE16981@random.random>
In-Reply-To: <20110127185215.GE16981@random.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

On 01/27/2011 01:52 PM, Andrea Arcangeli wrote:

>   			if (!zone_watermark_ok_safe(zone, order,
> -					8*high_wmark_pages(zone), end_zone, 0))
> +					(zone->present_pages +
> +					 KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
> +					 KSWAPD_ZONE_BALANCE_GAP_RATIO +
> +					high_wmark_pages(zone), end_zone, 0))
>   				shrink_zone(priority, zone,&sc);

Isn't (zone->present_pages + 99) / 100 + high_wmark_pages(zone)
pretty much guaranteed to be significantly larger than the 8
times the high watermark we had before?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
