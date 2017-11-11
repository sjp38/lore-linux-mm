Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E4E52440D49
	for <linux-mm@kvack.org>; Sat, 11 Nov 2017 08:26:37 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 76so10189242pfr.3
        for <linux-mm@kvack.org>; Sat, 11 Nov 2017 05:26:37 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id i70si2436472pgc.36.2017.11.11.05.26.35
        for <linux-mm@kvack.org>;
        Sat, 11 Nov 2017 05:26:36 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v3 5/5] locking/Documentation: Align crossrelease.txt with the width
Date: Sat, 11 Nov 2017 22:26:32 +0900
Message-Id: <1510406792-28676-6-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1510406792-28676-1-git-send-email-byungchul.park@lge.com>
References: <1510406792-28676-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com

No change of contents at all. Only adjust the width.

(Please merge this to another after the review.)

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 Documentation/locking/crossrelease.txt | 59 +++++++++++++++++-----------------
 1 file changed, 30 insertions(+), 29 deletions(-)

diff --git a/Documentation/locking/crossrelease.txt b/Documentation/locking/crossrelease.txt
index dac56f4..c6d628b 100644
--- a/Documentation/locking/crossrelease.txt
+++ b/Documentation/locking/crossrelease.txt
@@ -61,9 +61,9 @@ turn cannot be triggered if event B does not happen, which in turn
 cannot be triggered if event C does not happen. After all, no event can
 be triggered since any of them never meets its condition to wake up.
 
-A dependency might exist between two waiters and a deadlock happens
-due to an incorrect relationship between dependencies. Thus, we must
-define what a dependency is first. A dependency exists if:
+A dependency might exist between two waiters and a deadlock happens due
+to an incorrect relationship between dependencies. Thus, we must define
+what a dependency is first. A dependency exists if:
 
    1. There are two waiters waiting for each event at a given time.
    2. The only way to wake up each waiter is to trigger its event.
@@ -304,10 +304,10 @@ Considering only typical locks, lockdep builds nothing. However,
 relaxing the limitation, a dependency 'A -> B' can be added, giving us
 more chances to check circular dependencies.
 
-However, it might suffer performance degradation since
-relaxing the limitation, with which design and implementation of lockdep
-can be efficient, might introduce inefficiency inevitably. So lockdep
-should provide two options, strong detection and efficient detection.
+However, it might suffer performance degradation since relaxing the
+limitation, with which design and implementation of lockdep can be
+efficient, might introduce inefficiency inevitably. So lockdep should
+provide two options, strong detection and efficient detection.
 
 Choosing efficient detection:
 
@@ -404,8 +404,8 @@ There are four types of dependencies:
 
    When acquiring BX, lockdep cannot identify the dependency because
    there's no way to know if it's in the AX's release context. It has
-   to wait until the decision can be made. Commit is necessary.
-   But, handling CC type is not implemented yet. It's a future work.
+   to wait until the decision can be made. Commit is necessary. But,
+   handling CC type is not implemented yet. It's a future work.
 
 Lockdep can work without commit for typical locks, but the step is
 necessary once crosslocks are involved. Introducing commit, lockdep
@@ -442,9 +442,9 @@ Crossrelease introduces two main data structures.
 
    This is an array embedded in task_struct, for keeping lock history so
    that dependencies can be added using them at the commit step. Since
-   they are local data, they can be accessed locklessly in the owner context.
-   The array is filled at the acquisition step and consumed at the
-   commit step. And it's managed in a circular manner.
+   they are local data, they can be accessed locklessly in the owner
+   context. The array is filled at the acquisition step and consumed at
+   the commit step. And it's managed in a circular manner.
 
 2. cross_lock
 
@@ -470,8 +470,8 @@ works for typical locks, without crossrelease.
 
    where A, B, and C are different lock classes.
 
-Lockdep adds 'the top of held_locks -> the lock to acquire'
-dependency every time acquiring a lock.
+Lockdep adds 'the top of held_locks -> the lock to acquire' dependency
+every time acquiring a lock.
 
 After adding 'A -> B', the dependency graph will be:
 
@@ -561,10 +561,10 @@ for A, B, and C, the graph will be:
    NOTE: A dependency 'A -> C' is optimized out.
 
 We can see the former graph built without the commit step is same as the
-latter graph. Of course, the former way leads to
-earlier finish for building the graph, which means we can detect a
-deadlock or its possibility sooner. So the former way would be preferred
-when possible. But we cannot avoid using the latter way for crosslocks.
+latter graph. Of course, the former way leads to earlier finish for
+building the graph, which means we can detect a deadlock or its
+possibility sooner. So the former way would be preferred when possible.
+But we cannot avoid using the latter way for crosslocks.
 
 Lastly, let's look at how commit works for crosslocks in practice.
 
@@ -685,10 +685,10 @@ Lastly, let's look at how commit works for crosslocks in practice.
 
 Crossrelease considers all acquisitions following acquiring BX because
 they can create dependencies with BX. The dependencies will be
-determined in the release context of BX. Meanwhile,
-all typical locks are queued so that they can be used at the commit step.
-Finally, two dependencies 'BX -> C' and 'BX -> E' will be added at the
-commit step, when identifying the release context.
+determined in the release context of BX. Meanwhile, all typical locks
+are queued so that they can be used at the commit step. Finally, two
+dependencies 'BX -> C' and 'BX -> E' will be added at the commit step,
+when identifying the release context.
 
 The final graph will be, with crossrelease:
 
@@ -737,8 +737,8 @@ Make hot paths lockless
 To keep all locks for later use at the commit step, crossrelease adopts
 a local array embedded in task_struct, which makes the data locklessly
 accessible by forcing it to happen only within the owner context. It's
-like how lockdep handles held_locks. Lockless implementation is important
-since typical locks are very frequently acquired and released.
+like how lockdep handles held_locks. Lockless implementation is
+important since typical locks are very frequently acquired and released.
 
 
 =================================================
@@ -751,9 +751,10 @@ deadlock exists if the problematic dependencies exist. Thus, it's
 meaningful to detect not only an actual deadlock but also its potential
 possibility. The latter is rather valuable. When a deadlock actually
 occurs, we can identify what happens in the system by some means or
-other even without lockdep. However, there's no way to detect a possibility
-without lockdep, unless the whole code is parsed in the head. It's terrible.
-Lockdep does the both, and crossrelease only focuses on the latter.
+other even without lockdep. However, there's no way to detect a
+possibility without lockdep, unless the whole code is parsed in the head.
+It's terrible. Lockdep does the both, and crossrelease only focuses on
+the latter.
 
 Whether or not a deadlock actually occurs depends on several factors.
 For example, what order contexts are switched in is a factor. Assuming
@@ -845,8 +846,8 @@ we can ensure nothing but what actually happened. Relying on what
 actually happens at runtime, we can anyway add only true ones, though
 they might be a subset of true ones. It's similar to how lockdep works
 for typical locks. There might be more true dependencies than lockdep
-has detected. Lockdep has no choice but to rely on
-what actually happens. Crossrelease also relies on it.
+has detected. Lockdep has no choice but to rely on what actually happens.
+Crossrelease also relies on it.
 
 CONCLUSION
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
