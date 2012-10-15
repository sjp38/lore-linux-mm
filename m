Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id B96136B0089
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 07:24:37 -0400 (EDT)
Date: Mon, 15 Oct 2012 19:24:25 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH] firmware/memmap: avoid type conflicts with the generic
 memmap_init()
Message-ID: <20121015112425.GA14538@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Bernhard Walle <bwalle@suse.de>, Glauber Costa <glommer@parallels.com>, Linux Memory Management List <linux-mm@kvack.org>

This will fix build error:

drivers/firmware/memmap.c:240:19: error: conflicting types for 'memmap_init'
arch/ia64/include/asm/pgtable.h:565:17: note: previous declaration of 'memmap_init' was here

CC: Bernhard Walle <bwalle@suse.de>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 drivers/firmware/memmap.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
index c1cdc92..90723e6 100644
--- a/drivers/firmware/memmap.c
+++ b/drivers/firmware/memmap.c
@@ -237,7 +237,7 @@ static ssize_t memmap_attr_show(struct kobject *kobj,
  * firmware_map_add() or firmware_map_add_early() afterwards, the entries
  * are not added to sysfs.
  */
-static int __init memmap_init(void)
+static int __init firmware_memmap_init(void)
 {
 	struct firmware_map_entry *entry;
 
@@ -246,5 +246,5 @@ static int __init memmap_init(void)
 
 	return 0;
 }
-late_initcall(memmap_init);
+late_initcall(firmware_memmap_init);
 
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
