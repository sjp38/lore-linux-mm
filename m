Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id B0CF36B006E
	for <linux-mm@kvack.org>; Sun, 12 Oct 2014 00:51:32 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id z10so3847940pdj.40
        for <linux-mm@kvack.org>; Sat, 11 Oct 2014 21:51:32 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ak3si7386016pbc.91.2014.10.11.21.51.31
        for <linux-mm@kvack.org>;
        Sat, 11 Oct 2014 21:51:31 -0700 (PDT)
From: Qiaowei Ren <qiaowei.ren@intel.com>
Subject: [PATCH v9 02/12] x86, mpx: rename cfg_reg_u and status_reg
Date: Sun, 12 Oct 2014 12:41:45 +0800
Message-Id: <1413088915-13428-3-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, Qiaowei Ren <qiaowei.ren@intel.com>

According to Intel SDM extension, MPX configuration and status registers
should be BNDCFGU and BNDSTATUS. This patch renames cfg_reg_u and
status_reg to bndcfgu and bndstatus.

Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
---
 arch/x86/include/asm/processor.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index eb71ec7..020142f 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -379,8 +379,8 @@ struct bndregs_struct {
 } __packed;
 
 struct bndcsr_struct {
-	u64 cfg_reg_u;
-	u64 status_reg;
+	u64 bndcfgu;
+	u64 bndstatus;
 } __packed;
 
 struct xsave_hdr_struct {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
