Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4487C6B02AA
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 13:11:13 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 83so24169265pfx.1
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 10:11:13 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id n5si31572270pgh.23.2016.11.01.10.11.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Nov 2016 10:11:12 -0700 (PDT)
From: Christopher Covington <cov@codeaurora.org>
Subject: [RFC v2 2/7] arm: Use generic VDSO unmap and remap
Date: Tue,  1 Nov 2016 11:10:56 -0600
Message-Id: <20161101171101.24704-2-cov@codeaurora.org>
In-Reply-To: <20161101171101.24704-1-cov@codeaurora.org>
References: <20161101171101.24704-1-cov@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: criu@openvz.org, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Christopher Covington <cov@codeaurora.org>, Russell King <linux@armlinux.org.uk>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org

Checkpoint/Restore In Userspace (CRIU) needs to be able to unmap and remap
the VDSO to successfully checkpoint and restore applications in the face of
changing VDSO addresses due to Address Space Layout Randomization (ASLR,
randmaps). Previously, this was implemented in architecture-specific code
for PowerPC and x86. However, a generic version based on Laurent Dufour's
PowerPC implementation is now available, so begin using it on ARM.

Signed-off-by: Christopher Covington <cov@codeaurora.org>
---
 arch/arm/mm/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm/mm/Kconfig b/arch/arm/mm/Kconfig
index c1799dd..1d3312b 100644
--- a/arch/arm/mm/Kconfig
+++ b/arch/arm/mm/Kconfig
@@ -845,6 +845,7 @@ config VDSO
 	depends on AEABI && MMU && CPU_V7
 	default y if ARM_ARCH_TIMER
 	select GENERIC_TIME_VSYSCALL
+	select GENERIC_VDSO
 	help
 	  Place in the process address space an ELF shared object
 	  providing fast implementations of gettimeofday and
-- 
Qualcomm Datacenter Technologies as an affiliate of Qualcomm Technologies, Inc.
Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
