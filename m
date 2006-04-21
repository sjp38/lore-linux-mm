From: Nick Piggin <npiggin@suse.de>
Message-Id: <20060301045901.12434.54077.sendpatchset@linux.site>
Subject: [patch 0/5] mm: improve remapping of vmalloc regions
Date: Fri, 21 Apr 2006 08:43:08 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

OK, I've added my fixes, and removed vmalloc_to_pfn as per
Christoph's suggestion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
