Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 79E336B0093
	for <linux-mm@kvack.org>; Wed, 27 May 2009 01:30:09 -0400 (EDT)
Date: Tue, 26 May 2009 22:30:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] add inactive ratio calculation function of each
 zone V2
Message-Id: <20090526223002.f283bcd2.akpm@linux-foundation.org>
In-Reply-To: <20090521092321.ee57585e.minchan.kim@barrios-desktop>
References: <20090521092321.ee57585e.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 21 May 2009 09:23:21 +0900 Minchan Kim <minchan.kim@gmail.com> wrote:

> Changelog since V1 
>  o Change function name from calculate_zone_inactive_ratio to calculate_inactive_ratio
>    - by Mel Gorman advise
>  o Modify tab indent - by Mel Gorman advise

The first two patches still had various trivial whitespace bustages. 
You don't need Mel to find these things when we have the very nice
scripts/checkpatch.pl.  Please incorporate that script into your patch
preparation tools

> This patch devide setup_per_zone_inactive_ratio with
> per-zone inactive ratio calculaton.

The above sentence appears to be the changelog for this patch but it
doesn't make a lot of sense.

afaict the changelog should be:

"factor the per-zone arithemetic inside
setup_per_zone_inactive_ratio()'s loop into a a separate function,
calculate_zone_inactive_ratio().  This function will be used in a later
patch".

yes?


> This patch is just for helping my next patch.
> (reset wmark_min and inactive ratio of zone when hotplug happens)
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Rik van Riel <riel@redhat.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
