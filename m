Subject: Re: PATCH: Improvement in shrink_mmap (take 2)
References: <yttg0qf7vnm.fsf@serpe.mitica>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: "Juan J. Quintela"'s message of "15 Jun 2000 00:19:41 +0200"
Date: 15 Jun 2000 02:18:31 +0200
Message-ID: <yttsnuf6bl4.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ac@muc.de
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Dave Jones <dave@denial.force9.co.uk>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, lkml <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi

        James Manning told me that this test is easier to optimize
        (global result is the same).

Later, Juan.
        

diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude ac18/mm/filemap.c prueba/mm/filemap.c
--- ac18/mm/filemap.c	Thu Jun 15 00:28:22 2000
+++ prueba/mm/filemap.c	Thu Jun 15 02:14:59 2000
@@ -351,7 +351,9 @@
 		 * of zone - it's old.
 		 */
 		if (page->buffers) {
-			int wait = ((gfp_mask & __GFP_IO) && (nr_dirty-- < 0));
+			int wait = ((gfp_mask & __GFP_IO) && (--nr_dirty < 0));
+			if(nr_dirty < 0)
+				nr_dirty = priority;
 			if (!try_to_free_buffers(page, wait))
 				goto unlock_continue;
 			/* page was locked, inode can't go away under us */


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
