Message-ID: <44685FC1.2040505@shadowen.org>
Date: Mon, 15 May 2006 12:02:25 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH 5/6] Have ia64 use add_active_range() and free_area_init_nodes
References: <20060508141030.26912.93090.sendpatchset@skynet>	<20060508141211.26912.48278.sendpatchset@skynet>	<20060514203158.216a966e.akpm@osdl.org>	<44683A09.2060404@shadowen.org>	<44685123.7040501@yahoo.com.au>	<446855AF.1090100@shadowen.org> <20060515192918.c3e2e895.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060515192918.c3e2e895.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nickpiggin@yahoo.com.au, akpm@osdl.org, mel@csn.ul.ie, davej@codemonkey.org.uk, tony.luck@intel.com, linux-kernel@vger.kernel.org, bob.picco@hp.com, ak@suse.de, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Mon, 15 May 2006 11:19:27 +0100
> Andy Whitcroft <apw@shadowen.org> wrote:
> 
> 
>>Nick Piggin wrote:
>>
>>>Andy Whitcroft wrote:
>>>
>>>
>>>>Interesting.  You are correct there was no config component, at the time
>>>>I didn't have direct evidence that any architecture needed it, only that
>>>>we had an unchecked requirement on zones, a requirement that had only
>>>>recently arrived with the changes to free buddy detection.  I note that
>>>
>>>
>>>Recently arrived? Over a year ago with the no-buddy-bitmap patches,
>>>right? Just checking because I that's what I'm assuming broke it...
>>
>>Yep, sorry I forget I was out of the game for 6 months!  And yes that
>>was when the requirements were altered.
>>
> 
> When no-bitmap-buddy patches was included,
> 
> 1. bad_range() is not covered by CONFIG_VM_DEBUG. It always worked.
> ==
> static int bad_range(struct zone *zone, struct page *page)
> {
>         if (page_to_pfn(page) >= zone->zone_start_pfn + zone->spanned_pages)
>                 return 1;
>         if (page_to_pfn(page) < zone->zone_start_pfn)
>                 return 1;
> ==
> And , this code
> ==
>                 buddy = __page_find_buddy(page, page_idx, order);
> 
>                 if (bad_range(zone, buddy))
>                         break;
> ==
> 
> checked whether buddy is in zone and guarantees it to have page struct.
> 
> 
> But clean-up/speed-up codes vanished these checks. (I don't know when this occurs)
> Sorry for misses these things.

Heh, sorry to make it sound like it was you who was responsible.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
