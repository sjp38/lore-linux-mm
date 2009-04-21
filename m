Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1B6756B0055
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 21:43:42 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3L1iLNT012843
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 21 Apr 2009 10:44:21 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4ECA245DE50
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 10:44:20 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 286FE45DD72
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 10:44:20 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1513EE1800A
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 10:44:20 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 43F4F1DB8041
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 10:44:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 01/25] Replace __alloc_pages_internal() with __alloc_pages_nodemask()
In-Reply-To: <1240266011-11140-2-git-send-email-mel@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-2-git-send-email-mel@csn.ul.ie>
Message-Id: <20090421104346.F119.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Apr 2009 10:44:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


>  include/linux/gfp.h |   12 ++----------
>  mm/page_alloc.c     |    4 ++--
>  2 files changed, 4 insertions(+), 12 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 0bbc15f..556c840 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -169,24 +169,16 @@ static inline void arch_alloc_page(struct page *page, int order) { }
>  #endif
>  
>  struct page *
> -__alloc_pages_internal(gfp_t gfp_mask, unsigned int order,
> +__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  		       struct zonelist *zonelist, nodemask_t *nodemask);
>  
>  static inline struct page *
>  __alloc_pages(gfp_t gfp_mask, unsigned int order,
>  		struct zonelist *zonelist)
>  {
> -	return __alloc_pages_internal(gfp_mask, order, zonelist, NULL);
> +	return __alloc_pages_nodemask(gfp_mask, order, zonelist, NULL);
>  }
>  
> -static inline struct page *
> -__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
> -		struct zonelist *zonelist, nodemask_t *nodemask)
> -{
> -	return __alloc_pages_internal(gfp_mask, order, zonelist, nodemask);
> -}
> -
> -
>  static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
>  						unsigned int order)
>  {
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index e4ea469..dcc4f05 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1462,7 +1462,7 @@ try_next_zone:
>   * This is the 'heart' of the zoned buddy allocator.
>   */
>  struct page *
> -__alloc_pages_internal(gfp_t gfp_mask, unsigned int order,
> +__alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  			struct zonelist *zonelist, nodemask_t *nodemask)
>  {

sorry, late review.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
