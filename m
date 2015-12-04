Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4FF0882F6E
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 20:15:16 -0500 (EST)
Received: by pfbg73 with SMTP id g73so17644525pfb.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 17:15:16 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id tq1si15460389pac.125.2015.12.03.17.14.56
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 17:14:57 -0800 (PST)
Subject: [PATCH 23/34] x86, pkeys: add Kconfig prompt to existing config option
From: Dave Hansen <dave@sr71.net>
Date: Thu, 03 Dec 2015 17:14:56 -0800
References: <20151204011424.8A36E365@viggo.jf.intel.com>
In-Reply-To: <20151204011424.8A36E365@viggo.jf.intel.com>
Message-Id: <20151204011456.A052855B@viggo.jf.intel.com>
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
---

 b/arch/x86/Kconfig |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff -puN arch/x86/Kconfig~pkeys-40-kconfig-prompt arch/x86/Kconfig
--- a/arch/x86/Kconfig~pkeys-40-kconfig-prompt	2015-12-03 16:21:28.726811905 -0800
+++ b/arch/x86/Kconfig	2015-12-03 16:21:28.730812086 -0800
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
