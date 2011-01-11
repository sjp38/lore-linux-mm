Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1144F6B0092
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 18:26:00 -0500 (EST)
From: H Hartley Sweeten <hartleys@visionengravers.com>
Date: Tue, 11 Jan 2011 17:19:30 -0600
Subject: [PATCH] mm/memblock: local functions should be static
Message-ID: <0D753D10438DA54287A00B027084269764CE0E545D@AUSP01VMBX24.collaborationhost.net>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

The function memblock_overlaps_region() is only used in this file and should
be marked static.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>

---

diff --git a/mm/memblock.c b/mm/memblock.c
index 400dc62..69702ef 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -80,7 +80,8 @@ static long __init_memblock memblock_regions_adjacent(struct memblock_type *type
 	return memblock_addrs_adjacent(base1, size1, base2, size2);
 }
 
-long __init_memblock memblock_overlaps_region(struct memblock_type *type, phys_addr_t base, phys_addr_t size)
+static long __init_memblock memblock_overlaps_region(struct memblock_type *type,
+				phys_addr_t base, phys_addr_t size)
 {
 	unsigned long i;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
