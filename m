Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DF9666B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 03:21:31 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id k184so1251405wme.3
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 00:21:31 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id 69si30138203wmr.9.2016.06.08.00.21.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 00:21:30 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id n184so576480wmn.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 00:21:30 -0700 (PDT)
Date: Wed, 8 Jun 2016 09:21:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: fix documentation for compound parameter
Message-ID: <20160608072129.GC22570@dhcp22.suse.cz>
References: <1465368216-9393-1-git-send-email-roy.qing.li@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465368216-9393-1-git-send-email-roy.qing.li@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: roy.qing.li@gmail.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com

On Wed 08-06-16 14:43:36, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> commit f627c2f53786 ("memcg: adjust to support new THP refcounting")
> adds a compound parameter for several functions, and change one as
> compound for mem_cgroup_move_account but it does not change the
> comments.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index bc79b38..4d9a215 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4387,7 +4387,7 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
>  /**
>   * mem_cgroup_move_account - move account of the page
>   * @page: the page
> - * @nr_pages: number of regular pages (>1 for huge pages)
> + * @compound: charge the page as compound or small page
>   * @from: mem_cgroup which the page is moved from.
>   * @to:	mem_cgroup which the page is moved to. @from != @to.
>   *
> @@ -5249,6 +5249,7 @@ bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg)
>   * @mm: mm context of the victim
>   * @gfp_mask: reclaim mode
>   * @memcgp: charged memcg return
> + * @compound: charge the page as compound or small page
>   *
>   * Try to charge @page to the memcg that @mm belongs to, reclaiming
>   * pages according to @gfp_mask if necessary.
> @@ -5311,6 +5312,7 @@ out:
>   * @page: page to charge
>   * @memcg: memcg to charge the page to
>   * @lrucare: page might be on LRU already
> + * @compound: charge the page as compound or small page
>   *
>   * Finalize a charge transaction started by mem_cgroup_try_charge(),
>   * after page->mapping has been set up.  This must happen atomically
> @@ -5362,6 +5364,7 @@ void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
>   * mem_cgroup_cancel_charge - cancel a page charge
>   * @page: page to charge
>   * @memcg: memcg to charge the page to
> + * @compound: charge the page as compound or small page
>   *
>   * Cancel a charge transaction started by mem_cgroup_try_charge().
>   */
> -- 
> 2.1.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
