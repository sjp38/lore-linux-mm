Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 43CCD6B00E9
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 12:05:46 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so13312483pab.12
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 09:05:46 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id rb7si23313768pab.142.2014.11.12.09.05.43
        for <linux-mm@kvack.org>;
        Wed, 12 Nov 2014 09:05:44 -0800 (PST)
Subject: [PATCH 04/11] ia64: sync struct siginfo with general version
From: Dave Hansen <dave@sr71.net>
Date: Wed, 12 Nov 2014 09:04:56 -0800
References: <20141112170443.B4BD0899@viggo.jf.intel.com>
In-Reply-To: <20141112170443.B4BD0899@viggo.jf.intel.com>
Message-Id: <20141112170456.AD302D1B@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com
Cc: tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, qiaowei.ren@intel.com, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>


New fields about bound violation are added into general struct
siginfo. This will impact MIPS and IA64, which extend general
struct siginfo. This patch syncs this struct for IA64 with
general version.

Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/ia64/include/uapi/asm/siginfo.h |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff -puN arch/ia64/include/uapi/asm/siginfo.h~2014-10-14-08_12-ia64-sync-struct-siginfo-with-general-version arch/ia64/include/uapi/asm/siginfo.h
--- a/arch/ia64/include/uapi/asm/siginfo.h~2014-10-14-08_12-ia64-sync-struct-siginfo-with-general-version	2014-11-12 08:49:24.584830328 -0800
+++ b/arch/ia64/include/uapi/asm/siginfo.h	2014-11-12 08:49:24.587830463 -0800
@@ -63,6 +63,10 @@ typedef struct siginfo {
 			unsigned int _flags;	/* see below */
 			unsigned long _isr;	/* isr */
 			short _addr_lsb;	/* lsb of faulting address */
+			struct {
+				void __user *_lower;
+				void __user *_upper;
+			} _addr_bnd;
 		} _sigfault;
 
 		/* SIGPOLL */
@@ -110,9 +114,9 @@ typedef struct siginfo {
 /*
  * SIGSEGV si_codes
  */
-#define __SEGV_PSTKOVF	(__SI_FAULT|3)	/* paragraph stack overflow */
+#define __SEGV_PSTKOVF	(__SI_FAULT|4)	/* paragraph stack overflow */
 #undef NSIGSEGV
-#define NSIGSEGV	3
+#define NSIGSEGV	4
 
 #undef NSIGTRAP
 #define NSIGTRAP	4
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
