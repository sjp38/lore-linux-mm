Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 99BD66B003C
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 01:42:39 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id eu11so9130665pac.18
        for <linux-mm@kvack.org>; Sun, 20 Jul 2014 22:42:39 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id j3si1107912pdd.56.2014.07.20.22.42.37
        for <linux-mm@kvack.org>;
        Sun, 20 Jul 2014 22:42:38 -0700 (PDT)
From: Qiaowei Ren <qiaowei.ren@intel.com>
Subject: [PATCH v7 06/10] mips: sync struct siginfo with general version
Date: Mon, 21 Jul 2014 13:38:40 +0800
Message-Id: <1405921124-4230-7-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1405921124-4230-1-git-send-email-qiaowei.ren@intel.com>
References: <1405921124-4230-1-git-send-email-qiaowei.ren@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Qiaowei Ren <qiaowei.ren@intel.com>

Due to new fields about bound violation added into struct siginfo,
this patch syncs it with general version to avoid build issue.

Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
---
 arch/mips/include/uapi/asm/siginfo.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/arch/mips/include/uapi/asm/siginfo.h b/arch/mips/include/uapi/asm/siginfo.h
index e811744..d08f83f 100644
--- a/arch/mips/include/uapi/asm/siginfo.h
+++ b/arch/mips/include/uapi/asm/siginfo.h
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
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
