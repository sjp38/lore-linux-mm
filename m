Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 175F92802B4
	for <linux-mm@kvack.org>; Sat, 11 Nov 2017 08:26:37 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id w2so4845250pfi.20
        for <linux-mm@kvack.org>; Sat, 11 Nov 2017 05:26:37 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id g4si10759735pgo.87.2017.11.11.05.26.34
        for <linux-mm@kvack.org>;
        Sat, 11 Nov 2017 05:26:35 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v3 1/5] locking/Documentation: Remove meaningless examples and a note
Date: Sat, 11 Nov 2017 22:26:28 +0900
Message-Id: <1510406792-28676-2-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1510406792-28676-1-git-send-email-byungchul.park@lge.com>
References: <1510406792-28676-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com

crossrelease.txt is too verbose and includes two meaningless examples
and an unnecessary note. Remove them.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 Documentation/locking/crossrelease.txt | 48 +---------------------------------
 1 file changed, 1 insertion(+), 47 deletions(-)

diff --git a/Documentation/locking/crossrelease.txt b/Documentation/locking/crossrelease.txt
index bdf1423..0f8eb8a 100644
--- a/Documentation/locking/crossrelease.txt
+++ b/Documentation/locking/crossrelease.txt
@@ -281,31 +281,7 @@ causes a deadlock. The more lockdep adds dependencies, the more it
 thoroughly works. Thus Lockdep has to do its best to detect and add as
 many true dependencies into a graph as possible.
 
-For example, considering only typical locks, lockdep builds a graph like:
-
-   A -> B -
-           \
-            -> E
-           /
-   C -> D -
-
-   where A, B,..., E are different lock classes.
-
-On the other hand, under the relaxation, additional dependencies might
-be created and added. Assuming additional 'FX -> C' and 'E -> GX' are
-added thanks to the relaxation, the graph will be:
-
-         A -> B -
-                 \
-                  -> E -> GX
-                 /
-   FX -> C -> D -
-
-   where A, B,..., E, FX and GX are different lock classes, and a suffix
-   'X' is added on non-typical locks.
-
-The latter graph gives us more chances to check circular dependencies
-than the former. However, it might suffer performance degradation since
+However, it might suffer performance degradation since
 relaxing the limitation, with which design and implementation of lockdep
 can be efficient, might introduce inefficiency inevitably. So lockdep
 should provide two options, strong detection and efficient detection.
@@ -469,12 +445,6 @@ works without crossrelease for typical locks.
 
    where A, B and C are different lock classes.
 
-   NOTE: This document assumes that readers already understand how
-   lockdep works without crossrelease thus omits details. But there's
-   one thing to note. Lockdep pretends to pop a lock from held_locks
-   when releasing it. But it's subtly different from the original pop
-   operation because lockdep allows other than the top to be poped.
-
 In this case, lockdep adds 'the top of held_locks -> the lock to acquire'
 dependency every time acquiring a lock.
 
@@ -805,22 +775,6 @@ Remind what a dependency is. A dependency exists if:
 
 For example:
 
-   acquire A
-   acquire B /* A dependency 'A -> B' exists */
-   release B
-   release A
-
-   where A and B are different lock classes.
-
-A depedency 'A -> B' exists since:
-
-   1. A waiter for A and a waiter for B might exist when acquiring B.
-   2. Only way to wake up each is to release what it waits for.
-   3. Whether the waiter for A can be woken up depends on whether the
-      other can. IOW, TASK X cannot release A if it fails to acquire B.
-
-For another example:
-
    TASK X			   TASK Y
    ------			   ------
 				   acquire AX
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
