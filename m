Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 326C82806CB
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 12:39:49 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id n5so51023376pgd.19
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 09:39:49 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k126si2611984pgc.159.2017.03.30.09.39.47
        for <linux-mm@kvack.org>;
        Thu, 30 Mar 2017 09:39:48 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH 4/4] arm64: kconfig: allow support for memory failure handling
Date: Thu, 30 Mar 2017 17:38:49 +0100
Message-Id: <20170330163849.18402-5-punit.agrawal@arm.com>
In-Reply-To: <20170330163849.18402-1-punit.agrawal@arm.com>
References: <20170330163849.18402-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, will.deacon@arm.com, akpm@linux-foundation.org
Cc: "Jonathan (Zhixiong) Zhang" <zjzhang@codeaurora.org>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, tbaicar@codeaurora.org, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com, Punit Agrawal <punit.agrawal@arm.com>

From: "Jonathan (Zhixiong) Zhang" <zjzhang@codeaurora.org>

If ACPI_APEI and MEMORY_FAILURE is configured, select
ACPI_APEI_MEMORY_FAILURE. This enables memory failure recovery
when such memory failure is reported through ACPI APEI. APEI
(ACPI Platform Error Interfaces) provides a means for the
platform to convey error information to the kernel.
APEI bits

Declare ARCH_SUPPORTS_MEMORY_FAILURE, as arm64 does support
memory failure recovery attempt.

Signed-off-by: Jonathan (Zhixiong) Zhang <zjzhang@codeaurora.org>
Signed-off-by: Tyler Baicar <tbaicar@codeaurora.org>
Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
---
 arch/arm64/Kconfig        | 1 +
 drivers/acpi/apei/Kconfig | 1 +
 2 files changed, 2 insertions(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 3741859765cf..993a5fd85452 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -19,6 +19,7 @@ config ARM64
 	select ARCH_HAS_STRICT_MODULE_RWX
 	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
 	select ARCH_USE_CMPXCHG_LOCKREF
+	select ARCH_SUPPORTS_MEMORY_FAILURE
 	select ARCH_SUPPORTS_ATOMIC_RMW
 	select ARCH_SUPPORTS_NUMA_BALANCING
 	select ARCH_WANT_COMPAT_IPC_PARSE_VERSION
diff --git a/drivers/acpi/apei/Kconfig b/drivers/acpi/apei/Kconfig
index b0140c8fc733..6d9a812fd3f9 100644
--- a/drivers/acpi/apei/Kconfig
+++ b/drivers/acpi/apei/Kconfig
@@ -9,6 +9,7 @@ config ACPI_APEI
 	select MISC_FILESYSTEMS
 	select PSTORE
 	select UEFI_CPER
+	select ACPI_APEI_MEMORY_FAILURE if MEMORY_FAILURE
 	depends on HAVE_ACPI_APEI
 	help
 	  APEI allows to report errors (for example from the chipset)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
