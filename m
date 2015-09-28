Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id A5A906B025A
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 15:18:25 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so186091602pac.2
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 12:18:25 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id qo8si14118536pac.117.2015.09.28.12.18.20
        for <linux-mm@kvack.org>;
        Mon, 28 Sep 2015 12:18:20 -0700 (PDT)
Subject: [PATCH 04/25] x86, pku: define new CR4 bit
From: Dave Hansen <dave@sr71.net>
Date: Mon, 28 Sep 2015 12:18:19 -0700
References: <20150928191817.035A64E2@viggo.jf.intel.com>
In-Reply-To: <20150928191817.035A64E2@viggo.jf.intel.com>
Message-Id: <20150928191818.EDCB3BED@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

There is a new bit in CR4 for enabling protection keys.  We
will actually enable it later in the series.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/x86/include/uapi/asm/processor-flags.h |    2 ++
 1 file changed, 2 insertions(+)

diff -puN arch/x86/include/uapi/asm/processor-flags.h~pkeys-02-cr4 arch/x86/include/uapi/asm/processor-flags.h
--- a/arch/x86/include/uapi/asm/processor-flags.h~pkeys-02-cr4	2015-09-28 11:39:42.787039064 -0700
+++ b/arch/x86/include/uapi/asm/processor-flags.h	2015-09-28 11:39:42.790039200 -0700
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
