Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 8C2616B006C
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 09:44:10 -0400 (EDT)
Message-ID: <50927CA0.7050907@oracle.com>
Date: Thu, 01 Nov 2012 21:44:00 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: [PATCH] Document:  s/mem_cgroup_charge/mem_cgroup_change_common/
 in memcg doc
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, yinghan@google.com

mem_cgroup_charge_common() is invoked as the entry point for cgroup limits
charge rather than mem_cgroup_charge(), as the later has been removed for years.
Update the cgroup/memory.txt to reflect this change.

Cc: Ying Han <yinghan@google.com>
Signed-off-by: Jie Liu <jeff.liu@oracle.com>
---
 Documentation/cgroups/memory.txt |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index c07f7b4..cad8606 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -144,9 +144,9 @@ Figure 1 shows the important aspects of the controller
 3. Each page has a pointer to the page_cgroup, which in turn knows the
    cgroup it belongs to
 
-The accounting is done as follows: mem_cgroup_charge() is invoked to set up
-the necessary data structures and check if the cgroup that is being charged
-is over its limit. If it is, then reclaim is invoked on the cgroup.
+The accounting is done as follows: mem_cgroup_charge_common() is invoked to
+set up the necessary data structures and check if the cgroup that is being
+charged is over its limit. If it is, then reclaim is invoked on the cgroup.
 More details can be found in the reclaim section of this document.
 If everything goes well, a page meta-data-structure called page_cgroup is
 updated. page_cgroup has its own LRU on cgroup.
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
