Date: Tue, 11 Sep 2007 16:25:07 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: [PATCH -mm] mm: Fix memory hotplug + sparsemem build.
Message-ID: <20070911072507.GB19260@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Building with CONFIG_MEMORY_HOTPLUG_SPARSE enabled results in:

  CC      mm/memory_hotplug.o
mm/memory_hotplug.c: In function 'online_pages':
mm/memory_hotplug.c:215: error: 'struct zone' has no member named 'node'
make[1]: *** [mm/memory_hotplug.o] Error 1
make: *** [mm] Error 2

Fix it up.

Signed-off-by: Paul Mundt <lethal@linux-sh.org>

--

 mm/memory_hotplug.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.23-rc4-mm1.orig/mm/memory_hotplug.c	2007-09-11 15:15:56.000000000 +0900
+++ linux-2.6.23-rc4-mm1/mm/memory_hotplug.c	2007-09-11 16:20:03.000000000 +0900
@@ -212,7 +212,7 @@
 	zone->present_pages += onlined_pages;
 	zone->zone_pgdat->node_present_pages += onlined_pages;
 	if (onlined_pages)
-		node_set_state(zone->node, N_HIGH_MEMORY);
+		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
 
 	setup_per_zone_pages_min();
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
