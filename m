Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1AB236B0069
	for <linux-mm@kvack.org>; Thu, 17 Nov 2011 03:22:49 -0500 (EST)
Date: Thu, 17 Nov 2011 09:22:42 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: cleanup the comment for head/tail pages of compound
 pages in mm/page_alloc.c
Message-ID: <20111117082148.GA30544@tiehlicka.suse.cz>
References: <4EC21D78.4080508@gmail.com>
 <20111115132409.GA7551@tiehlicka.suse.cz>
 <4EC2FE33.7030905@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4EC2FE33.7030905@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Sheng-Hui <shhuiw@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, trivial@kernel.org

[CCing trivial tree]

Unquoted patch at https://lkml.org/lkml/2011/11/15/402

On Wed 16-11-11 08:05:07, Wang Sheng-Hui wrote:
[...]
> Thanks, Michal.
> 
> New patch generated.
> 
> 
> [PATCH] mm: cleanup the comment for head/tail pages of compound pages in mm/page_alloc.c
> 
> Only tail pages point at the head page using their ->first_page fields.
> 
> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/page_alloc.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6e8ecb6..e7dd848 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -332,8 +332,8 @@ out:
>   *
>   * The remaining PAGE_SIZE pages are called "tail pages".
>   *
> - * All pages have PG_compound set.  All pages have their ->private pointing at
> - * the head page (even the head page has this).
> + * All pages have PG_compound set.  All tail pages have their ->first_page
> + * pointing at the head page.
>   *
>   * The first tail page's ->lru.next holds the address of the compound page's
>   * put_page() function.  Its ->lru.prev holds the order of allocation.
> -- 
> 1.7.1

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
