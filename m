Received: from midway.site ([71.117.233.155]) by xenotime.net for <linux-mm@kvack.org>; Mon, 25 Sep 2006 21:50:37 -0700
Date: Mon, 25 Sep 2006 21:48:09 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH] mm/page_alloc: use NULL instead of 0 for ptr
Message-Id: <20060925214809.e273de48.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Randy Dunlap <rdunlap@xenotime.net>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm <akpm@osdl.org>, viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Use NULL instead of 0 for pointer value, eliminate sparse warnings.

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 mm/page_alloc.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

--- linux-2618-g4.orig/mm/page_alloc.c
+++ linux-2618-g4/mm/page_alloc.c
@@ -1558,7 +1558,7 @@ static int __meminit __build_all_zonelis
 void __meminit build_all_zonelists(void)
 {
 	if (system_state == SYSTEM_BOOTING) {
-		__build_all_zonelists(0);
+		__build_all_zonelists(NULL);
 		cpuset_init_current_mems_allowed();
 	} else {
 		/* we have to stop all cpus to guaranntee there is no user


---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
