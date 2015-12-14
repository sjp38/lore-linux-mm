Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1AD586B026C
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 14:06:33 -0500 (EST)
Received: by pfnn128 with SMTP id n128so110001583pfn.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 11:06:32 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id t74si18779133pfa.170.2015.12.14.11.06.21
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 11:06:21 -0800 (PST)
Subject: [PATCH 23/32] x86, pkeys: add Kconfig prompt to existing config option
From: Dave Hansen <dave@sr71.net>
Date: Mon, 14 Dec 2015 11:06:20 -0800
References: <20151214190542.39C4886D@viggo.jf.intel.com>
In-Reply-To: <20151214190542.39C4886D@viggo.jf.intel.com>
Message-Id: <20151214190620.1EEBABDF@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

I don't have a strong opinion on whether we need this or not.
Protection Keys has relatively little code associated with it,
and it is not a heavyweight feature to keep enabled.  However,
I can imagine that folks would still appreciate being able to
disable it.

Here's the option if folks want it.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/arch/x86/Kconfig |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff -puN arch/x86/Kconfig~pkeys-40-kconfig-prompt arch/x86/Kconfig
--- a/arch/x86/Kconfig~pkeys-40-kconfig-prompt	2015-12-14 10:42:49.213090279 -0800
+++ b/arch/x86/Kconfig	2015-12-14 10:42:49.216090413 -0800
@@ -1682,8 +1682,18 @@ config X86_INTEL_MPX
 	  If unsure, say N.
 
 config X86_INTEL_MEMORY_PROTECTION_KEYS
+	prompt "Intel Memory Protection Keys"
 	def_bool y
+	# Note: only available in 64-bit mode
 	depends on CPU_SUP_INTEL && X86_64
+	---help---
+	  Memory Protection Keys provides a mechanism for enforcing
+	  page-based protections, but without requiring modification of the
+	  page tables when an application changes protection domains.
+
+	  For details, see Documentation/x86/protection-keys.txt
+
+	  If unsure, say y.
 
 config EFI
 	bool "EFI runtime service support"
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
