Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EA1236B0253
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 10:03:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e199so738154pfh.3
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 07:03:00 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id y38si4895984plh.332.2017.09.18.07.02.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Sep 2017 07:02:59 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: Fix typo in VM_MPX definition
Date: Mon, 18 Sep 2017 17:02:53 +0300
Message-Id: <20170918140253.36856-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>

There's typo in recent change of VM_MPX definition. We want it to be
VM_HIGH_ARCH_4, not VM_HIGH_ARCH_BIT_4.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Fixes: df3735c5b40f ("x86,mpx: make mpx depend on x86-64 to free up VMA flag")
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
---
 include/linux/mm.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f8c10d336e42..065d99deb847 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -240,7 +240,7 @@ extern unsigned int kobjsize(const void *objp);
 
 #if defined(CONFIG_X86_INTEL_MPX)
 /* MPX specific bounds table or bounds directory */
-# define VM_MPX		VM_HIGH_ARCH_BIT_4
+# define VM_MPX		VM_HIGH_ARCH_4
 #else
 # define VM_MPX		VM_NONE
 #endif
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
