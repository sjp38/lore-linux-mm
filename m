Subject: Re: PATCH: Rewrite of truncate_inode_pages (WIP)
References: <yttvgzwg70s.fsf@serpe.mitica>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: "Juan J. Quintela"'s message of "30 May 2000 03:29:23 +0200"
Date: 30 May 2000 03:52:40 +0200
Message-ID: <yttem6kg5xz.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.rutgers.edu>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi
        sorry I forget one page_cache_release in
        invalidate_inode_pages.  This patch is incremental over the
        previous one.  Sorry for any inconveniences.

Later, Juan.

diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/mm/filemap.c testing/mm/filemap.c
--- base/mm/filemap.c	Tue May 30 03:41:21 2000
+++ testing/mm/filemap.c	Tue May 30 03:46:05 2000
@@ -146,6 +146,7 @@
 			lru_cache_del(page);
 			page_cache_release(page);
 			UnlockPage(page);
+			page_cache_release(page);
 			goto repeat;
 		}
 		__remove_inode_page(page);


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
