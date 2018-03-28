Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 535B26B0266
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 12:55:58 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m18so1542752pgu.14
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 09:55:58 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id j16si2972220pff.153.2018.03.28.09.55.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 09:55:50 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 08/14] mm/page_ext: Drop definition of unused PAGE_EXT_DEBUG_POISON
Date: Wed, 28 Mar 2018 19:55:34 +0300
Message-Id: <20180328165540.648-9-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
References: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vinayak Menon <vinmenon@codeaurora.org>

After bd33ef368135 ("mm: enable page poisoning early at boot")
PAGE_EXT_DEBUG_POISON is not longer used. Remove it.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Vinayak Menon <vinmenon@codeaurora.org>
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
2.16.2
