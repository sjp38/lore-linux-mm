Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 42B096B02AC
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 13:11:15 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id rt15so35362588pab.5
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 10:11:15 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id c19si31514508pgk.260.2016.11.01.10.11.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Nov 2016 10:11:14 -0700 (PDT)
From: Christopher Covington <cov@codeaurora.org>
Subject: [RFC v2 4/7] arm64: Use generic VDSO unmap and remap functions
Date: Tue,  1 Nov 2016 11:10:58 -0600
Message-Id: <20161101171101.24704-4-cov@codeaurora.org>
In-Reply-To: <20161101171101.24704-1-cov@codeaurora.org>
References: <20161101171101.24704-1-cov@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: criu@openvz.org, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Christopher Covington <cov@codeaurora.org>, Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org

Checkpoint/Restore In Userspace (CRIU) must be able to remap and unmap the
Virtual Dynamic Shared Object (VDSO) to be able to handle the changing
addresses that result from address space layout randomization. Now that
generic support is available and arm64 has adopted unsigned long for the
type of mm->context.vdso, opt-in to VDSO unmap and remap support.

Signed-off-by: Christopher Covington <cov@codeaurora.org>
---
 arch/arm64/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 969ef88..534df3f 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -50,6 +50,7 @@ config ARM64
 	select GENERIC_STRNCPY_FROM_USER
 	select GENERIC_STRNLEN_USER
 	select GENERIC_TIME_VSYSCALL
+	select GENERIC_VDSO
 	select HANDLE_DOMAIN_IRQ
 	select HARDIRQS_SW_RESEND
 	select HAVE_ALIGNED_STRUCT_PAGE if SLUB
-- 
Qualcomm Datacenter Technologies as an affiliate of Qualcomm Technologies, Inc.
Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
