Date: Mon, 19 Jun 2000 18:22:21 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] -ac21 don't set referenced bit
In-Reply-To: <Pine.LNX.4.21.0006191231300.13200-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0006191819560.5562-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, los@lsdb.bwl.uni-mannheim.de
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jun 2000, Rik van Riel wrote:

>the patch below, against -ac21, does two things:
>
>1) do not set the referenced bit when we add a page to
>   one of the caches ... this allows us to distinguish

Glad to see you agreed with that. You forgot the buffer cache, hint from:

	ftp://ftp.*.kernel.org/pub/linux/kernel/people/andrea/patches/v2.4/2.4.0-test1-ac21/classzone-32.gz

@@ -2338,7 +2362,8 @@
        spin_unlock(&free_list[isize].lock);
 
        page->buffers = bh;
-       lru_cache_add(page);
+       page->flags &= ~(1 << PG_referenced);
+       lru_cache_add(page, LRU_NORMAL_CACHE);
        atomic_inc(&buffermem_pages);
        return 1;
 

Andrea


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
