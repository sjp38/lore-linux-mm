Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 77EEA828DF
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 13:16:55 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id cy9so45107042pac.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 10:16:55 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id v18si22197212pfi.64.2016.01.29.10.16.48
        for <linux-mm@kvack.org>;
        Fri, 29 Jan 2016 10:16:48 -0800 (PST)
Subject: [PATCH 03/31] x86, pkeys: Add Kconfig option
From: Dave Hansen <dave@sr71.net>
Date: Fri, 29 Jan 2016 10:16:47 -0800
References: <20160129181642.98E7D468@viggo.jf.intel.com>
In-Reply-To: <20160129181642.98E7D468@viggo.jf.intel.com>
Message-Id: <20160129181647.02DFB684@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

I don't have a strong opinion on whether we need a Kconfig prompt
or not.  Protection Keys has relatively little code associated
with it, and it is not a heavyweight feature to keep enabled.
However, I can imagine that folks would still appreciate being
able to disable it.

Note that, with disabled-features.h, the checks in the code
for protection keys are always the same:

	cpu_has(c, X86_FEATURE_PKU)

With the config option disabled, this essentially turns into an
#ifdef.

We will hide the prompt for now.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/arch/x86/Kconfig |    4 ++++
 1 file changed, 4 insertions(+)

diff -puN arch/x86/Kconfig~pkeys-01-kconfig arch/x86/Kconfig
--- a/arch/x86/Kconfig~pkeys-01-kconfig	2016-01-28 15:52:17.645279448 -0800
+++ b/arch/x86/Kconfig	2016-01-28 15:52:17.649279631 -0800
@@ -1714,6 +1714,10 @@ config X86_INTEL_MPX
 
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
