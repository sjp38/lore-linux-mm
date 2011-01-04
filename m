Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D4F6A6B00C1
	for <linux-mm@kvack.org>; Mon,  3 Jan 2011 20:51:07 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 30AE53EE0BB
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 10:51:05 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1403E45DE51
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 10:51:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F0BF745DE4D
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 10:51:04 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E4AE8EF8002
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 10:51:04 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B29F51DB8037
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 10:51:04 +0900 (JST)
Date: Tue, 4 Jan 2011 10:45:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2 7/7] Change __remove_from_page_cache
Message-Id: <20110104104517.e55410b4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <593ce6375438dfa3299ccbc5011a8dfc983340fb.1293982522.git.minchan.kim@gmail.com>
References: <cover.1293982522.git.minchan.kim@gmail.com>
	<593ce6375438dfa3299ccbc5011a8dfc983340fb.1293982522.git.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon,  3 Jan 2011 00:44:36 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Now we renamed remove_from_page_cache with delete_from_page_cache.
> As consistency of __remove_from_swap_cache and remove_from_swap_cache,
> We change internal page cache handling function name, too.
> 
> Cc: Christoph Hellwig <hch@infradead.org>
> Acked-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
