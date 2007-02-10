From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070210001844.21921.48605.sendpatchset@linux.site>
Subject: [patch 0/3] 2.6.20 fix for PageUptodate memorder problem (try 3)
Date: Sat, 10 Feb 2007 03:31:22 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

OK, I have got rid of SetPageUptodate_nowarn, and removed the atomic op
from SetNewPageUptodate. Made PageUptodate_NoLock only issue the memory
barrier is the page was uptodate (hopefully the compiler can thread the
branch into the caller's branch).

SetNewPageUptodate does not do the S390 page_test_and_clear_dirty, so
I'd like to make sure that's OK.

Rearranged the patch series so we don't have the first patch introducing
a lot of WARN_ONs that are solved in the next two patches (rather, solve
those issues first).

Thanks,
Nick

--
SuSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
