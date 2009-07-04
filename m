Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B8D326B004F
	for <linux-mm@kvack.org>; Sat,  4 Jul 2009 09:26:39 -0400 (EDT)
Message-ID: <4A4F5D4F.5000104@redhat.com>
Date: Sat, 04 Jul 2009 09:46:55 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH][mmotm] don't attempt to reclaim anon page in lumpy reclaim
 when no swap space is available
References: <20090704141818.0afa877a.minchan.kim@gmail.com>
In-Reply-To: <20090704141818.0afa877a.minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Minchan Kim wrote:

> VM already avoids attempting to reclaim anon pages in various places, But
> it doesn't avoid it for lumpy reclaim.
> 
> It shuffles lru list unnecessary so that it is pointless.
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
