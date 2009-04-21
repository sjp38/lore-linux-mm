Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A18126B0055
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 05:55:13 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3L9u3md017815
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 21 Apr 2009 18:56:03 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CAC845DE58
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:56:03 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BDCE45DE54
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:56:03 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 11F12E08008
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:56:03 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C4A61E08007
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:56:01 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 14/25] Inline buffered_rmqueue()
In-Reply-To: <1240266011-11140-15-git-send-email-mel@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-15-git-send-email-mel@csn.ul.ie>
Message-Id: <20090421185442.F159.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Apr 2009 18:56:00 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> buffered_rmqueue() is in the fast path so inline it. Because it only has
> one call site, this actually should reduce text bloat instead of
> increase it.

nit: please append size command output.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/page_alloc.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 91a2cdb..2dfe3aa 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1077,7 +1077,8 @@ void split_page(struct page *page, unsigned int order)
>   * we cheat by calling it from here, in the order > 0 path.  Saves a branch
>   * or two.
>   */
> -static struct page *buffered_rmqueue(struct zone *preferred_zone,
> +static inline
> +struct page *buffered_rmqueue(struct zone *preferred_zone,
>  			struct zone *zone, int order, gfp_t gfp_flags,
>  			int migratetype, int cold)
>  {
> -- 
> 1.5.6.5
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
