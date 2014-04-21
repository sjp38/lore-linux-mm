Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id DF1CD6B0038
	for <linux-mm@kvack.org>; Mon, 21 Apr 2014 14:08:18 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so3929301pdi.30
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 11:08:18 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id eg2si21257408pac.305.2014.04.21.11.08.10
        for <linux-mm@kvack.org>;
        Mon, 21 Apr 2014 11:08:11 -0700 (PDT)
Subject: [PATCH] mm: debug: make bad_range() output more usable and readable
From: Dave Hansen <dave@sr71.net>
Date: Mon, 21 Apr 2014 11:07:33 -0700
Message-Id: <20140421180733.30BD5EFE@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

Nobody outputs memory addresses in decimal.  PFNs are essentially
addresses, and they're gibberish in decimal.  Output them in hex.

Also, add the nid and zone name to give a little more context to
the message.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/mm/page_alloc.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff -puN mm/page_alloc.c~range-in-hex mm/page_alloc.c
--- a/mm/page_alloc.c~range-in-hex	2014-04-21 10:11:32.274712151 -0700
+++ b/mm/page_alloc.c	2014-04-21 10:11:32.279712378 -0700
@@ -261,8 +261,9 @@ static int page_outside_zone_boundaries(
 	} while (zone_span_seqretry(zone, seq));
 
 	if (ret)
-		pr_err("page %lu outside zone [ %lu - %lu ]\n",
-			pfn, start_pfn, start_pfn + sp);
+		pr_err("page 0x%lx outside node %d zone %s [ 0x%lx - 0x%lx ]\n",
+			pfn, zone_to_nid(zone), zone->name,
+			start_pfn, start_pfn + sp);
 
 	return ret;
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
