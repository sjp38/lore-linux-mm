Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 66091828DE
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 19:08:29 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id uo6so224786450pac.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 16:08:29 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id tz9si4901799pac.197.2016.01.06.16.01.40
        for <linux-mm@kvack.org>;
        Wed, 06 Jan 2016 16:01:41 -0800 (PST)
Subject: [PATCH 23/31] x86, pkeys: add Kconfig prompt to existing config option
From: Dave Hansen <dave@sr71.net>
Date: Wed, 06 Jan 2016 16:01:37 -0800
References: <20160107000104.1A105322@viggo.jf.intel.com>
In-Reply-To: <20160107000104.1A105322@viggo.jf.intel.com>
Message-Id: <20160107000137.2089F216@viggo.jf.intel.com>
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
--- a/arch/x86/Kconfig~pkeys-40-kconfig-prompt	2016-01-06 15:50:13.114494312 -0800
+++ b/arch/x86/Kconfig	2016-01-06 15:50:13.117494447 -0800
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
