Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 28B4F6B0078
	for <linux-mm@kvack.org>; Sun, 10 Jan 2010 22:47:02 -0500 (EST)
Message-ID: <4B4A9F12.8020200@redhat.com>
Date: Sun, 10 Jan 2010 22:46:26 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 -mmotm-2010-01-06-14-34] check high watermark after
 shrink zone
References: <20100111084816.81bc7ebd.minchan.kim@barrios-desktop>
In-Reply-To: <20100111084816.81bc7ebd.minchan.kim@barrios-desktop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On 01/10/2010 06:48 PM, Minchan Kim wrote:
>
>
>   * V2
>    * Add reviewed-by singed-off (Thanks Kosaki, Wu)
>    * Fix typo of changelog
>
> == CUT HERE ==
>
> Kswapd check that zone have enough free by zone_water_mark.
> If any zone doesn't have enough page, it set all_zones_ok to zero.
> !all_zone_ok makes kswapd retry not sleeping.
>
> I think the watermark check before shrink zone is pointless.
> Kswapd try to shrink zone then the check is meaninful.
>
> This patch move the check after shrink zone.
>
> Signed-off-by: Minchan Kim<minchan.kim@gmail.com>
> Reviewed-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: Wu Fengguang<fengguang.wu@intel.com>
> CC: Mel Gorman<mel@csn.ul.ie>
> CC: Rik van Riel<riel@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
