Date: Sat, 31 May 2003 12:14:48 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: pgcl-2.5.70-bk5-2
Message-ID: <20030531191448.GA20413@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This release corrects a showstopping list handling bug in the pgd slab
management code. When PAGE_MMUCOUNT > 1, the pgd : struct page relation
becomes N:1, so that pgd_ctor() and pgd_dtor() may be called multiple
times for each page dedicated to the pgd slab. The bug was that
pgd_ctor() did an unconditional list_add(&page->lru, &pgd_list) and
pgd_dtor() did an unconditional list_del(&page->lru, &pgd_list)
regardless of whether the page backing the pgd's passed as an argument
was already on the pgd_list. There was also a bug in pageattr.c where
the pieces of a pgd slab page weren't iterated over when looping over
pgd slab pages.

A minor highmem compilefix and a fixes for /proc/vmstat reporting
inaccuracies are also included.

pgcl-2.5.70-bk5-2 survives a couple of hours of running dbench and
tiobench in a loop.

Available as an incremental patch atop pgcl-2.5.70-bk5-1 from:
ftp://ftp.kernel.org/pub/linux/kernel/people/wli/vm/pgcl/


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
