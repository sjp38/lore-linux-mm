Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id C85106B0044
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 04:06:30 -0400 (EDT)
Date: Fri, 24 Aug 2012 10:06:26 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Fixup the page of buddy_higher address's calculation
Message-ID: <20120824080626.GC29282@dhcp22.suse.cz>
References: <CAFNq8R7ibTNeRP_Wftwyr7mK6Du4TVysQysgL_RYj+CGf9N2qg@mail.gmail.com>
 <20120823095022.GB10685@dhcp22.suse.cz>
 <CAFNq8R5pY0yPp-LQYNywpMhVtXgqPSy3RYqHVTVpPXs52kOmJw@mail.gmail.com>
 <20120823135839.GB19968@dhcp22.suse.cz>
 <CAFNq8R7ry5kyuMombamf6jLmiLcWFnRQRp2vYt1+kv+pPec1_w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFNq8R7ry5kyuMombamf6jLmiLcWFnRQRp2vYt1+kv+pPec1_w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Haifeng <omycle@gmail.com>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 24-08-12 10:08:20, Li Haifeng wrote:
[...]
> Subject: [PATCH] Fix the page address of higher page's buddy calculation
> 
> Calculate the page address of higher page's buddy should be based
> higher_page with the offset between index of higher page and
> index of higher page's buddy.

Sorry for insisting but could you add an information about when this has
been introduced (I have mentioned the commit in the other email) and the
effect of the bug so that we can consider whether this is worth
backporting to stable trees.

> Signed-off-by: Haifeng Li <omycle@gmail.com>
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>

Other than that
Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/page_alloc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index cdef1d4..642cd62 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -536,7 +536,7 @@ static inline void __free_one_page(struct page *page,
>                 combined_idx = buddy_idx & page_idx;
>                 higher_page = page + (combined_idx - page_idx);
>                 buddy_idx = __find_buddy_index(combined_idx, order + 1);
> -               higher_buddy = page + (buddy_idx - combined_idx);
> +               higher_buddy = higher_page + (buddy_idx - combined_idx);
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
