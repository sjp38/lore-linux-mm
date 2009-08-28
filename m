Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D46226B004D
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 18:38:15 -0400 (EDT)
Received: by ywh42 with SMTP id 42so3080248ywh.30
        for <linux-mm@kvack.org>; Fri, 28 Aug 2009 15:38:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0908282034240.19475@sister.anvils>
References: <Pine.LNX.4.64.0908282034240.19475@sister.anvils>
Date: Sat, 29 Aug 2009 07:38:17 +0900
Message-ID: <28c262360908281538q305db3bat51b4382defd1bf3f@mail.gmail.com>
Subject: Re: [PATCH mmotm] vmscan move pgdeactivate modification to
	shrink_active_list fix
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 29, 2009 at 4:39 AM, Hugh Dickins<hugh.dickins@tiscali.co.uk> wrote:
> mmotm 2009-08-27-16-51 lets the OOM killer loose on my loads even
> quicker than last time: one bug fixed but another bug introduced.
> vmscan-move-pgdeactivate-modification-to-shrink_active_list.patch
> forgot to add NR_LRU_BASE to lru index to make zone_page_state index.
>
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
