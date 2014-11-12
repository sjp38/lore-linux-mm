Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 1CF976B00EA
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 12:06:00 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id hz1so2131357pad.41
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 09:05:59 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ju5si11084205pbb.184.2014.11.12.09.05.57
        for <linux-mm@kvack.org>;
        Wed, 12 Nov 2014 09:05:58 -0800 (PST)
Subject: [PATCH 03/11] mips: sync struct siginfo with general version
From: Dave Hansen <dave@sr71.net>
Date: Wed, 12 Nov 2014 09:04:53 -0800
References: <20141112170443.B4BD0899@viggo.jf.intel.com>
In-Reply-To: <20141112170443.B4BD0899@viggo.jf.intel.com>
Message-Id: <20141112170453.04589D81@viggo.jf.intel.com>
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

diff -puN arch/mips/include/uapi/asm/siginfo.h~2014-10-14-07_12-mips-sync-struct-siginfo-with-general-version arch/mips/include/uapi/asm/siginfo.h
--- a/arch/mips/include/uapi/asm/siginfo.h~2014-10-14-07_12-mips-sync-struct-siginfo-with-general-version	2014-11-12 08:49:24.242814903 -0800
+++ b/arch/mips/include/uapi/asm/siginfo.h	2014-11-12 08:49:24.245815038 -0800
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
