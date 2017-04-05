Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E78F6B03BE
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 09:38:38 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 197so6685706pfv.13
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 06:38:38 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m3si20690293pld.162.2017.04.05.06.38.37
        for <linux-mm@kvack.org>;
        Wed, 05 Apr 2017 06:38:37 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v2 9/9] arm64: kconfig: allow support for memory failure handling
Date: Wed,  5 Apr 2017 14:37:22 +0100
Message-Id: <20170405133722.6406-10-punit.agrawal@arm.com>
In-Reply-To: <20170405133722.6406-1-punit.agrawal@arm.com>
References: <20170405133722.6406-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, will.deacon@arm.com, akpm@linux-foundation.org, mark.rutland@arm.com
Cc: "Jonathan (Zhixiong) Zhang" <zjzhang@codeaurora.org>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, tbaicar@codeaurora.org, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, steve.capper@arm.com, Punit Agrawal <punit.agrawal@arm.com>

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
