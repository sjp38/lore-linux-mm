Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 451216B0258
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 14:05:52 -0500 (EST)
Received: by padhk6 with SMTP id hk6so68109252pad.2
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 11:05:52 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id q65si1628976pfi.120.2015.12.14.11.05.51
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 11:05:51 -0800 (PST)
Subject: [PATCH 05/32] x86, pkeys: define new CR4 bit
From: Dave Hansen <dave@sr71.net>
Date: Mon, 14 Dec 2015 11:05:50 -0800
References: <20151214190542.39C4886D@viggo.jf.intel.com>
In-Reply-To: <20151214190542.39C4886D@viggo.jf.intel.com>
Message-Id: <20151214190550.5C2B0E4B@viggo.jf.intel.com>
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
--- a/arch/x86/include/uapi/asm/processor-flags.h~pkeys-02-cr4	2015-12-14 10:42:40.978721262 -0800
+++ b/arch/x86/include/uapi/asm/processor-flags.h	2015-12-14 10:42:40.981721397 -0800
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
