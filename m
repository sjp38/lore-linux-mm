Date: Tue, 6 Feb 2001 13:07:18 +0100
From: Rasmus Andersen <rasmus@jaquet.dk>
Subject: [PATCH] thinko in mm/filemap.c (242p1)
Message-ID: <20010206130718.F18574@jaquet.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi.

The following patch fixes what I think is a cut'n'paste slipup in
mm/filemap.c::generic_buffer_fdatasync. It applies against 242p1
and 241-ac3. Comments?

--- linux/mm/filemap.c.org      Tue Feb  6 13:00:03 2001
+++ linux/mm/filemap.c  Tue Feb  6 13:00:53 2001
@@ -397,7 +397,7 @@
        retval |= do_buffer_fdatasync(&inode->i_mapping->locked_pages, start_idx
, end_idx, writeout_one_page);
 
        /* now wait for locked buffers on pages from both clean and dirty lists 
*/
-       retval |= do_buffer_fdatasync(&inode->i_mapping->dirty_pages, start_idx,
 end_idx, writeout_one_page);
+       retval |= do_buffer_fdatasync(&inode->i_mapping->dirty_pages, start_idx,
 end_idx, waitfor_one_page);
        retval |= do_buffer_fdatasync(&inode->i_mapping->clean_pages, start_idx,
 end_idx, waitfor_one_page);
        retval |= do_buffer_fdatasync(&inode->i_mapping->locked_pages, start_idx
, end_idx, waitfor_one_page);
 


Regards,
  Rasmus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
