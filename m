Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id A1B986B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 05:50:25 -0400 (EDT)
Date: Thu, 23 Aug 2012 11:50:22 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Fixup the page of buddy_higher address's calculation
Message-ID: <20120823095022.GB10685@dhcp22.suse.cz>
References: <CAFNq8R7ibTNeRP_Wftwyr7mK6Du4TVysQysgL_RYj+CGf9N2qg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFNq8R7ibTNeRP_Wftwyr7mK6Du4TVysQysgL_RYj+CGf9N2qg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Haifeng <omycle@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 23-08-12 16:40:13, Li Haifeng wrote:
> From d7cd78f9d71a5c9ddeed02724558096f0bb4508a Mon Sep 17 00:00:00 2001
> From: Haifeng Li <omycle@gmail.com>
> Date: Thu, 23 Aug 2012 16:27:19 +0800
> Subject: [PATCH] Fixup the page of buddy_higher address's calculation

Some general questions:
Any word about the change? Is it really that obvious? Why do you think the
current state is incorrect? How did you find out?

And more specific below:

> Signed-off-by: Haifeng Li <omycle@gmail.com>
> ---
>  mm/page_alloc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ddbc17d..5588f68 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -579,7 +579,7 @@ static inline void __free_one_page(struct page *page,
>                 combined_idx = buddy_idx & page_idx;
>                 higher_page = page + (combined_idx - page_idx);
>                 buddy_idx = __find_buddy_index(combined_idx, order + 1);
> -               higher_buddy = page + (buddy_idx - combined_idx);
> +               higher_buddy = page + (buddy_idx - page_idx);

We are finding buddy index for combined_idx so why should we use
page_idx here?

>                 if (page_is_buddy(higher_page, higher_buddy, order + 1)) {
>                         list_add_tail(&page->lru,
>                                 &zone->free_area[order].free_list[migratetype]);
> --
> 1.7.5.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
