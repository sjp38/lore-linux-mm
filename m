Date: Thu, 24 Apr 2003 16:13:54 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: objrmap (was 2.5.68-mm2)
Message-ID: <1675320000.1051226034@flay>
In-Reply-To: <1661460000.1051218805@flay>
References: <20030423012046.0535e4fd.akpm@digeo.com><18400000.1051109459@[10.10.2.4]> <20030423144648.5ce68d11.akpm@digeo.com> <1565150000.1051134452@flay> <20030423233954.D9036@redhat.com> <1661460000.1051218805@flay>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> OK, well then you need to look at something that's not totally dominated
> by gcc anyway. I know everyone hates SDET as it's "closed" but I'll try
> to rerun with aim7 at some point. A real 20% improvement in throughput
> is not to be sniffed at ...

BTW, if you want to see the profile for this, it's obvious what's
taking the time ...

86159 page_remove_rmap
38690 page_add_rmap
17976 zap_pte_range
14431 copy_page_range
10953 __d_lookup
9978 release_pages
9369 find_get_page
7483 atomic_dec_and_lock
6924 __copy_to_user_ll
6830 kmem_cache_free
5848 path_lookup
4687 follow_mount
4430 clear_page_tables
4214 remove_shared_vm_struct
3907 do_wp_page
3823 .text.lock.dec_and_lock
3336 do_no_page
3315 do_anonymous_page
3294 copy_mm
3279 free_pages_and_swap_cache
3111 pte_alloc_one
2709 .text.lock.dcache
2625 .text.lock.filemap
2573 filemap_nopage
2564 copy_process
2556 proc_pid_stat
2358 link_path_walk
2246 do_page_fault
2202 file_move
2189 buffered_rmqueue
2141 free_hot_cold_page
2140 schedule
2114 path_release
1879 current_kernel_time
1825 .text.lock.namei
1722 d_alloc
1719 release_task
1490 __set_page_dirty_buffers
1464 number
1350 kmalloc
1343 __read_lock_failed
1305 page_address
1286 fd_install
1255 __find_get_block
1253 flush_signal_handlers
1249 __fput
1248 exit_notify
1242 task_mem
1221 grab_block
1188 .text.lock.highmem
1169 __block_prepare_write
1123 __brelse
1050 file_kill
1026 .text.lock.file_table
1013 ext2_new_inode
1008 __mark_inode_dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
