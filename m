Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CE9746B008C
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 11:03:44 -0500 (EST)
Received: by iwn1 with SMTP id 1so3893128iwn.37
        for <linux-mm@kvack.org>; Thu, 09 Dec 2010 08:03:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101209155925.GD1740@barrios-desktop>
References: <1291893500-12342-1-git-send-email-mel@csn.ul.ie>
	<1291893500-12342-5-git-send-email-mel@csn.ul.ie>
	<20101209155925.GD1740@barrios-desktop>
Date: Fri, 10 Dec 2010 01:03:01 +0900
Message-ID: <AANLkTimKVZjfVtZ_Rz0p0xKbE76Uoa1rDrYmN9EC4wLU@mail.gmail.com>
Subject: Re: [PATCH 4/6] mm: kswapd: Reset kswapd_max_order and classzone_idx
 after reading
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 10, 2010 at 12:59 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Thu, Dec 09, 2010 at 11:18:18AM +0000, Mel Gorman wrote:
>> When kswapd wakes up, it reads its order and classzone from pgdat and
>> calls balance_pgdat. While its awake, it potentially reclaimes at a high
>> order and a low classzone index. This might have been a once-off that
>> was not required by subsequent callers. However, because the pgdat
>> values were not reset, they remain artifically high while
>> balance_pgdat() is running and potentially kswapd enters a second
>> unnecessary reclaim cycle. Reset the pgdat order and classzone index
>> after reading.
>>
>> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Nitpick.
Shouldn't this patch be merged with 1/6?

>
> --
> Kind regards,
> Minchan Kim
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
