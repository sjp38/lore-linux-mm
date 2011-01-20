Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1F50A8D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 12:37:19 -0500 (EST)
Date: Thu, 20 Jan 2011 11:30:35 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] When migrate_pages returns 0, all pages must have
 been released
In-Reply-To: <f60d811fd1abcb68d40ac19af35881d700a97cd2.1295539829.git.minchan.kim@gmail.com>
Message-ID: <alpine.DEB.2.00.1101201130100.10695@router.home>
References: <f60d811fd1abcb68d40ac19af35881d700a97cd2.1295539829.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jan 2011, Minchan Kim wrote:

> diff --git a/mm/migrate.c b/mm/migrate.c
> index 46fe8cc..7d34237 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -772,6 +772,7 @@ uncharge:
>  unlock:
>  	unlock_page(page);
>
> +move_newpage:
>  	if (rc != -EAGAIN) {
>   		/*
>   		 * A page that has been migrated has all references
> @@ -785,8 +786,6 @@ unlock:
>  		putback_lru_page(page);
>  	}
>
> -move_newpage:
> -
>  	/*
>  	 * Move the new page to the LRU. If migration was not successful
>  	 * then this will free the page.
>

What does this do? Not covered by the description.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
