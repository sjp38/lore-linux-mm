From: Nick Piggin <npiggin@suse.de>
Message-Id: <20060408134635.22479.79269.sendpatchset@linux.site>
Subject: [patch 0/3] 2.6.17 radix-tree: updates and lockless
Date: Tue, 20 Jun 2006 16:48:17 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrew Morton <akpm@osdl.org>, Paul McKenney <Paul.McKenney@us.ibm.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I've finally ported the RCU radix tree over my radix tree direct-data patch
(the latter patch has been in -mm for a while now).

I've also done the last step required for submission, which was to make a
small userspace RCU test harness, and wire up the rtth so that it can handle
multiple threads to test the lockless capability. The RCU test harness uses
an implementation somewhat like Paul's paper's quiescent state bitmask
approach; with infrequent quiescent state updates, performance isn't bad.

This quickly flushed out several obscure bugs just when running on my dual
G5. After fixing those, I racked up about 100 CPU hours of testing on
SUSE's 64-way Altix without problem. Also passes the normal battery of
single threaded rtth tests.

I'd like to hear views regarding merging these patches for 2.6.18. Initially
the lockless code would not come into effect (good - one thing at a time)
until tree_lock can start getting lifted in -mm and 2.6.19.

Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
