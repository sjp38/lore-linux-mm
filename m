Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3C2C46B0035
	for <linux-mm@kvack.org>; Mon, 29 Sep 2014 21:50:57 -0400 (EDT)
Received: by mail-ob0-f176.google.com with SMTP id vb8so4921683obc.35
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 18:50:57 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ku3si15061069obc.31.2014.09.29.18.50.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 29 Sep 2014 18:50:56 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH 1/5] mm: add poisoning basics
Date: Mon, 29 Sep 2014 21:47:15 -0400
Message-Id: <1412041639-23617-2-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1412041639-23617-1-git-send-email-sasha.levin@oracle.com>
References: <1412041639-23617-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, mgorman@suse.de, Sasha Levin <sasha.levin@oracle.com>

Add poisining basics along with a config option to enable poisoning.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/poison.h | 6 ++++++
 lib/Kconfig.debug      | 9 +++++++++
 2 files changed, 15 insertions(+)

diff --git a/include/linux/poison.h b/include/linux/poison.h
index 2110a81..db4d03e 100644
--- a/include/linux/poison.h
+++ b/include/linux/poison.h
@@ -86,4 +86,10 @@
 /********** sound/oss/ **********/
 #define OSS_POISON_FREE		0xAB
 
+/********** include/linux/mm_types.h **********/
+#ifdef CONFIG_DEBUG_VM_POISON
+#define MM_POISON_BEGIN		0x89ABCDEF
+#define MM_POISON_END		0xFEDCBA98
+#endif /* DEBUG_VM_POISON */
+
 #endif
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index c366c8a..3b82772 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -543,6 +543,15 @@ config DEBUG_VM_RB
 
 	  If unsure, say N.
 
+config DEBUG_VM_POISON
+	bool "Poison VM structures"
+	depends on DEBUG_VM
+	help
+	  Add poison to the beggining and end of various VM structure to
+	  detect memory corruption in VM management code.
+
+	  If unsure, say N.
+
 config DEBUG_VIRTUAL
 	bool "Debug VM translations"
 	depends on DEBUG_KERNEL && X86
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
