Date: Tue, 13 May 2003 19:08:17 +0200
Subject: Re: 2.5.69-mm4 smp crash, seems fs/vm related
Message-ID: <20030513170817.GA462@hh.idb.hist.no>
References: <20030512225504.4baca409.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030512225504.4baca409.akpm@digeo.com>
From: Helge Hafting <helgehaf@aitel.hist.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I tried 2.5.69-mm4 + your fblogo patch on my dual celeron.
It oopsed during boot. 
The machine has 384M RAM, it uses ext2 filessytems
on various scsi partitions, root is on a raid-0 device.
It is a nfsv3 server for another machine, I don't
think there were any nfs traffic when it crashed though.
The kernel uses preempt, devfs & framebuffer. 

Some scrolled off screen, this remained:

mempool_alloc
mempool_alloc
autoremove_wake_function
autoremove_wake_function
bio_alloc
mpage_alloc
do_mpage_readpage
radix_tree_insert
add_to_page_cache
mpage_readpages
ext2_get_block
read_pages
ext2_get_block
__alloc_pages
do_page_cache_readahead
filemap_populate
sys_remap_file_pages
do_mmap_pgoff
old_mmap
syscall_call
There were also a hex code listing at the end.

Helge Hafting
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
