Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 76FAC828E4
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 16:02:06 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id ho8so52462150pac.2
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 13:02:06 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id 22si17645213pfq.57.2016.02.12.13.02.00
        for <linux-mm@kvack.org>;
        Fri, 12 Feb 2016 13:02:00 -0800 (PST)
Subject: [PATCH 05/33] x86, pkeys: Add Kconfig option
From: Dave Hansen <dave@sr71.net>
Date: Fri, 12 Feb 2016 13:02:00 -0800
References: <20160212210152.9CAD15B0@viggo.jf.intel.com>
In-Reply-To: <20160212210152.9CAD15B0@viggo.jf.intel.com>
Message-Id: <20160212210200.DB7055E8@viggo.jf.intel.com>
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
--- a/arch/x86/Kconfig~pkeys-01-kconfig	2016-02-12 10:44:15.909231872 -0800
+++ b/arch/x86/Kconfig	2016-02-12 10:44:15.913232055 -0800
@@ -1713,6 +1713,10 @@ config X86_INTEL_MPX
 
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
