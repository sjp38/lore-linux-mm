Message-ID: <39D3B9DA.C4319407@sgi.com>
Date: Thu, 28 Sep 2000 14:36:26 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: lru_cache_add() -> deactivate_page_nolock()?
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Few questions on aging & deactivation:

Suppose a page has to be freshly allocated 
(no cache hit) in __grab_cache_page() in generic_file_write().
What is the age of the page at the time of its lru_cache_add?
Won't the age be zero?
If so, won't it be the case that deactive_page_nolock() will be
called _every_ time such a page is lru_cache_add'ed,
and that this call will be the one from here:

--------
void lru_cache_add(struct page * page)
{
	[ ... ]
	/* This should be relatively rare */
        if (!page->age)
                deactivate_page_nolock(page);
	[ ... ]
}
----------

If so, I fail to understand the motivation behind
the "relatively rare" comment ...



--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
