Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1DEA7828DF
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 13:17:39 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id cy9so45115871pac.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 10:17:39 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id g25si25627515pfd.215.2016.01.29.10.17.16
        for <linux-mm@kvack.org>;
        Fri, 29 Jan 2016 10:17:16 -0800 (PST)
Subject: [PATCH 23/31] x86, pkeys: add Kconfig prompt to existing config option
From: Dave Hansen <dave@sr71.net>
Date: Fri, 29 Jan 2016 10:17:15 -0800
References: <20160129181642.98E7D468@viggo.jf.intel.com>
In-Reply-To: <20160129181642.98E7D468@viggo.jf.intel.com>
Message-Id: <20160129181715.1EA81AC7@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


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
--- a/arch/x86/Kconfig~pkeys-40-kconfig-prompt	2016-01-28 15:52:26.863702069 -0800
+++ b/arch/x86/Kconfig	2016-01-28 15:52:26.867702253 -0800
@@ -1716,8 +1716,18 @@ config X86_INTEL_MPX
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
