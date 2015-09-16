Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 490306B0257
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 13:49:16 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so215641999pac.0
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 10:49:16 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id ry7si27617629pbb.204.2015.09.16.10.49.06
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 10:49:06 -0700 (PDT)
Subject: [PATCH 02/26] x86, pkeys: Add Kconfig option
From: Dave Hansen <dave@sr71.net>
Date: Wed, 16 Sep 2015 10:49:04 -0700
References: <20150916174903.E112E464@viggo.jf.intel.com>
In-Reply-To: <20150916174903.E112E464@viggo.jf.intel.com>
Message-Id: <20150916174904.996E5E23@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


I don't have a strong opinion on whether we need a Kconfig prompt
or not.  Protection Keys has relatively little code associated
with it, and it is not a heavyweight feature to keep enabled.
However, I can imagine that folks would still appreciate being
able to disable it.

We will hide the prompt for now.

---

 b/arch/x86/Kconfig |    4 ++++
 1 file changed, 4 insertions(+)

diff -puN arch/x86/Kconfig~pkeys-01-kconfig arch/x86/Kconfig
--- a/arch/x86/Kconfig~pkeys-01-kconfig	2015-09-16 10:48:12.006999694 -0700
+++ b/arch/x86/Kconfig	2015-09-16 10:48:12.010999875 -0700
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
