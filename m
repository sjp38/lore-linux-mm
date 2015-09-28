Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id B8B766B0259
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 15:18:21 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so186090426pac.2
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 12:18:21 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id xu3si30678164pab.194.2015.09.28.12.18.20
        for <linux-mm@kvack.org>;
        Mon, 28 Sep 2015 12:18:20 -0700 (PDT)
Subject: [PATCH 02/25] x86, pkeys: Add Kconfig option
From: Dave Hansen <dave@sr71.net>
Date: Mon, 28 Sep 2015 12:18:18 -0700
References: <20150928191817.035A64E2@viggo.jf.intel.com>
In-Reply-To: <20150928191817.035A64E2@viggo.jf.intel.com>
Message-Id: <20150928191818.3378A6C9@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

I don't have a strong opinion on whether we need a Kconfig prompt
or not.  Protection Keys has relatively little code associated
with it, and it is not a heavyweight feature to keep enabled.
However, I can imagine that folks would still appreciate being
able to disable it.

We will hide the prompt for now.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/x86/Kconfig |    4 ++++
 1 file changed, 4 insertions(+)

diff -puN arch/x86/Kconfig~pkeys-01-kconfig arch/x86/Kconfig
--- a/arch/x86/Kconfig~pkeys-01-kconfig	2015-09-28 11:39:41.883997985 -0700
+++ b/arch/x86/Kconfig	2015-09-28 11:39:41.887998167 -0700
@@ -1694,6 +1694,10 @@ config X86_INTEL_MPX
 
 	  If unsure, say N.
 
+config X86_INTEL_MEMORY_PROTECTION_KEYS
+	def_bool y
+	depends on CPU_SUP_INTEL && X86_64
+
 config EFI
 	bool "EFI runtime service support"
 	depends on ACPI
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
