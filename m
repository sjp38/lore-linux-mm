From: Nick Piggin <npiggin@suse.de>
Message-Id: <20060228202202.14172.60409.sendpatchset@linux.site>
Subject: [patch 0/5] mm: improve remapping of vmalloc regions
Date: Thu, 20 Apr 2006 19:06:09 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hi,

I'd like some feedback about this patchset -- whether it is the right
design, and the implementation (e.g. people might dislike patch 4).

vm_insert_page and remap_pfn_range loops are really clever, bit
probably asking a bit too much of most drivers. I was able to get
rid of most of them without too much trouble.

Not tested, because I don't have any of the hardware, but it seems
compiles OK.

Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
