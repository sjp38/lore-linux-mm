Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C45C28D003B
	for <linux-mm@kvack.org>; Sat, 23 Apr 2011 22:01:34 -0400 (EDT)
Received: by pzk32 with SMTP id 32so1138611pzk.14
        for <linux-mm@kvack.org>; Sat, 23 Apr 2011 19:01:33 -0700 (PDT)
Date: Sun, 24 Apr 2011 11:01:22 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] Check PageActive when evictable page and unevicetable
 page race happen
Message-ID: <20110424020122.GA6228@barrios-desktop>
References: <1303604751-4980-1-git-send-email-minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1303604751-4980-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>

On Sun, Apr 24, 2011 at 09:25:51AM +0900, Minchan Kim wrote:
> In putback_lru_page, unevictable page can be changed into evictable
> 's one while we move it among lru. So we have checked it again and
> rescued it. But we don't check PageActive, again. It could add
> active page into inactive list so we can see the BUG in isolate_lru_pages.
> (But I didn't see any report because I think it's very subtle)

As I look the code further, that's because lru_cache_add_lru always 
cleans up PageActive regardless of LRU list. 
If active page goes to inactive list, we shouldn't meet the BUG 
but it's apparently wrong. 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
