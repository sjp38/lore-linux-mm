Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1AB688D000C
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 10:01:24 -0500 (EST)
Message-Id: <20101126145411.270875001@chello.nl>
Date: Fri, 26 Nov 2010 15:39:01 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 18/21] mutex: Provide mutex_is_contended
References: <20101126143843.801484792@chello.nl>
Content-Disposition: inline; filename=mutex-is-contended.patch
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>
List-ID: <linux-mm.kvack.org>

Usable for lock-breaks and such.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/mutex.h |    5 +++++
 1 file changed, 5 insertions(+)

Index: linux-2.6/include/linux/mutex.h
===================================================================
--- linux-2.6.orig/include/linux/mutex.h
+++ linux-2.6/include/linux/mutex.h
@@ -118,6 +118,11 @@ static inline int mutex_is_locked(struct
 	return atomic_read(&lock->count) != 1;
 }
 
+static inline int mutex_is_contended(struct mutex *lock)
+{
+	return atomic_read(&lock->count) < 0;
+}
+
 /*
  * See kernel/mutex.c for detailed documentation of these APIs.
  * Also see Documentation/mutex-design.txt.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
