Date: Sun, 3 Mar 2002 21:03:46 +0100
From: Christoph Hellwig <hch@caldera.de>
Subject: [PATCH] radix-tree pagecache for 2.4.19-pre2-ac2
Message-ID: <20020303210346.A8329@caldera.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I have uploaded an updated version of the radix-tree pagecache patch
against 2.4.19-pre2-ac2.  News in this release:

* fix a deadlock when vmtruncate takes i_shared_lock twice by introducing
  a new mapping->page_lock that mutexes mapping->page_tree. (akpm)
* move setting of page->flags back out of move_to/from_swap_cache. (akpm)
* put back lost page state settings in shmem_unuse_inode. (akpm)
* get rid of remove_page_from_inode_queue - there was only one caller. (me)
* replace add_page_to_inode_queue with ___add_to_page_cache. (me)

Please give it some serious beating while I try to get 2.5 working and
port the patch over 8)

Location:

	ftp://ftp.kernel.org/pub/linux/kernel/people/hch/patches/v2.4/2.4.19-pre2-ac2/linux-2.4.19-radixtree.patch.gz
	ftp://ftp.kernel.org/pub/linux/kernel/people/hch/patches/v2.4/2.4.19-pre2-ac2/linux-2.4.19-radixtree.patch.bz2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
