Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8709E6B0257
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 22:56:42 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id m7so3071730obh.3
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 19:56:42 -0800 (PST)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id lb9si602629oeb.56.2016.03.07.19.56.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 19:56:42 -0800 (PST)
Received: by mail-oi0-x243.google.com with SMTP id c129so242623oif.3
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 19:56:41 -0800 (PST)
From: Li Zhang <zhlcindy@gmail.com>
Subject: [PATCH 2/2] powerpc/mm: Enable page parallel initialisation
Date: Tue,  8 Mar 2016 11:55:54 +0800
Message-Id: <1457409354-10867-3-git-send-email-zhlcindy@gmail.com>
In-Reply-To: <1457409354-10867-1-git-send-email-zhlcindy@gmail.com>
References: <1457409354-10867-1-git-send-email-zhlcindy@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Li Zhang <zhlcindy@linux.vnet.ibm.com>

From: Li Zhang <zhlcindy@linux.vnet.ibm.com>

Parallel initialisation has been enabled for X86, boot time is
improved greatly. On Power8, it is improved greatly for small
memory. Here is the result from my test on Power8 platform:

For 4GB memory: 57% is improved, boot time as the following:
with patch: 10s, without patch: 24.5s

For 50GB memory: 22% is improved, boot time as the following:
with patch: 43.8s, without patch: 56.8s

Acked-by: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Li Zhang <zhlcindy@linux.vnet.ibm.com>
---
 * Add boot time details in change log.
 * Please apply this patch after [PATCH 1/2] mm: meminit: initialise
    more memory for inode/dentry hash tables in early boot, because
   [PATCH 1/2] is to fix a bug which can be reproduced on Power.

 arch/powerpc/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 9faa18c..97d41ad 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -158,6 +158,7 @@ config PPC
 	select ARCH_HAS_DEVMEM_IS_ALLOWED
 	select HAVE_ARCH_SECCOMP_FILTER
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
+	select ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
 
 config GENERIC_CSUM
 	def_bool CPU_LITTLE_ENDIAN
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
