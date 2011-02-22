Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CB1F38D0039
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 19:31:47 -0500 (EST)
Date: Tue, 22 Feb 2011 09:30:22 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] hugetlbfs: correct handling of negative input to
 /proc/sys/vm/nr_hugepages
Message-ID: <20110222003022.GA2895@spritzera.linux.bs1.fc.nec.co.jp>
References: <1298303270-3184-1-git-send-email-pholasek@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <1298303270-3184-1-git-send-email-pholasek@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org

On Mon, Feb 21, 2011 at 04:47:49PM +0100, Petr Holasek wrote:
> When user insert negative value into /proc/sys/vm/nr_hugepages it will result
> in the setting a random number of HugePages in system (can be easily showed
> at /proc/meminfo output). This patch fixes the wrong behavior so that the
> negative input will result in nr_hugepages value unchanged.
> 
> Signed-off-by: Petr Holasek <pholasek@redhat.com>
> ---
>  mm/hugetlb.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index bb0b7c1..f99d7a8 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1872,8 +1872,7 @@ static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
>  	unsigned long tmp;
>  	int ret;
>  
> -	if (!write)
> -		tmp = h->max_huge_pages;
> +	tmp = h->max_huge_pages;

Looks reasonable.
hugetlb_overcommit_handler() has the same wrong behavior.
So how about fixing that too?

Anyway,
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
