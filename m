From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070208111421.30513.77904.sendpatchset@linux.site>
Subject: [patch 0/3] 2.6.20 fix for PageUptodate memorder problem (try 2)
Date: Thu,  8 Feb 2007 14:26:59 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Still no independent confirmation as to whether this is a problem or not.
Updated some comments, added diffstats to patches, don't use __SetPageUptodate
as an internal page-flags.h private function.

I would like to eventually get an ack from Hugh regarding the anon memory
and especially swap side of the equation, and a glance from whoever put the
smp_wmb()s into the copy functions (Was it Ben H or Anton maybe?)

Thanks,
Nick

--
SuSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
