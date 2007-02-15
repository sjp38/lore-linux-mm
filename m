From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070215051822.7443.30110.sendpatchset@linux.site>
Subject: [patch 0/3] 2.6.20 fix for PageUptodate memorder problem (try 4)
Date: Thu, 15 Feb 2007 08:31:02 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Various little cleanups and commenting fixes. Fixed up the patchset so
each one, incrementally, should give a properly compiling and running
kernel.

I'd still like Hugh to ack the anon/swap changes when he can find the time.
It would be desirable to get at least one ack as to the overall problem and
design of the fix (Martin's ack is just for the s390 changes at this stage).

Meanwhile, can it go into -mm for wider testing, if it isn't too much
trouble?

Thanks,
Nick

--
SuSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
