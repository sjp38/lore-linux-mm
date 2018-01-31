Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2FCE06B000A
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 18:04:29 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id z37so15251244qtj.15
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 15:04:29 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id r32si996368qkr.106.2018.01.31.15.04.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 15:04:28 -0800 (PST)
From: daniel.m.jordan@oracle.com
Subject: [RFC PATCH v1 02/13] mm: allow compaction to be disabled
Date: Wed, 31 Jan 2018 18:04:02 -0500
Message-Id: <20180131230413.27653-3-daniel.m.jordan@oracle.com>
In-Reply-To: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
References: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, Dave.Dice@oracle.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ldufour@linux.vnet.ibm.com, mgorman@suse.de, mhocko@kernel.org, pasha.tatashin@oracle.com, steven.sistare@oracle.com, yossi.lev@oracle.com

This is a temporary hack to avoid the non-trivial refactoring of the
compaction code that takes lru_lock in this prototype.  This refactoring
can be done later.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 mm/Kconfig | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 03ff7703d322..96412c3939c5 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -231,7 +231,6 @@ config BALLOON_COMPACTION
 # support for memory compaction
 config COMPACTION
 	bool "Allow for memory compaction"
-	def_bool y
 	select MIGRATION
 	depends on MMU
 	help
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
