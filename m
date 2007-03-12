From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070312042553.5536.73828.sendpatchset@linux.site>
Subject: [patch 0/4] mlock pages off LRU
Date: Mon, 12 Mar 2007 07:38:35 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

This is my current mlock patchset, based on top of the last partial rollup
of Andrew's tree that I was given, plus my recent fault vs invalidate race
fixes.

This boots and appears to do the right thing here, with several test cases.

Lee has been helping to test and debug, and he found a case where mlocked
pages weren't getting unlocked properly, but that should be fixed now.

Comments?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
