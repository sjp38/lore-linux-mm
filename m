Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B7E1C6B006A
	for <linux-mm@kvack.org>; Sun, 10 Jan 2010 09:26:31 -0500 (EST)
Date: Sun, 10 Jan 2010 22:25:49 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH -mmotm-2010-01-06-14-34] check high watermark after
	shrink zone
Message-ID: <20100110142549.GA14610@localhost>
References: <20100108141235.ef56b567.minchan.kim@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100108141235.ef56b567.minchan.kim@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 08, 2010 at 02:12:35PM +0900, Minchan Kim wrote:
> Kswapd check that zone have enough free by zone_water_mark.
> If any zone doesn't have enough page, it set all_zones_ok to zero.

> all_zone_ok makes kswapd retry not sleeping.

!all_zone_ok :)

> I think the watermark check before shrink zone is pointless.
> Kswapd try to shrink zone then the check is meaningul.
> 
> This patch move the check after shrink zone.

This tends to make kswapd do less work in one invocation, with lower
priority.  Looks at least not bad to me :) Thanks!

Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
