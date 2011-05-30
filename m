Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 174556B0012
	for <linux-mm@kvack.org>; Sun, 29 May 2011 21:48:02 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3C2B33EE0BB
	for <linux-mm@kvack.org>; Mon, 30 May 2011 10:47:58 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 227F745DE99
	for <linux-mm@kvack.org>; Mon, 30 May 2011 10:47:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B25D45DE73
	for <linux-mm@kvack.org>; Mon, 30 May 2011 10:47:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F33B91DB8037
	for <linux-mm@kvack.org>; Mon, 30 May 2011 10:47:57 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C15A81DB802F
	for <linux-mm@kvack.org>; Mon, 30 May 2011 10:47:57 +0900 (JST)
Message-ID: <4DE2F741.7060109@jp.fujitsu.com>
Date: Mon, 30 May 2011 10:47:45 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 00/10] Prevent LRU churning
References: <cover.1306689214.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1306689214.git.minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan.kim@gmail.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mgorman@suse.de, riel@redhat.com, aarcange@redhat.com, hannes@cmpxchg.org

> Minchan Kim (10):
>   [1/10] Make clear description of isolate/putback functions
>   [2/10] compaction: trivial clean up acct_isolated
>   [3/10] Change int mode for isolate mode with enum ISOLATE_PAGE_MODE
>   [4/10] Add additional isolation mode
>   [5/10] compaction: make isolate_lru_page with filter aware
>   [6/10] vmscan: make isolate_lru_page with filter aware
>   [7/10] In order putback lru core
>   [8/10] migration: make in-order-putback aware
>   [9/10] compaction: make compaction use in-order putback
>   [10/10] add tracepoints

Minchan,

I'm sorry I have no chance to review this patch in this week. I'm getting
stuck for LinuxCon. ;)
That doesn't mean I dislike this series.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
