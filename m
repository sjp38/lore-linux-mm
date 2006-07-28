From: Nick Piggin <npiggin@suse.de>
Message-Id: <20060515210529.30275.74992.sendpatchset@linux.site>
Subject: [patch 0/9] oom: various fixes and improvements for 2.6.18-rc2
Date: Fri, 28 Jul 2006 09:20:44 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

These are some various OOM killer fixes that I have accumulated. Some of
the more important ones are in SLES10, and were developed in response to
issues coming up in stress testing.

The other small fixes haven't been widely tested, but they're issues I
spotted when working in this area.

Comments?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
