Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 37FDE9000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 13:01:25 -0400 (EDT)
Date: Mon, 20 Jun 2011 18:01:07 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/3] mm: print information when THP is disabled
 automatically
Message-ID: <20110620170106.GC9396@suse.de>
References: <1308587683-2555-1-git-send-email-amwang@redhat.com>
 <1308587683-2555-3-git-send-email-amwang@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1308587683-2555-3-git-send-email-amwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Tue, Jun 21, 2011 at 12:34:30AM +0800, Amerigo Wang wrote:
> Print information when THP is disabled automatically so that
> users can find this info in dmesg.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>
> ---
>  mm/huge_memory.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 7fb44cc..07679da 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -544,8 +544,11 @@ static int __init hugepage_init(void)
>  	 * where the extra memory used could hurt more than TLB overhead
>  	 * is likely to save.  The admin can still enable it through /sys.
>  	 */
> -	if (totalram_pages < (CONFIG_TRANSPARENT_HUGEPAGE_THRESHOLD << (20 - PAGE_SHIFT)))
> +	if (totalram_pages < (CONFIG_TRANSPARENT_HUGEPAGE_THRESHOLD
> +					<< (20 - PAGE_SHIFT))) {
> +		printk(KERN_INFO "hugepage: disabled auotmatically\n");
>  		transparent_hugepage_flags = 0;
> +	}
>  
>  	start_khugepaged();
>  

Guess this doesn't hurt. You misspelled automatically though and
mentioning "hugepage" could be confused with hugetlbfs.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
