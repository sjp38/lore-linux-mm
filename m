Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 896B66B0291
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 10:42:31 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p29-v6so4668481pfi.19
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 07:42:31 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id l22-v6si26243115pgu.353.2018.06.07.07.42.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 07:42:30 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH 1/7] x86/cet: Add Kconfig option for user-mode Indirect Branch Tracking
Date: Thu,  7 Jun 2018 07:38:49 -0700
Message-Id: <20180607143855.3681-2-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143855.3681-1-yu-cheng.yu@intel.com>
References: <20180607143855.3681-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

The user-mode indirect branch tracking support is done mostly by
GCC to insert ENDBR64/ENDBR32 instructions at branch targets.
The kernel provides CPUID enumeration, feature MSR setup and
the allocation of legacy bitmap.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/Kconfig | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 24339a5299da..27bfbd137fbe 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1953,6 +1953,18 @@ config X86_INTEL_SHADOW_STACK_USER
 
 	  If unsure, say y.
 
+config X86_INTEL_BRANCH_TRACKING_USER
+	prompt "Intel Indirect Branch Tracking for user-mode"
+	def_bool n
+	depends on CPU_SUP_INTEL && X86_64
+	select X86_INTEL_CET
+	select ARCH_HAS_PROGRAM_PROPERTIES
+	---help---
+	  Indirect Branch Tracking provides hardware protection against return-/jmp-
+	  oriented programing attacks.
+
+	  If unsure, say y
+
 config EFI
 	bool "EFI runtime service support"
 	depends on ACPI
-- 
2.15.1
