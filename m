From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 2/8] arm: mem_map/max_mapnr -- init is FLATMEM use correct defines
References: <20080410103306.GA29831@shadowen.org>
Date: Thu, 10 Apr 2008 11:41:13 +0100
Message-Id: <1207824073.0@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Johannes Weiner <hannes@saeurebad.de>, Andy Whitcroft <apw@shadowen.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

The initialisation of max_mapnr is only valid if the memory
model is FLATMEM, use the appropriate define.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 arch/arm/mm/init.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)
diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index b657f17..e414e83 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -426,7 +426,7 @@ void __init mem_init(void)
 	datapages = &_end - &__data_start;
 	initpages = &__init_end - &__init_begin;
 
-#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_FLATMEM
 	max_mapnr   = virt_to_page(high_memory) - mem_map;
 #endif
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
