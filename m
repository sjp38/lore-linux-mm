Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 53CC86B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 14:14:36 -0400 (EDT)
Received: by laba3 with SMTP id a3so83234282lab.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 11:14:35 -0700 (PDT)
Received: from mail-lb0-x234.google.com (mail-lb0-x234.google.com. [2a00:1450:4010:c04::234])
        by mx.google.com with ESMTPS id jt9si1057620lab.77.2015.08.24.11.14.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 11:14:34 -0700 (PDT)
Received: by lbbsx3 with SMTP id sx3so85138381lbb.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 11:14:33 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH] mm/memblock: Typo fixed
Date: Tue, 25 Aug 2015 00:14:02 +0600
Message-Id: <1440440042-3709-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Robin Holt <holt@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

Typo fixed - s/succees/success

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 mm/memblock.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 87108e7..8742db8 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -758,7 +758,7 @@ int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
  *
  * This function isolates region [@base, @base + @size), and sets/clears flag
  *
- * Return 0 on succees, -errno on failure.
+ * Return 0 on success, -errno on failure.
  */
 static int __init_memblock memblock_setclr_flag(phys_addr_t base,
 				phys_addr_t size, int set, int flag)
@@ -785,7 +785,7 @@ static int __init_memblock memblock_setclr_flag(phys_addr_t base,
  * @base: the base phys addr of the region
  * @size: the size of the region
  *
- * Return 0 on succees, -errno on failure.
+ * Return 0 on success, -errno on failure.
  */
 int __init_memblock memblock_mark_hotplug(phys_addr_t base, phys_addr_t size)
 {
@@ -797,7 +797,7 @@ int __init_memblock memblock_mark_hotplug(phys_addr_t base, phys_addr_t size)
  * @base: the base phys addr of the region
  * @size: the size of the region
  *
- * Return 0 on succees, -errno on failure.
+ * Return 0 on success, -errno on failure.
  */
 int __init_memblock memblock_clear_hotplug(phys_addr_t base, phys_addr_t size)
 {
@@ -809,7 +809,7 @@ int __init_memblock memblock_clear_hotplug(phys_addr_t base, phys_addr_t size)
  * @base: the base phys addr of the region
  * @size: the size of the region
  *
- * Return 0 on succees, -errno on failure.
+ * Return 0 on success, -errno on failure.
  */
 int __init_memblock memblock_mark_mirror(phys_addr_t base, phys_addr_t size)
 {
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
