Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f42.google.com (mail-bk0-f42.google.com [209.85.214.42])
	by kanga.kvack.org (Postfix) with ESMTP id 336356B0031
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 14:26:20 -0500 (EST)
Received: by mail-bk0-f42.google.com with SMTP id w11so7436337bkz.1
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 11:26:19 -0800 (PST)
Received: from mail-lb0-x236.google.com (mail-lb0-x236.google.com [2a00:1450:4010:c04::236])
        by mx.google.com with ESMTPS id os10si5781242bkb.194.2013.12.05.11.26.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Dec 2013 11:26:19 -0800 (PST)
Received: by mail-lb0-f182.google.com with SMTP id u14so10389886lbd.27
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 11:26:18 -0800 (PST)
Date: Thu, 5 Dec 2013 20:30:50 +0100
From: Sima Baymani <sima.baymani@gmail.com>
Subject: [PATCH] mm: Add missing dependency in Kconfig
Message-ID: <20131205193050.GA13476@lovelace>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, rientjes@google.com
Cc: tangchen@cn.fujitsu.com, akpm@linux-foundation.org, aquini@redhat.com, linux-kernel@vger.kernel.org, gang.chen@asianux.com, aneesh.kumar@linux.vnet.ibm.com, isimatu.yasuaki@jp.fujitsu.com, kirill.shutemov@linux.intel.com, sjenning@linux.vnet.ibm.com, darrick.wong@oracle.com

Eliminate the following (rand)config warning by adding missing PROC_FS
dependency:
warning: (HWPOISON_INJECT && MEM_SOFT_DIRTY) selects PROC_PAGE_MONITOR
which has unmet direct dependencies (PROC_FS && MMU)

Suggested-by: David Rientjes <rientjes@google.com>
Signed-off-by: Sima Baymani <sima.baymani@gmail.com>
---
 mm/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index eb69f35..723bbe0 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -543,7 +543,7 @@ config ZSWAP
 
 config MEM_SOFT_DIRTY
 	bool "Track memory changes"
-	depends on CHECKPOINT_RESTORE && HAVE_ARCH_SOFT_DIRTY
+	depends on CHECKPOINT_RESTORE && HAVE_ARCH_SOFT_DIRTY && PROC_FS
 	select PROC_PAGE_MONITOR
 	help
 	  This option enables memory changes tracking by introducing a
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
