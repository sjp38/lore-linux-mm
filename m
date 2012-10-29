Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 9D32D6B006C
	for <linux-mm@kvack.org>; Sun, 28 Oct 2012 21:52:07 -0400 (EDT)
Date: Mon, 29 Oct 2012 10:57:52 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/5] mm, highmem: remove page_address_pool list
Message-ID: <20121029015752.GH15767@bbox>
References: <Yes>
 <1351451576-2611-1-git-send-email-js1304@gmail.com>
 <1351451576-2611-4-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1351451576-2611-4-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Oct 29, 2012 at 04:12:54AM +0900, Joonsoo Kim wrote:
> We can find free page_address_map instance without the page_address_pool.
> So remove it.
> 
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>

See below a nitpick. :)

> 
> diff --git a/mm/highmem.c b/mm/highmem.c
> index 017bad1..731cf9a 100644
> --- a/mm/highmem.c
> +++ b/mm/highmem.c
> @@ -323,11 +323,7 @@ struct page_address_map {
>  	void *virtual;
>  	struct list_head list;
>  };
> -

Let's leave a blank line.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
