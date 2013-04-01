Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 5415A6B0006
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 10:24:20 -0400 (EDT)
Message-ID: <5159988E.60104@redhat.com>
Date: Mon, 01 Apr 2013 10:24:14 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch]THP: add split tail pages to shrink page list in page
 reclaim
References: <20130401132605.GA2996@kernel.org>
In-Reply-To: <20130401132605.GA2996@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, aarcange@redhat.com, minchan@kernel.org

On 04/01/2013 09:26 AM, Shaohua Li wrote:
> In page reclaim, huge page is split. split_huge_page() adds tail pages to LRU
> list. Since we are reclaiming a huge page, it's better we reclaim all subpages
> of the huge page instead of just the head page. This patch adds split tail
> pages to shrink page list so the tail pages can be reclaimed soon.
>
> Before this patch, run a swap workload:
> thp_fault_alloc 3492
> thp_fault_fallback 608
> thp_collapse_alloc 6
> thp_collapse_alloc_failed 0
> thp_split 916
>
> With this patch:
> thp_fault_alloc 4085
> thp_fault_fallback 16
> thp_collapse_alloc 90
> thp_collapse_alloc_failed 0
> thp_split 1272
>
> fallback allocation is reduced a lot.
>
> Signed-off-by: Shaohua Li <shli@fusionio.com>

I'm not entirely happy that lru_add_page_tail can now add a page to
list that is not an LRU list, but the patch does do the right thing
policy wise, and I am not sure how to do it better...

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
