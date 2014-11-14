Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id A8A1D6B00CF
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 10:18:23 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so1797860pde.20
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 07:18:23 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ca3si2471080pbb.132.2014.11.14.07.18.20
        for <linux-mm@kvack.org>;
        Fri, 14 Nov 2014 07:18:21 -0800 (PST)
Subject: [PATCH 03/11] mips: sync struct siginfo with general version
From: Dave Hansen <dave@sr71.net>
Date: Fri, 14 Nov 2014 07:18:20 -0800
References: <20141114151816.F56A3072@viggo.jf.intel.com>
In-Reply-To: <20141114151816.F56A3072@viggo.jf.intel.com>
Message-Id: <20141114151820.F7EDC3CC@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com
Cc: tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, qiaowei.ren@intel.com, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>


New fields about bound violation are added into general struct
siginfo. This will impact MIPS and IA64, which extend general
struct siginfo. This patch syncs this struct for MIPS with
general version.

Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/mips/include/uapi/asm/siginfo.h |    4 ++++
 1 file changed, 4 insertions(+)

diff -puN arch/mips/include/uapi/asm/siginfo.h~mpx-v11-mips-sync-struct-siginfo-with-general-version arch/mips/include/uapi/asm/siginfo.h
--- a/arch/mips/include/uapi/asm/siginfo.h~mpx-v11-mips-sync-struct-siginfo-with-general-version	2014-11-14 07:06:21.551576596 -0800
+++ b/arch/mips/include/uapi/asm/siginfo.h	2014-11-14 07:06:21.554576731 -0800
@@ -92,6 +92,10 @@ typedef struct siginfo {
 			int _trapno;	/* TRAP # which caused the signal */
 #endif
 			short _addr_lsb;
+			struct {
+				void __user *_lower;
+				void __user *_upper;
+			} _addr_bnd;
 		} _sigfault;
 
 		/* SIGPOLL, SIGXFSZ (To do ...)	 */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
