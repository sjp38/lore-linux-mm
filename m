Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 538DB6B0255
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 13:49:12 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so215286714pad.1
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 10:49:12 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id rb8si42266970pbb.243.2015.09.16.10.49.05
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 10:49:05 -0700 (PDT)
Subject: [PATCH 04/26] x86, pku: define new CR4 bit
From: Dave Hansen <dave@sr71.net>
Date: Wed, 16 Sep 2015 10:49:04 -0700
References: <20150916174903.E112E464@viggo.jf.intel.com>
In-Reply-To: <20150916174903.E112E464@viggo.jf.intel.com>
Message-Id: <20150916174904.0AAA8BFC@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


There is a new bit in CR4 for enabling protection keys.  We
will actually enable it later in the series.

---

 b/arch/x86/include/uapi/asm/processor-flags.h |    2 ++
 1 file changed, 2 insertions(+)

diff -puN arch/x86/include/uapi/asm/processor-flags.h~pkeys-02-cr4 arch/x86/include/uapi/asm/processor-flags.h
--- a/arch/x86/include/uapi/asm/processor-flags.h~pkeys-02-cr4	2015-09-16 10:48:12.921041130 -0700
+++ b/arch/x86/include/uapi/asm/processor-flags.h	2015-09-16 10:48:12.924041266 -0700
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
