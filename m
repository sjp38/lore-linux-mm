Received: from localhost (localhost [127.0.0.1])
	by several.ru (Postfix) with ESMTP id 1C724132CDF
	for <linux-mm@kvack.org>; Sun, 16 Jan 2005 19:18:25 +0300 (MSK)
Received: from several.ru ([127.0.0.1])
 by localhost (several.ru [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
 id 01017-01 for <linux-mm@kvack.org>; Sun, 16 Jan 2005 19:18:24 +0300 (MSK)
Received: from tv-sign.ru (unknown [217.23.131.158])
	by several.ru (Postfix) with ESMTP id EC602132CDF
	for <linux-mm@kvack.org>; Sun, 16 Jan 2005 19:18:23 +0300 (MSK)
Message-ID: <41EAA2AD.C7D37D1B@tv-sign.ru>
Date: Sun, 16 Jan 2005 20:21:49 +0300
From: Oleg Nesterov <oleg@tv-sign.ru>
MIME-Version: 1.0
Subject: Q: shrink_cache() vs release_pages() page->lru management
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Is it really necessary to re-add the page to inactive_list?

It seems to me that shrink_cache() can just do:

	if (get_page_testone(page)) {
		__put_page(page);
		--zone->nr_inactive;
		continue;
	}

When the __page_cache_release (or whatever) takes zone->lru_lock
it must check PG_lru before del_page_from_lru().

The same question applies to refill_inactive_zone().

Thanks,
Oleg.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
