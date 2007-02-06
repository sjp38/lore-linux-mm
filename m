From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070206054925.21042.50546.sendpatchset@linux.site>
Subject: [patch 0/3] 2.6.20 fix for PageUptodate memorder problem
Date: Tue,  6 Feb 2007 09:02:01 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Linux Filesystems <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Still no independent confirmation as to whether this is a problem or not.
I think it is, so I'll propose this patchset to fix it. Patch 1/3 has a
reasonable description of the problem.

Thanks,
Nick

--
SuSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
