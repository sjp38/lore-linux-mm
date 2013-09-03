Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id BF2206B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 08:55:10 -0400 (EDT)
From: Christian Hesse <mail@eworm.de>
Subject: [PATCH 1/1] fix typos in Documentation/vm/zswap.txt
Date: Tue,  3 Sep 2013 14:54:14 +0200
Message-Id: <1378212854-15296-1-git-send-email-mail@eworm.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Christian Hesse <mail@eworm.de>

---
 Documentation/vm/zswap.txt | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/Documentation/vm/zswap.txt b/Documentation/vm/zswap.txt
index 7e492d8..00c3d31 100644
--- a/Documentation/vm/zswap.txt
+++ b/Documentation/vm/zswap.txt
@@ -8,7 +8,7 @@ significant performance improvement if reads from the compressed cache are
 faster than reads from a swap device.
 
 NOTE: Zswap is a new feature as of v3.11 and interacts heavily with memory
-reclaim.  This interaction has not be fully explored on the large set of
+reclaim.  This interaction has not been fully explored on the large set of
 potential configurations and workloads that exist.  For this reason, zswap
 is a work in progress and should be considered experimental.
 
@@ -23,7 +23,7 @@ Some potential benefits:
 A A A  drastically reducing life-shortening writes.
 
 Zswap evicts pages from compressed cache on an LRU basis to the backing swap
-device when the compressed pool reaches it size limit.  This requirement had
+device when the compressed pool reaches its size limit.  This requirement had
 been identified in prior community discussions.
 
 To enabled zswap, the "enabled" attribute must be set to 1 at boot time.  e.g.
@@ -37,7 +37,7 @@ the backing swap device in the case that the compressed pool is full.
 
 Zswap makes use of zbud for the managing the compressed memory pool.  Each
 allocation in zbud is not directly accessible by address.  Rather, a handle is
-return by the allocation routine and that handle must be mapped before being
+returned by the allocation routine and that handle must be mapped before being
 accessed.  The compressed memory pool grows on demand and shrinks as compressed
 pages are freed.  The pool is not preallocated.
 
@@ -56,7 +56,7 @@ in the swap_map goes to 0) the swap code calls the zswap invalidate function,
 via frontswap, to free the compressed entry.
 
 Zswap seeks to be simple in its policies.  Sysfs attributes allow for one user
-controlled policies:
+controlled policy:
 * max_pool_percent - The maximum percentage of memory that the compressed
     pool can occupy.
 
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
