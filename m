Received: from [127.0.0.1] (helo=logos.cnet)
	by www.linux.org.uk with esmtp (Exim 4.33)
	id 1C9VrO-0006k0-7k
	for linux-mm@kvack.org; Mon, 20 Sep 2004 22:38:10 +0100
Date: Mon, 20 Sep 2004 17:09:53 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: PG_slab?
Message-ID: <20040920200953.GF5521@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi MM fellows,

What is PG_slab about?

#define PG_slab                  7      /* slab debug (Suparna wants this) */

Its not used by SLAB though:

[marcelo@xeon mm]$ grep -A5 -B5 PG_slab page_alloc.c
                        1 << PG_lru     |
                        1 << PG_private |
                        1 << PG_locked  |
                        1 << PG_active  |
                        1 << PG_reclaim |
                        1 << PG_slab    |
                        1 << PG_swapcache |
                        1 << PG_writeback )))
                bad_page(function, page);
        if (PageDirty(page))
                ClearPageDirty(page);
[marcelo@xeon mm]$

I suppose it was used by someone sometime ago but its not anymore?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
