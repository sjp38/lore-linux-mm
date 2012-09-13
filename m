Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id EAF686B0177
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 16:21:02 -0400 (EDT)
Date: Thu, 13 Sep 2012 16:21:04 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm] enable CONFIG_COMPACTION by default
Message-ID: <20120913162104.1458bea2@cuia.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>

Now that lumpy reclaim has been removed, compaction is the
only way left to free up contiguous memory areas. It is time
to just enable CONFIG_COMPACTION by default.
    
Signed-off-by: Rik van Riel <riel@redhat.com>

diff --git a/mm/Kconfig b/mm/Kconfig
index d5c8019..32ea0ef 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -191,6 +191,7 @@ config SPLIT_PTLOCK_CPUS
 # support for memory compaction
 config COMPACTION
 	bool "Allow for memory compaction"
+	def_bool y
 	select MIGRATION
 	depends on MMU
 	help

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
