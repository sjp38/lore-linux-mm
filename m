Date: Sat, 08 Feb 2003 11:29:33 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Performance of highpte
Message-ID: <16010000.1044732573@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm mailing list <linux-mm@kvack.org>
Cc: dmccr@us.ibm.com
List-ID: <linux-mm.kvack.org>

Hmmm. Looks like we need to dust off UKVA to me.

diffprofile:

3790 page_remove_rmap
3213 default_idle
1299 kmap_atomic
803 kmap_atomic_to_page
776 kmem_cache_free
676 __pte_chain_free
486 page_add_rmap
240 unmap_all_pages
225 kmem_cache_alloc
166 vm_enough_memory
132 do_generic_mapping_read
100 handle_mm_fault
82 buffered_rmqueue
79 __copy_from_user_ll
67 update_atime
66 kunmap_atomic
63 release_pages
58 filemap_nopage
55 file_move
51 generic_file_open
51 find_get_page
...
-52 dput
-61 do_schedule
-63 get_empty_filp
-74 do_page_fault
-96 vfs_read
-97 path_lookup
-121 fd_install
-159 pte_alloc_one
-260 .text.lock.file_table
-372 page_address

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
