Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 176B46B003D
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 18:53:27 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2MNk9qX008207
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 23 Mar 2009 08:46:09 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B8F8045DE55
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 08:46:08 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DDEB45DE52
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 08:46:08 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 756EE1DB8016
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 08:46:08 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DE021DB8014
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 08:46:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 1/3] mm: decouple unevictable lru from mmu
In-Reply-To: <1237752784-1989-1-git-send-email-hannes@cmpxchg.org>
References: <20090321102044.GA3427@cmpxchg.org> <1237752784-1989-1-git-send-email-hannes@cmpxchg.org>
Message-Id: <20090323084423.490C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 23 Mar 2009 08:46:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Howells <dhowells@redhat.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.com>, MinChan Kim <minchan.kim@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

> @@ -206,7 +206,6 @@ config VIRT_TO_BUS
>  config UNEVICTABLE_LRU
>  	bool "Add LRU list to track non-evictable pages"
>  	default y
> -	depends on MMU
>  	help
>  	  Keeps unevictable pages off of the active and inactive pageout
>  	  lists, so kswapd will not waste CPU time or have its balancing
> diff --git a/mm/internal.h b/mm/internal.h
> index 478223b..ceaa629 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h

David alread made this portion and it already merged in mmotm.
Don't you work on mmotm?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
