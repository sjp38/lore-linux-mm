Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id F0B286B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 05:19:41 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id c13so502870eek.6
        for <linux-mm@kvack.org>; Wed, 07 May 2014 02:19:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o41si900311eem.3.2014.05.07.02.19.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 02:19:40 -0700 (PDT)
Date: Wed, 7 May 2014 11:19:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] memcg: correct comments for
 __mem_cgroup_begin_update_page_stat
Message-ID: <20140507091939.GB9489@dhcp22.suse.cz>
References: <5369EE61.1040003@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5369EE61.1040003@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiang Huang <h.huangqiang@huawei.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed 07-05-14 16:27:13, Qiang Huang wrote:
> 
> Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>

Looks good
Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> ---
>  mm/memcontrol.c | 9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 5804d71..f96e68e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2251,12 +2251,11 @@ cleanup:
>  }
> 
>  /*
> - * Currently used to update mapped file statistics, but the routine can be
> - * generalized to update other statistics as well.
> + * Used to update mapped file or writeback or other statistics.
>   *
>   * Notes: Race condition
>   *
> - * We usually use page_cgroup_lock() for accessing page_cgroup member but
> + * We usually use lock_page_cgroup() for accessing page_cgroup member but
>   * it tends to be costly. But considering some conditions, we doesn't need
>   * to do so _always_.
>   *
> @@ -2270,8 +2269,8 @@ cleanup:
>   * by flags.
>   *
>   * Considering "move", this is an only case we see a race. To make the race
> - * small, we check mm->moving_account and detect there are possibility of race
> - * If there is, we take a lock.
> + * small, we check memcg->moving_account and detect there are possibility
> + * of race or not. If there is, we take a lock.
>   */
> 
>  void __mem_cgroup_begin_update_page_stat(struct page *page,
> -- 
> 1.8.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
