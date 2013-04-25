Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id BE6476B0002
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 18:00:59 -0400 (EDT)
Date: Thu, 25 Apr 2013 15:00:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, highmem: remove useless virtual variable in
 page_address_map
Message-Id: <20130425150057.c25220a8f03e068f5bea5d58@linux-foundation.org>
In-Reply-To: <1366619188-28087-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1366619188-28087-1-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

On Mon, 22 Apr 2013 17:26:28 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> We can get virtual address without virtual field.
> So remove it.
> 
> ...
>
> --- a/mm/highmem.c
> +++ b/mm/highmem.c
> @@ -320,7 +320,6 @@ EXPORT_SYMBOL(kunmap_high);
>   */
>  struct page_address_map {
>  	struct page *page;
> -	void *virtual;
>  	struct list_head list;
>  };
>  
> @@ -362,7 +361,10 @@ void *page_address(const struct page *page)
>  
>  		list_for_each_entry(pam, &pas->lh, list) {
>  			if (pam->page == page) {
> -				ret = pam->virtual;
> +				int nr;
> +
> +				nr = pam - page_address_map;

Doesn't compile.  Presumably you meant page_address_maps.

I'll drop this - please resend if/when it has been runtime tested.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
