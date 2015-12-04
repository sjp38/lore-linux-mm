Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 43E9E6B0258
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 20:14:39 -0500 (EST)
Received: by pfu207 with SMTP id 207so17245976pfu.2
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 17:14:39 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 187si15438678pfa.195.2015.12.03.17.14.32
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 17:14:32 -0800 (PST)
Subject: [PATCH 05/34] x86, pkeys: define new CR4 bit
From: Dave Hansen <dave@sr71.net>
Date: Thu, 03 Dec 2015 17:14:32 -0800
References: <20151204011424.8A36E365@viggo.jf.intel.com>
In-Reply-To: <20151204011424.8A36E365@viggo.jf.intel.com>
Message-Id: <20151204011432.06D9EA27@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

There is a new bit in CR4 for enabling protection keys.  We
will actually enable it later in the series.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/arch/x86/include/uapi/asm/processor-flags.h |    2 ++
 1 file changed, 2 insertions(+)

diff -puN arch/x86/include/uapi/asm/processor-flags.h~pkeys-02-cr4 arch/x86/include/uapi/asm/processor-flags.h
--- a/arch/x86/include/uapi/asm/processor-flags.h~pkeys-02-cr4	2015-12-03 16:21:20.345431800 -0800
+++ b/arch/x86/include/uapi/asm/processor-flags.h	2015-12-03 16:21:20.348431936 -0800
@@ -118,6 +118,8 @@
 #define X86_CR4_SMEP		_BITUL(X86_CR4_SMEP_BIT)
 #define X86_CR4_SMAP_BIT	21 /* enable SMAP support */
 #define X86_CR4_SMAP		_BITUL(X86_CR4_SMAP_BIT)
+#define X86_CR4_PKE_BIT		22 /* enable Protection Keys support */
+#define X86_CR4_PKE		_BITUL(X86_CR4_PKE_BIT)
 
 /*
  * x86-64 Task Priority Register, CR8
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
