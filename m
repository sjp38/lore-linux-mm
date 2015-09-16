Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6306B025F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 13:49:30 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so219532412pac.2
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 10:49:30 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id rb8si42266970pbb.243.2015.09.16.10.49.09
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 10:49:09 -0700 (PDT)
Subject: [PATCH 18/26] x86, pkeys: add Kconfig prompt to existing config option
From: Dave Hansen <dave@sr71.net>
Date: Wed, 16 Sep 2015 10:49:09 -0700
References: <20150916174903.E112E464@viggo.jf.intel.com>
In-Reply-To: <20150916174903.E112E464@viggo.jf.intel.com>
Message-Id: <20150916174909.B4D79DCE@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


I don't have a strong opinion on whether we need this or not.
Protection Keys has relatively little code associated with it,
and it is not a heavyweight feature to keep enabled.  However,
I can imagine that folks would still appreciate being able to
disable it.

Here's the option if folks want it.

---

 b/arch/x86/Kconfig |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff -puN arch/x86/Kconfig~pkeys-40-kconfig-prompt arch/x86/Kconfig
--- a/arch/x86/Kconfig~pkeys-40-kconfig-prompt	2015-09-16 10:48:19.287329737 -0700
+++ b/arch/x86/Kconfig	2015-09-16 10:48:19.291329919 -0700
@@ -1696,8 +1696,18 @@ config X86_INTEL_MPX
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
