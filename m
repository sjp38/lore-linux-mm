Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6D1E98D003B
	for <linux-mm@kvack.org>; Sun, 24 Apr 2011 01:37:14 -0400 (EDT)
Received: by iyh42 with SMTP id 42so1845796iyh.14
        for <linux-mm@kvack.org>; Sat, 23 Apr 2011 22:37:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1303604751-4980-1-git-send-email-minchan.kim@gmail.com>
References: <1303604751-4980-1-git-send-email-minchan.kim@gmail.com>
Date: Sun, 24 Apr 2011 14:37:12 +0900
Message-ID: <BANLkTinW7+14b-DSK80-3ujdgVjTbZ4KCQ@mail.gmail.com>
Subject: Re: [PATCH] Check PageActive when evictable page and unevicetable
 page race happen
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>

On Sun, Apr 24, 2011 at 9:25 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> In putback_lru_page, unevictable page can be changed into evictable
> 's one while we move it among lru. So we have checked it again and
> rescued it. But we don't check PageActive, again. It could add
> active page into inactive list so we can see the BUG in isolate_lru_pages.
> (But I didn't see any report because I think it's very subtle)
>
> It could happen in race that zap_pte_range's mark_page_accessed and
> putback_lru_page. It's subtle but could be possible.

Please Ignore this. I was confused.
The race never happens.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
