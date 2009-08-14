Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C20816B0062
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 02:56:48 -0400 (EDT)
Date: Fri, 14 Aug 2009 15:56:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 5/5] mm: document is_page_cache_freeable()
In-Reply-To: <1250065929-17392-5-git-send-email-hannes@cmpxchg.org>
References: <1250065929-17392-1-git-send-email-hannes@cmpxchg.org> <1250065929-17392-5-git-send-email-hannes@cmpxchg.org>
Message-Id: <20090814144547.CBE4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> @@ -286,6 +286,11 @@ static inline int page_mapping_inuse(struct page *page)
>  
>  static inline int is_page_cache_freeable(struct page *page)
>  {
> +	/*
> +	 * A freeable page cache page is referenced only by the caller
> +	 * that isolated the page, the page cache radix tree and
> +	 * optional buffer heads at page->private.
> +	 */
>  	return page_count(page) - page_has_private(page) == 2;
>  }

Looks good to me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
