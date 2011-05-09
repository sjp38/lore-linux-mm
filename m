Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 072186B0023
	for <linux-mm@kvack.org>; Mon,  9 May 2011 17:14:45 -0400 (EDT)
Date: Mon, 9 May 2011 14:13:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH]mm/migrate.c: clean up comment
Message-Id: <20110509141347.51ccc087.akpm@linux-foundation.org>
In-Reply-To: <1304697799.2450.9.camel@figo-desktop>
References: <1304697799.2450.9.camel@figo-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Figo.zhang" <figo1802@gmail.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>

On Sat, 07 May 2011 00:03:11 +0800
"Figo.zhang" <figo1802@gmail.com> wrote:

> 
> clean up comment. prepare cgroup return 0 or -ENOMEN, others return -EAGAIN.
> avoid conflict meanings.
> 
> Signed-off-by: Figo.zhang <figo1802@gmail.com>
> ---
> mm/migrate.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 34132f8..d65b351 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -647,7 +647,6 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
>  		if (unlikely(split_huge_page(page)))
>  			goto move_newpage;
>  
> -	/* prepare cgroup just returns 0 or -ENOMEM */
>  	rc = -EAGAIN;
>  
>  	if (!trylock_page(page)) {
> @@ -687,7 +686,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
>  		goto unlock;
>  	}
>  
> -	/* charge against new page */
> +	/* charge against new page, return 0 or -ENOMEM */
>  	charge = mem_cgroup_prepare_migration(page, newpage, &mem, GFP_KERNEL);
>  	if (charge == -ENOMEM) {
>  		rc = -ENOMEM;

Well it's still pretty confusing - the function can also return -EAGAIN
and -EBUSY, at least.

It would be better to remove this random sprinkle of commentlets and to
properly document unmap_and_move()'s interface in the usual fashion, in
its leading comment block.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
