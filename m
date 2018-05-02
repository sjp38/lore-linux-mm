Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 44A696B0005
	for <linux-mm@kvack.org>; Wed,  2 May 2018 03:54:04 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id e18-v6so6554420pgt.3
        for <linux-mm@kvack.org>; Wed, 02 May 2018 00:54:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i6-v6sor1440651pgp.161.2018.05.02.00.54.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 May 2018 00:54:03 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH 1/2] arm64/mm: define ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
Date: Wed,  2 May 2018 15:53:21 +0800
Message-Id: <1525247602-1565-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ldufour@linux.vnet.ibm.com, catalin.marinas@arm.com, will.deacon@arm.com
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ganesh Mahendran <opensource.ganesh@gmail.com>

Set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT for arm64. This
enables Speculative Page Fault handler.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
---
This patch is on top of Laurent's v10 spf
---
 arch/arm64/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index eb2cf49..cd583a9 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -144,6 +144,7 @@ config ARM64
 	select SPARSE_IRQ
 	select SYSCTL_EXCEPTION_TRACE
 	select THREAD_INFO_IN_TASK
+	select ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT if SMP
 	help
 	  ARM 64-bit (AArch64) Linux support.
 
-- 
1.9.1
