Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E34006B0007
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 00:15:34 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id p20so5529039pfh.17
        for <linux-mm@kvack.org>; Sun, 28 Jan 2018 21:15:34 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id x10-v6si8416421plm.261.2018.01.28.21.15.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 28 Jan 2018 21:15:33 -0800 (PST)
Date: Sun, 28 Jan 2018 21:15:32 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm/swap.c: fix kernel-doc functions and parameters
Message-ID: <20180129051532.GA18247@bombadil.infradead.org>
References: <bac38b63-5b67-b2b7-8fe9-ff9c36f59ded@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bac38b63-5b67-b2b7-8fe9-ff9c36f59ded@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>

On Sun, Jan 28, 2018 at 08:01:08PM -0800, Randy Dunlap wrote:
> @@ -400,6 +400,10 @@ void mark_page_accessed(struct page *pag
>  }
>  EXPORT_SYMBOL(mark_page_accessed);
>  
> +/**
> + * __lru_cache_add: add a page to the page lists
> + * @page: the page to add
> + */
>  static void __lru_cache_add(struct page *page)
>  {
>  	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
> @@ -410,10 +414,6 @@ static void __lru_cache_add(struct page
>  	put_cpu_var(lru_add_pvec);
>  }
>  
> -/**
> - * lru_cache_add: add a page to the page lists
> - * @page: the page to add
> - */
>  void lru_cache_add_anon(struct page *page)
>  {
>  	if (PageActive(page))

I don't see the point in adding kernel-doc for a static function while
deleting it for a non-static function?  I'd change the name of the
function in the second hunk and drop the first hunk.

Also, the comment doesn't actually fit the kernel-doc format (colon
versus hyphen; missing capitalisation and full-stop).

> @@ -913,11 +913,11 @@ EXPORT_SYMBOL(__pagevec_lru_add);
>   * @pvec:	Where the resulting entries are placed
>   * @mapping:	The address_space to search
>   * @start:	The starting entry index
> - * @nr_entries:	The maximum number of entries
> + * @nr_pages:	The maximum number of entries
>   * @indices:	The cache indices corresponding to the entries in @pvec
>   *
>   * pagevec_lookup_entries() will search for and return a group of up
> - * to @nr_entries pages and shadow entries in the mapping.  All
> + * to @nr_pages pages and shadow entries in the mapping.  All
>   * entries are placed in @pvec.  pagevec_lookup_entries() takes a
>   * reference against actual pages in @pvec.
>   *

I think the documentation has the right name here; it is the number of
entries and not the number of pages which is returned.  We should change
the code to match the documentation here ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
