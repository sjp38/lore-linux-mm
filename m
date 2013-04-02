Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id A4D266B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 09:09:32 -0400 (EDT)
Date: Tue, 2 Apr 2013 09:09:25 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch]THP: add split tail pages to shrink page list in page
 reclaim
Message-ID: <20130402130925.GB4611@cmpxchg.org>
References: <20130401132605.GA2996@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130401132605.GA2996@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, aarcange@redhat.com, minchan@kernel.org

On Mon, Apr 01, 2013 at 09:26:05PM +0800, Shaohua Li wrote:
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

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
