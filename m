Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id F3B406B13F0
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 09:22:50 -0500 (EST)
From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [trivial] mm: Fix typo in unevictable-lru.txt
Date: Wed,  8 Feb 2012 23:22:21 +0900
Message-Id: <1328710941-3349-1-git-send-email-standby24x7@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: standby24x7@gmail.com, linux-kernel@vger.kernel.org, trivial@kernel.org

Correct spelling "semphore" to "semaphore" in
Documentation/vm/unevictable-lru.txt

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 Documentation/vm/unevictable-lru.txt |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/Documentation/vm/unevictable-lru.txt b/Documentation/vm/unevictable-lru.txt
index 97bae3c..609d1a3 100644
--- a/Documentation/vm/unevictable-lru.txt
+++ b/Documentation/vm/unevictable-lru.txt
@@ -538,7 +538,7 @@ different reverse map mechanisms.
      process because mlocked pages are migratable.  However, for reclaim, if
      the page is mapped into a VM_LOCKED VMA, the scan stops.
 
-     try_to_unmap_anon() attempts to acquire in read mode the mmap semphore of
+     try_to_unmap_anon() attempts to acquire in read mode the mmap semaphore of
      the mm_struct to which the VMA belongs.  If this is successful, it will
      mlock the page via mlock_vma_page() - we wouldn't have gotten to
      try_to_unmap_anon() if the page were already mlocked - and will return
@@ -623,7 +623,7 @@ mapped file pages with an additional argument specifing unlock versus unmap
 processing.  Again, these functions walk the respective reverse maps looking
 for VM_LOCKED VMAs.  When such a VMA is found for anonymous pages and file
 pages mapped in linear VMAs, as in the try_to_unmap() case, the functions
-attempt to acquire the associated mmap semphore, mlock the page via
+attempt to acquire the associated mmap semaphore, mlock the page via
 mlock_vma_page() and return SWAP_MLOCK.  This effectively undoes the
 pre-clearing of the page's PG_mlocked done by munlock_vma_page.
 
@@ -641,7 +641,7 @@ with it - the usual fallback position.
 Note that try_to_munlock()'s reverse map walk must visit every VMA in a page's
 reverse map to determine that a page is NOT mapped into any VM_LOCKED VMA.
 However, the scan can terminate when it encounters a VM_LOCKED VMA and can
-successfully acquire the VMA's mmap semphore for read and mlock the page.
+successfully acquire the VMA's mmap semaphore for read and mlock the page.
 Although try_to_munlock() might be called a great many times when munlocking a
 large region or tearing down a large address space that has been mlocked via
 mlockall(), overall this is a fairly rare event.
-- 
1.7.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
