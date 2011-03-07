Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6614F8D003E
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 03:37:10 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 25A903EE0AE
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:37:07 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E6DA45DE61
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:37:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E5CC945DE4D
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:37:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D96E2E08001
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:37:06 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A4A571DB802C
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 17:37:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/8] Add alloc_page_vma_node
In-Reply-To: <1299182391-6061-4-git-send-email-andi@firstfloor.org>
References: <1299182391-6061-1-git-send-email-andi@firstfloor.org> <1299182391-6061-4-git-send-email-andi@firstfloor.org>
Message-Id: <20110307173659.8A0A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  7 Mar 2011 17:37:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

> From: Andi Kleen <ak@linux.intel.com>
> 
> Add a alloc_page_vma_node that allows passing the "local" node in.
> Used in a followon patch.
> 
> Acked-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/gfp.h |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 782e74a..814d50e 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -343,6 +343,8 @@ extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
>  #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
>  #define alloc_page_vma(gfp_mask, vma, addr)			\
>  	alloc_pages_vma(gfp_mask, 0, vma, addr, numa_node_id())
> +#define alloc_page_vma_node(gfp_mask, vma, addr, node)		\
> +	alloc_pages_vma(gfp_mask, 0, vma, addr, node)
>  
>  extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
>  extern unsigned long get_zeroed_page(gfp_t gfp_mask);

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
