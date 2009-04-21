Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 335616B0055
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 05:51:46 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3L9qXlI024092
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 21 Apr 2009 18:52:33 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F0A3C45DD7B
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:52:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D345845DD78
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:52:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B74561DB8037
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:52:32 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 38170E08005
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:52:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 13/25] Inline __rmqueue_smallest()
In-Reply-To: <1240266011-11140-14-git-send-email-mel@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-14-git-send-email-mel@csn.ul.ie>
Message-Id: <20090421185025.F156.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Apr 2009 18:52:28 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> Inline __rmqueue_smallest by altering flow very slightly so that there
> is only one call site. This allows the function to be inlined without
> additional text bloat.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
> ---
>  mm/page_alloc.c |   23 ++++++++++++++++++-----
>  1 files changed, 18 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index b13fc29..91a2cdb 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -665,7 +665,8 @@ static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
>   * Go through the free lists for the given migratetype and remove
>   * the smallest available page from the freelists
>   */
> -static struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
> +static inline
> +struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
>  						int migratetype)

"only one caller" is one of keypoint of this patch, I think.
so, commenting is better? but it isn't blocking reason at all.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
