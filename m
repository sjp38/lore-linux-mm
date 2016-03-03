Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1B90E6B0255
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 02:02:19 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id bj10so9562751pad.2
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:02:19 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id kr9si9976038pab.190.2016.03.02.23.02.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 23:02:18 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id 184so839606pff.1
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:02:18 -0800 (PST)
From: Li Zhang <zhlcindy@gmail.com>
Subject: [PATCH RFC 2/2] powerpc/mm: Enable page parallel initialisation
Date: Thu,  3 Mar 2016 15:01:41 +0800
Message-Id: <1456988501-29046-3-git-send-email-zhlcindy@gmail.com>
In-Reply-To: <1456988501-29046-1-git-send-email-zhlcindy@gmail.com>
References: <1456988501-29046-1-git-send-email-zhlcindy@gmail.com>
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
