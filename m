Subject: Re: [RFC] buddy allocator without bitmap [3/4]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <412DD34A.70802@jp.fujitsu.com>
References: <412DD34A.70802@jp.fujitsu.com>
Content-Type: text/plain
Message-Id: <1093535709.2984.24.camel@nighthawk>
Mime-Version: 1.0
Date: Thu, 26 Aug 2004 08:55:09 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

> +                       if (zone->nr_mem_map > 1) {
> +                               /*
> +                                * there may be hole in zone's memmap &&
> +                                * hole is not aligned in this order.
> +                                * currently, I think CONFIG_VIRTUAL_MEM_MAP
> +                                * case is only case to reach here.
> +                                * Is there any other case ?
> +                                */
> +                               /*
> +                                * Is there better call than pfn_valid ?
> +                                */
> +                               if (!pfn_valid(zone->zone_start_pfn
> +                                              + (page_idx ^ (1 << order))))
> +                                       break;
> +                       }

Nice try.  How about putting the ia64 code in a macro or header function
that you can #ifdef out on all the other architectures?  We used to be
able to see that entire while loop on one screen.  That's a bit harder
now.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
