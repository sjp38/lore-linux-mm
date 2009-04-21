Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4F9666B0055
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 05:56:00 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3L9upAs018150
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 21 Apr 2009 18:56:51 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 01DA945DD7A
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:56:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C852345DD77
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:56:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DDF9E08005
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:56:50 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 402CEE08008
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:56:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 15/25] Inline __rmqueue_fallback()
In-Reply-To: <1240266011-11140-16-git-send-email-mel@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-16-git-send-email-mel@csn.ul.ie>
Message-Id: <20090421185626.F15C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Apr 2009 18:56:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> __rmqueue_fallback() is in the slow path but has only one call site. It
> actually reduces text if it's inlined.

ditto. I hope to write size command output.


> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/page_alloc.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2dfe3aa..83da463 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -775,8 +775,8 @@ static int move_freepages_block(struct zone *zone, struct page *page,
>  }
>  
>  /* Remove an element from the buddy allocator from the fallback list */
> -static struct page *__rmqueue_fallback(struct zone *zone, int order,
> -						int start_migratetype)
> +static inline struct page *
> +__rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
>  {
>  	struct free_area * area;
>  	int current_order;
> -- 
> 1.5.6.5
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
