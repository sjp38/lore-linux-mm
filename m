Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 17BChl-0005Uq-00
	for <linux-mm@kvack.org>; Fri, 24 May 2002 03:53:53 -0700
Date: Fri, 24 May 2002 03:53:53 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: treap bootmem update
Message-ID: <20020524105353.GH2035@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is an update to the treap-based bootmem patch. Very lightly tested
(UP i386 laptop with 256MB of RAM). As the patch is too lengthy to post
directly, I give only pointers to it. It features two new features:

(1) dynamic page stealing
(2) free_pages() of higher-order pages for bulk marking of free pages
	in the buddy allocator bitmap in free_all_bootmem_core().
and a cleanup:
(3) various cleanups including codesize reduction and elimination of
	dozens of include/asm-*/bootmem.h droppings around the tree.

Available from:
	bk://linux-wli.bkbits.net/bootmem/
	ftp://ftp.kernel.org/pub/linux/kernel/wli/bootmem/bootmem-2.5.17-1

Remaining TODO items to follow up on are:
(1) The ability to mark memory as available at runtime but unusable for
	bootmem allocations. (rmk)
(2) Implement queries for automatic determination of ->node_start_paddr
	and ->node_low_pfn. (wli)

Cheers,
Bill
-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
