Date: Sat, 5 Nov 2005 21:21:33 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Does shmem_getpage==>shmem_alloc_page==>alloc_page_vma hold
 mmap_sem?
Message-Id: <20051105212133.714da0d2.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andi,

The comment in mm/mempolicy.c for alloc_page_vma() states:

  Should be called with the mm_sem of the vma hold.

However it seems that the call chain (#ifdef CONFIG_NUMA):

  shmem_getpage ==> shmem_alloc_page ==> alloc_page_vma

where shmem_getpage() is called from many of the mm/shmem.c file
operations, is called without holding mmap_sem.  There is no
mention of mmap_sem in the entire mm/shmem.c file.

This doesn't seem right.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
