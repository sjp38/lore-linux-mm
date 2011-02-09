Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A9EAB8D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 19:04:32 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 129113EE0BB
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 09:04:31 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E7F1445DE5A
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 09:04:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C15D145DE53
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 09:04:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A78AEEF800A
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 09:04:30 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 70EA5EF8005
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 09:04:30 +0900 (JST)
Date: Thu, 10 Feb 2011 08:58:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: Fix out-of-date comments which refers non-existent
 functions
Message-Id: <20110210085823.2f99b81c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1297262537-7425-1-git-send-email-ozaki.ryota@gmail.com>
References: <1297262537-7425-1-git-send-email-ozaki.ryota@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ryota Ozaki <ozaki.ryota@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

On Wed,  9 Feb 2011 23:42:17 +0900
Ryota Ozaki <ozaki.ryota@gmail.com> wrote:

> From: Ryota Ozaki <ozaki.ryota@gmail.com>
> 
> do_file_page and do_no_page don't exist anymore, but some comments
> still refers them. The patch fixes them by replacing them with
> existing ones.
> 
> Signed-off-by: Ryota Ozaki <ozaki.ryota@gmail.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

It seems there are other ones ;)
==
    Searched full:do_no_page (Results 1 - 3 of 3) sorted by relevancy

  /linux-2.6-git/arch/alpha/include/asm/
H A D	cacheflush.h 	66 /* This is used only in do_no_page and do_swap_page. */
  /linux-2.6-git/arch/avr32/mm/
H A D	cache.c 	116 * This one is called from do_no_page(), do_swap_page() and install_page().
  /linux-2.6-git/mm/
H A D	memory.c 	2121 * and do_anonymous_page and do_no_page can safely check later on).
2319 * do_no_page is protected similarly.





> ---
>  mm/memory.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> I'm not familiar with the codes very much, so the fix may be wrong.
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 31250fa..3fbf32a 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2115,10 +2115,10 @@ EXPORT_SYMBOL_GPL(apply_to_page_range);
>   * handle_pte_fault chooses page fault handler according to an entry
>   * which was read non-atomically.  Before making any commitment, on
>   * those architectures or configurations (e.g. i386 with PAE) which
> - * might give a mix of unmatched parts, do_swap_page and do_file_page
> + * might give a mix of unmatched parts, do_swap_page and do_nonlinear_fault
>   * must check under lock before unmapping the pte and proceeding
>   * (but do_wp_page is only called after already making such a check;
> - * and do_anonymous_page and do_no_page can safely check later on).
> + * and do_anonymous_page can safely check later on).
>   */
>  static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
>  				pte_t *page_table, pte_t orig_pte)
> @@ -2316,7 +2316,7 @@ reuse:
>  		 * bit after it clear all dirty ptes, but before a racing
>  		 * do_wp_page installs a dirty pte.
>  		 *
> -		 * do_no_page is protected similarly.
> +		 * __do_fault is protected similarly.
>  		 */
>  		if (!page_mkwrite) {
>  			wait_on_page_locked(dirty_page);
> -- 
> 1.7.2.3
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
