From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070221023656.6306.246.sendpatchset@linux.site>
Subject: [patch 0/6] fault vs truncate/invalidate race fix
Date: Wed, 21 Feb 2007 05:49:38 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

The following set of patches are based on current git.

These fix the fault vs invalidate and fault vs truncate_range race for
filemap_nopage mappings, plus those and fault vs truncate race for nonlinear
mappings.

These patches fix silent data corruption that we've had several people hitting
in SUSE kernels. Our kernels have similar patches to lock the page over page
fault, and no problem.

I've also got rid of the horrible populate API, and integrated nonlinear pages
properly with the page fault path.

Downside is that this adds one more vector through which the buffered write
deadlock can occur. However this is just a very tiny one (pte being unmapped
for reclaim), compared to all the other ways that deadlock can occur (unmap,
reclaim, truncate, invalidate). I doubt it will be noticable. At any rate, it
is better than data corruption.

I hope these can get merged (at least into -mm) soon.

Thanks,
Nick

--
SuSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
