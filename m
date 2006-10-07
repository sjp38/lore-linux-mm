From: Nick Piggin <npiggin@suse.de>
Message-Id: <20061007105758.14024.70048.sendpatchset@linux.site>
Subject: [rfc] 2.6.19-rc1: vm stuff
Date: Sat,  7 Oct 2006 15:05:37 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

The first 3 patches are some minor fixes and rearrangements for the
page allocator and are probably fit to go into -mm.

The next set of 3 patches is another attempt at solving the invalidate
vs pagefault race (this got reintroduced after invalidate_complete_page2
was added, and has always been present for nonlinear mappings). These
are booted and have had some stress testing, but are still at the RFC
stage. Comments?

Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
