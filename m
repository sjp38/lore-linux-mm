Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id A933A6B0253
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 21:36:15 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id ir4so64120394igb.1
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 18:36:15 -0800 (PST)
Received: from bogon.localdomain ([219.143.95.81])
        by mx.google.com with ESMTP id n6si16028689igk.95.2016.03.07.18.36.14
        for <linux-mm@kvack.org>;
        Mon, 07 Mar 2016 18:36:15 -0800 (PST)
From: Li Zhang <zhlcindy@gmail.com>
Subject: [PATCH RFC 2/2] powerpc/mm: Enable page parallel initialisation
Date: Wed,  2 Mar 2016 16:49:37 +0800
Message-Id: <1456908577-4702-3-git-send-email-zhlcindy@gmail.com>
In-Reply-To: <1456908577-4702-1-git-send-email-zhlcindy@gmail.com>
References: <1456908577-4702-1-git-send-email-zhlcindy@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, mgorman@techsingularity.net
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Li Zhang <zhlcindy@linux.vnet.ibm.com>

From: Li Zhang <zhlcindy@linux.vnet.ibm.com>

Parallel initialisation has been enabled for X86,
boot time is improved greatly.
On Power8, for small memory, it is improved greatly.
Here is the result from my test on Power8 platform:

For 4GB memory: 57% is improved
For 50GB memory: 22% is improve

Signed-off-by: Li Zhang <zhlcindy@linux.vnet.ibm.com>
---
 arch/powerpc/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index e4824fd..83073c2 100644
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
