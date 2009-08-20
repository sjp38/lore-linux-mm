Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A0B086B004F
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 20:29:32 -0400 (EDT)
Message-ID: <4A8C98DD.9030500@redhat.com>
Date: Wed, 19 Aug 2009 20:29:17 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Fix to infinite churning of mlocked page
References: <20090820085544.faed1ca4.minchan.kim@barrios-desktop>
In-Reply-To: <20090820085544.faed1ca4.minchan.kim@barrios-desktop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Minchan Kim wrote:
> Mlocked page might lost the isolatation race.
> It cause the page to clear PG_mlocked while it remains
> in VM_LOCKED vma. It means it can be put [in]active list.
> We can rescue it by try_to_unmap in shrink_page_list.
> 
> But now, As Wu Fengguang pointed out, vmscan have a bug.
> If the page has PG_referenced, it can't reach try_to_unmap
> in shrink_page_list but put into active list. If the page
> is referenced repeatedly, it can remain [in]active list
> without moving unevictable list.
> 
> This patch can fix it.
> 
> Reported-by: Wu Fengguang <fengguang.wu@intel.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Cc: KOSAKI Motohiro <<kosaki.motohiro@jp.fujitsu.com>
> Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
> Cc: Rik van Riel <riel@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
