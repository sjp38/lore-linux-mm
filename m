Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C88B06B003D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 02:50:50 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 4so3968229qwk.44
        for <linux-mm@kvack.org>; Tue, 05 May 2009 23:51:37 -0700 (PDT)
Date: Wed, 6 May 2009 15:51:45 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH -mmotm] mm: setup_per_zone_inactive_ratio - fix comment
 and make it __init
Message-Id: <20090506155145.e657b271.minchan.kim@barrios-desktop>
In-Reply-To: <20090506061923.GA4865@lenovo>
References: <20090506061923.GA4865@lenovo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, LMMML <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 6 May 2009 10:19:23 +0400
Cyrill Gorcunov <gorcunov@openvz.org> wrote:

> The caller of setup_per_zone_inactive_ratio is module_init function.

__init :)

> No need to keep the callee after is completed as well.
> Also fix a comment.
> 
> CC: David Rientjes <rientjes@google.com>
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
I guess the comment was a typo. 

> ---
>  mm/page_alloc.c |    4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> Index: linux-2.6.git/mm/page_alloc.c
> =====================================================================
> --- linux-2.6.git.orig/mm/page_alloc.c
> +++ linux-2.6.git/mm/page_alloc.c
> @@ -4540,8 +4540,6 @@ void setup_per_zone_pages_min(void)
>  }
>  
>  /**
> - * setup_per_zone_inactive_ratio - called when min_free_kbytes changes.
> - *
>   * The inactive anon list should be small enough that the VM never has to
>   * do too much work, but large enough that each inactive page has a chance
>   * to be referenced again before it is swapped out.
> @@ -4562,7 +4560,7 @@ void setup_per_zone_pages_min(void)
>   *    1TB     101        10GB
>   *   10TB     320        32GB
>   */
> -static void setup_per_zone_inactive_ratio(void)
> +static void __init setup_per_zone_inactive_ratio(void)
>  {
>  	struct zone *zone;
>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
