Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B37296B0007
	for <linux-mm@kvack.org>; Thu, 31 May 2018 09:55:05 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id e1-v6so3266212pgp.20
        for <linux-mm@kvack.org>; Thu, 31 May 2018 06:55:05 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id b66-v6si37586672plb.107.2018.05.31.06.55.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 06:55:04 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/2] mm/page_ext: Drop definition of unused PAGE_EXT_DEBUG_POISON
Date: Thu, 31 May 2018 16:54:56 +0300
Message-Id: <20180531135457.20167-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180531135457.20167-1-kirill.shutemov@linux.intel.com>
References: <20180531135457.20167-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

After bd33ef368135 ("mm: enable page poisoning early at boot")
PAGE_EXT_DEBUG_POISON is not longer used. Remove it.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Vinayak Menon <vinmenon@codeaurora.org>
---
 include/linux/page_ext.h | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
index ca5461efae2f..bbec618a614b 100644
--- a/include/linux/page_ext.h
+++ b/include/linux/page_ext.h
@@ -16,18 +16,7 @@ struct page_ext_operations {
 
 #ifdef CONFIG_PAGE_EXTENSION
 
-/*
- * page_ext->flags bits:
- *
- * PAGE_EXT_DEBUG_POISON is set for poisoned pages. This is used to
- * implement generic debug pagealloc feature. The pages are filled with
- * poison patterns and set this flag after free_pages(). The poisoned
- * pages are verified whether the patterns are not corrupted and clear
- * the flag before alloc_pages().
- */
-
 enum page_ext_flags {
-	PAGE_EXT_DEBUG_POISON,		/* Page is poisoned */
 	PAGE_EXT_DEBUG_GUARD,
 	PAGE_EXT_OWNER,
 #if defined(CONFIG_IDLE_PAGE_TRACKING) && !defined(CONFIG_64BIT)
-- 
2.17.0
