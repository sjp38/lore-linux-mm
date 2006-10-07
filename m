Date: Fri, 6 Oct 2006 18:49:30 -0700
From: Andrew Morton <akpm@google.com>
Subject: mm section mismatches
Message-Id: <20061006184930.855d0f0b.akpm@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

i386 allmoconfig, -mm tree:

WARNING: vmlinux - Section mismatch: reference to .init.data:arch_zone_highest_possible_pfn from .text between 'memmap_zone_idx' (at offset 0xc0155e3b) and 'calculate_totalreserve_pages'

WARNING: vmlinux - Section mismatch: reference to .init.data:initkmem_list3 from .text between 'set_up_list3s' (at offset 0xc016ba8e) and 'kmem_flagcheck'

any takers?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
