Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1220A6B0007
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 19:01:45 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id do7so5835745pab.2
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 16:01:45 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id fm6si62871119pab.122.2016.01.06.16.01.12
        for <linux-mm@kvack.org>;
        Wed, 06 Jan 2016 16:01:12 -0800 (PST)
Subject: [PATCH 05/31] x86, pkeys: define new CR4 bit
From: Dave Hansen <dave@sr71.net>
Date: Wed, 06 Jan 2016 16:01:11 -0800
References: <20160107000104.1A105322@viggo.jf.intel.com>
In-Reply-To: <20160107000104.1A105322@viggo.jf.intel.com>
Message-Id: <20160107000111.AC9947FF@viggo.jf.intel.com>
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
--- a/arch/x86/include/uapi/asm/processor-flags.h~pkeys-02-cr4	2016-01-06 15:50:04.798119379 -0800
+++ b/arch/x86/include/uapi/asm/processor-flags.h	2016-01-06 15:50:04.801119514 -0800
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
