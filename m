Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2A2876B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 02:58:23 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id w3-v6so13301321pgv.17
        for <linux-mm@kvack.org>; Thu, 03 May 2018 23:58:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c21-v6sor3747032pls.113.2018.05.03.23.58.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 May 2018 23:58:22 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH v2 1/2] arm64/mm: define ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
Date: Fri,  4 May 2018 14:57:48 +0800
Message-Id: <1525417069-27401-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ldufour@linux.vnet.ibm.com, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com, cpandya@codeaurora.org, punit.agrawal@arm.com
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ganesh Mahendran <opensource.ganesh@gmail.com>

Set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT for arm64. This
enables Speculative Page Fault handler.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
---
v2: remove "if SMP"
---
 arch/arm64/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index eb2cf49..b3ca29d 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -144,6 +144,7 @@ config ARM64
 	select SPARSE_IRQ
 	select SYSCTL_EXCEPTION_TRACE
 	select THREAD_INFO_IN_TASK
+	select ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
 	help
 	  ARM 64-bit (AArch64) Linux support.
 
-- 
1.9.1
