Date: Thu, 4 May 2000 17:23:35 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: classzone-VM + mapped pages out of lru_cache
In-Reply-To: <Pine.LNX.4.21.0005041702560.2512-100000@alpha.random>
Message-ID: <Pine.LNX.4.21.0005041722560.2835-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Thu, 4 May 2000, Andrea Arcangeli wrote:

>--- 2.2.15/mm/filemap.c	Thu May  4 13:00:40 2000
>+++ /tmp/filemap.c	Thu May  4 17:11:18 2000
>@@ -68,7 +68,7 @@
> 
> 	p = &inode->i_pages;
> 	while ((page = *p) != NULL) {
>-		if (PageLocked(page)) {
>+		if (PageLocked(page) || atomic_read(&page->count) > 1) {
> 			p = &page->next;
> 			continue;
> 		}

above patch is also here:

	ftp://ftp.us.kernel.org/pub/linux/kernel/people/andrea/patches/v2.2/2.2.15/invalidate_inode_pages-1

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
