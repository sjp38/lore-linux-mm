From: Nick Piggin <npiggin@suse.de>
Message-Id: <20060118024106.10241.69438.sendpatchset@linux.site>
Subject: [patch 0/4] mm: de-skew page refcount
Date: Wed, 18 Jan 2006 11:40:25 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

The following patchset (against 2.6.16-rc1 + migrate race fixes) uses the new
atomic ops to do away with the offset page refcounting, and simplify the race
that it was designed to cover.

This allows some nice optimisations, and in the page freeing path we end up
saving 2 atomic ops including a spin_lock_irqsave in the !PageLRU case, and 1
or 2 atomic ops in the PageLRU case.

Andrew's previous feedback has been incorporated (less BUG_ONs in fastpaths
and more detail in changelogs).

Anyone spot any holes or races?

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
