Received: from groan.gormenghast (216-99-198-160.dial.spiritone.com [216.99.198.160])
	by franka.aracnet.com (8.12.5/8.12.5) with ESMTP id h18JWZLs013809
	for <linux-mm@kvack.org>; Sat, 8 Feb 2003 11:32:36 -0800
Received: from [10.10.2.4] (fletch@titus.gormenghast [10.10.2.4])
	by groan.gormenghast (8.12.3/8.12.3/Debian -4) with ESMTP id h18JX7Tl002990
	for <linux-mm@kvack.org>; Sat, 8 Feb 2003 11:33:07 -0800
Date: Sat, 08 Feb 2003 11:33:06 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: Performance of highpte
Message-ID: <16730000.1044732785@[10.10.2.4]>
In-Reply-To: <16010000.1044732573@[10.10.2.4]>
References: <16010000.1044732573@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Odd. linux-mm helpfully stripped the results ... I'll try once more below,
if that doesn't work, try getting it off linux-kernel.


> Kernbench-2: (make -j N vmlinux, where N = 2 x num_cpus)
>                         Elapsed        User      System         CPU
>          2.5.59-mjb5       45.64      564.71      110.73     1479.50
>  2.5.59-mjb5-highpte       46.38      565.32      118.35     1473.50


--On Saturday, February 08, 2003 11:29:33 -0800 "Martin J. Bligh"
<mbligh@aracnet.com> wrote:

> Hmmm. Looks like we need to dust off UKVA to me.
> 
> diffprofile:
> 
> 3790 page_remove_rmap
> 3213 default_idle
> 1299 kmap_atomic
> 803 kmap_atomic_to_page
> 776 kmem_cache_free
> 676 __pte_chain_free
> 486 page_add_rmap
> 240 unmap_all_pages
> 225 kmem_cache_alloc
> 166 vm_enough_memory
> 132 do_generic_mapping_read
> 100 handle_mm_fault
> 82 buffered_rmqueue
> 79 __copy_from_user_ll
> 67 update_atime
> 66 kunmap_atomic
> 63 release_pages
> 58 filemap_nopage
> 55 file_move
> 51 generic_file_open
> 51 find_get_page
> ...
> -52 dput
> -61 do_schedule
> -63 get_empty_filp
> -74 do_page_fault
> -96 vfs_read
> -97 path_lookup
> -121 fd_install
> -159 pte_alloc_one
> -260 .text.lock.file_table
> -372 page_address
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
