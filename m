From: Nick Piggin <nickpiggin@yahoo.com.au>
Message-Id: <20060108052307.2996.39444.sendpatchset@didi.local0.net>
Subject: [patch 0/4] mm: de-skew page_count
Date: Sun, 8 Jan 2006 00:19:27 -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

The following patchset (against 2.6.15-rc5ish) uses the new atomic ops to
do away with the offset page refcounting, and simplify the race that it
was designed to cover.

This allows some nice optimisations, and we end up saving 2 atomic ops
including a spin_lock_irqsave in the !PageLRU case, and 1 or 2 atomic ops
in the PageLRU case in the page-release path.

It also happens to be a requirement for my lockless pagecache work, but
stands on its own as good patches.

Nick

-- 
SUSE Labs, Novell Inc.


Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
