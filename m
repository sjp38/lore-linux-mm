Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7C0656B025B
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 14:05:59 -0500 (EST)
Received: by padhk6 with SMTP id hk6so68110715pad.2
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 11:05:59 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id d3si10001434pas.116.2015.12.14.11.05.58
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 11:05:58 -0800 (PST)
Subject: [PATCH 03/32] x86, pkeys: Add Kconfig option
From: Dave Hansen <dave@sr71.net>
Date: Mon, 14 Dec 2015 11:05:47 -0800
References: <20151214190542.39C4886D@viggo.jf.intel.com>
In-Reply-To: <20151214190542.39C4886D@viggo.jf.intel.com>
Message-Id: <20151214190547.C0C1B3EB@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


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
--- a/arch/x86/Kconfig~pkeys-01-kconfig	2015-12-14 10:42:40.090681466 -0800
+++ b/arch/x86/Kconfig	2015-12-14 10:42:40.094681645 -0800
@@ -1680,6 +1680,10 @@ config X86_INTEL_MPX
 
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
