Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1838EC0650F
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 09:35:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2F64206E0
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 09:35:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2F64206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F0A36B0003; Mon,  1 Jul 2019 05:35:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A1628E0003; Mon,  1 Jul 2019 05:35:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 590B28E0002; Mon,  1 Jul 2019 05:35:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f77.google.com (mail-ed1-f77.google.com [209.85.208.77])
	by kanga.kvack.org (Postfix) with ESMTP id 046EC6B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 05:35:38 -0400 (EDT)
Received: by mail-ed1-f77.google.com with SMTP id k15so16437308eda.6
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 02:35:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=oi/Lav8rHr+u9vVgDvPAlC9VunnwuctmNgE6YBWZMrs=;
        b=htuGNc8x/xBFHPSRTcHOeGNBYq7nQivhDloCNGEqVJ9xocjeuU3RsD6HZcpI+tp0pL
         KF2S3arLkdjzA9dwJg71JBZPvXkKhXJLQDPptT9BsE2OX0FixudY/cv14o/5CVUaNv0l
         xryHm6P8O7GpnkNm+8+99c4bD7HvZH1AvE9M56391ne1ZGOwJ6guSUJA5thkZ6jnrNOa
         HCHQgf6XXeU21XfBZ6MQsIOPEF7xGf6vbkYdPZrK41w6FKf4rAwgNK/3lvZLYFQdp2xz
         EKanDaNJBKiwNIivJKLnIngQbcuHYtg9N3kG7i95KzzQM6Ux0ARz4YrG6xJeXAhrFYg3
         20qQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVfom2O6gwMkkhb1ZuGhBaXWZTWcJVgpVLMyieJlR9LcnrZqcsh
	81p7E28UvIvZZSOBpEaaYYS9J3DCAesW7XqbvIXY/RAwA/P6Esha5Nyn3ldvn05xVLqySupS0dw
	rRPkmmDstA5ZKpi9LOx3KczHZsX5YofVRYqTFT0HNTVXXTrDItpgl2aPN7+CMSmbDSg==
X-Received: by 2002:a50:86b7:: with SMTP id r52mr28470123eda.100.1561973737562;
        Mon, 01 Jul 2019 02:35:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwk8c7s31Nw1oDpf5dJfo8+D2sak8hZY3Ll1LpmZqSQbYFU5zJ8JbB2BVLk5rRadJopaQqw
X-Received: by 2002:a50:86b7:: with SMTP id r52mr28470004eda.100.1561973735918;
        Mon, 01 Jul 2019 02:35:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561973735; cv=none;
        d=google.com; s=arc-20160816;
        b=LIHkzaWgIWXfoq7dultdqyIMi79aYNIZcc9vwKtE2jCQZtCbQ8/5KM46dXPjqBFRKa
         L+J6SCfvXSVYHquAZk+vQiUhzkudWvvLHn5QPsO0YAcz/5nmM0u2oSjcXQl4v6cz8DiJ
         vYswGR5hEUVlQyyULv5VLmKwHOBDRz9Zh5E5lfs2Nr3a/vcMi/gRCupdt4l8OqTtjsvl
         9zcx3a//viGcS3y0PPtWMu4f0Qs+K4ZpGUG1D5YIzOc93lrxEdsu/irHj94Dw6x4Qow5
         5/zAmtwOh8Wo+l9nqspDpg1MLM8KbK6oWQCIg1sTzswHxlH91xfVAWc3y2cHm2KfwkcP
         ASWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=oi/Lav8rHr+u9vVgDvPAlC9VunnwuctmNgE6YBWZMrs=;
        b=lXJ0oUevsNRE9/qFjZhLBujPt96jm4V976uYsqZB7OrXOtKEWmP5TNE/cL8nwuwWmv
         iecAneK41apmdfT8oyx3jwRs6CaJHY7IJQppwAC9Vtc8ZurY0vUjNFBmMGs/5exHmJkW
         BtehqtCvMiK73h948tAsqTcb5A/Kd8aeiXKvusbuhC2Mcpzf8DpHFJIryiY4qS+KSRlQ
         fOUjbTFBOdyMRacfYeo0PM5H7M6mIvysLxlguviU6rY+Y7s9l5k+h8a2ds/AzeS/boYZ
         bZJj88rYhk+X6RazsOOxO6B1hRtkFAjCx0fb6Ux5T0RGN4RJWiDtNzHZ2dpr7+LuxNU8
         B8MQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id 53si8954907edu.386.2019.07.01.02.35.35
        for <linux-mm@kvack.org>;
        Mon, 01 Jul 2019 02:35:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E13352B;
	Mon,  1 Jul 2019 02:35:34 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.42.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 18BE23F718;
	Mon,  1 Jul 2019 02:35:32 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org,
	linux@roeck-us.net
Subject: [DRAFT] mm/kprobes: Add generic kprobe_fault_handler() fallback definition
Date: Mon,  1 Jul 2019 15:05:57 +0530
Message-Id: <1561973757-5445-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <78863cd0-8cb5-c4fd-ed06-b1136bdbb6ef@arm.com>
References: <78863cd0-8cb5-c4fd-ed06-b1136bdbb6ef@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Architectures like parisc enable CONFIG_KROBES without having a definition
for kprobe_fault_handler() which results in a build failure. Arch needs to
provide kprobe_fault_handler() as it is platform specific and cannot have
a generic working alternative. But in the event when platform lacks such a
definition there needs to be a fallback.

This adds a stub kprobe_fault_handler() definition which not only prevents
a build failure but also makes sure that kprobe_page_fault() if called will
always return negative in absence of a sane platform specific alternative.

While here wrap kprobe_page_fault() in CONFIG_KPROBES. This enables stud
definitions for generic kporbe_fault_handler() and kprobes_built_in() can
just be dropped. Only on x86 it needs to be added back locally as it gets
used in a !CONFIG_KPROBES function do_general_protection().

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
I am planning to go with approach unless we just want to implement a stub
definition for parisc to get around the build problem for now.

Hello Guenter,

Could you please test this in your parisc setup. Thank you.

- Anshuman

 arch/arc/include/asm/kprobes.h     |  1 +
 arch/arm/include/asm/kprobes.h     |  1 +
 arch/arm64/include/asm/kprobes.h   |  1 +
 arch/ia64/include/asm/kprobes.h    |  1 +
 arch/mips/include/asm/kprobes.h    |  1 +
 arch/powerpc/include/asm/kprobes.h |  1 +
 arch/s390/include/asm/kprobes.h    |  1 +
 arch/sh/include/asm/kprobes.h      |  1 +
 arch/sparc/include/asm/kprobes.h   |  1 +
 arch/x86/include/asm/kprobes.h     |  6 ++++++
 include/linux/kprobes.h            | 32 ++++++++++++++++++------------
 11 files changed, 34 insertions(+), 13 deletions(-)

diff --git a/arch/arc/include/asm/kprobes.h b/arch/arc/include/asm/kprobes.h
index 2134721dce44..ee8efe256675 100644
--- a/arch/arc/include/asm/kprobes.h
+++ b/arch/arc/include/asm/kprobes.h
@@ -45,6 +45,7 @@ struct kprobe_ctlblk {
 	struct prev_kprobe prev_kprobe;
 };
 
+#define kprobe_fault_handler kprobe_fault_handler
 int kprobe_fault_handler(struct pt_regs *regs, unsigned long cause);
 void kretprobe_trampoline(void);
 void trap_is_kprobe(unsigned long address, struct pt_regs *regs);
diff --git a/arch/arm/include/asm/kprobes.h b/arch/arm/include/asm/kprobes.h
index 213607a1f45c..660f877b989f 100644
--- a/arch/arm/include/asm/kprobes.h
+++ b/arch/arm/include/asm/kprobes.h
@@ -38,6 +38,7 @@ struct kprobe_ctlblk {
 	struct prev_kprobe prev_kprobe;
 };
 
+#define kprobe_fault_handler kprobe_fault_handler
 void arch_remove_kprobe(struct kprobe *);
 int kprobe_fault_handler(struct pt_regs *regs, unsigned int fsr);
 int kprobe_exceptions_notify(struct notifier_block *self,
diff --git a/arch/arm64/include/asm/kprobes.h b/arch/arm64/include/asm/kprobes.h
index 97e511d645a2..667773f75616 100644
--- a/arch/arm64/include/asm/kprobes.h
+++ b/arch/arm64/include/asm/kprobes.h
@@ -42,6 +42,7 @@ struct kprobe_ctlblk {
 	struct kprobe_step_ctx ss_ctx;
 };
 
+#define kprobe_fault_handler kprobe_fault_handler
 void arch_remove_kprobe(struct kprobe *);
 int kprobe_fault_handler(struct pt_regs *regs, unsigned int fsr);
 int kprobe_exceptions_notify(struct notifier_block *self,
diff --git a/arch/ia64/include/asm/kprobes.h b/arch/ia64/include/asm/kprobes.h
index c5cf5e4fb338..c321e8585089 100644
--- a/arch/ia64/include/asm/kprobes.h
+++ b/arch/ia64/include/asm/kprobes.h
@@ -106,6 +106,7 @@ struct arch_specific_insn {
 	unsigned short slot;
 };
 
+#define kprobe_fault_handler kprobe_fault_handler
 extern int kprobe_fault_handler(struct pt_regs *regs, int trapnr);
 extern int kprobe_exceptions_notify(struct notifier_block *self,
 				    unsigned long val, void *data);
diff --git a/arch/mips/include/asm/kprobes.h b/arch/mips/include/asm/kprobes.h
index 68b1e5d458cf..d1efe991ea22 100644
--- a/arch/mips/include/asm/kprobes.h
+++ b/arch/mips/include/asm/kprobes.h
@@ -40,6 +40,7 @@ do {									\
 
 #define kretprobe_blacklist_size 0
 
+#define kprobe_fault_handler kprobe_fault_handler
 void arch_remove_kprobe(struct kprobe *p);
 int kprobe_fault_handler(struct pt_regs *regs, int trapnr);
 
diff --git a/arch/powerpc/include/asm/kprobes.h b/arch/powerpc/include/asm/kprobes.h
index 66b3f2983b22..c94f375ec957 100644
--- a/arch/powerpc/include/asm/kprobes.h
+++ b/arch/powerpc/include/asm/kprobes.h
@@ -84,6 +84,7 @@ struct arch_optimized_insn {
 	kprobe_opcode_t *insn;
 };
 
+#define kprobe_fault_handler kprobe_fault_handler
 extern int kprobe_exceptions_notify(struct notifier_block *self,
 					unsigned long val, void *data);
 extern int kprobe_fault_handler(struct pt_regs *regs, int trapnr);
diff --git a/arch/s390/include/asm/kprobes.h b/arch/s390/include/asm/kprobes.h
index b106aa29bf55..0ecaebb78092 100644
--- a/arch/s390/include/asm/kprobes.h
+++ b/arch/s390/include/asm/kprobes.h
@@ -73,6 +73,7 @@ struct kprobe_ctlblk {
 void arch_remove_kprobe(struct kprobe *p);
 void kretprobe_trampoline(void);
 
+#define kprobe_fault_handler kprobe_fault_handler
 int kprobe_fault_handler(struct pt_regs *regs, int trapnr);
 int kprobe_exceptions_notify(struct notifier_block *self,
 	unsigned long val, void *data);
diff --git a/arch/sh/include/asm/kprobes.h b/arch/sh/include/asm/kprobes.h
index 6171682f7798..637a698393c0 100644
--- a/arch/sh/include/asm/kprobes.h
+++ b/arch/sh/include/asm/kprobes.h
@@ -45,6 +45,7 @@ struct kprobe_ctlblk {
 	struct prev_kprobe prev_kprobe;
 };
 
+#define kprobe_fault_handler kprobe_fault_handler
 extern int kprobe_fault_handler(struct pt_regs *regs, int trapnr);
 extern int kprobe_exceptions_notify(struct notifier_block *self,
 				    unsigned long val, void *data);
diff --git a/arch/sparc/include/asm/kprobes.h b/arch/sparc/include/asm/kprobes.h
index bfcaa6326c20..9aa4d25a45a8 100644
--- a/arch/sparc/include/asm/kprobes.h
+++ b/arch/sparc/include/asm/kprobes.h
@@ -47,6 +47,7 @@ struct kprobe_ctlblk {
 	struct prev_kprobe prev_kprobe;
 };
 
+#define kprobe_fault_handler kprobe_fault_handler
 int kprobe_exceptions_notify(struct notifier_block *self,
 			     unsigned long val, void *data);
 int kprobe_fault_handler(struct pt_regs *regs, int trapnr);
diff --git a/arch/x86/include/asm/kprobes.h b/arch/x86/include/asm/kprobes.h
index 5dc909d9ad81..1af2b6db13bd 100644
--- a/arch/x86/include/asm/kprobes.h
+++ b/arch/x86/include/asm/kprobes.h
@@ -101,11 +101,17 @@ struct kprobe_ctlblk {
 	struct prev_kprobe prev_kprobe;
 };
 
+#define kprobe_fault_handler kprobe_fault_handler
 extern int kprobe_fault_handler(struct pt_regs *regs, int trapnr);
 extern int kprobe_exceptions_notify(struct notifier_block *self,
 				    unsigned long val, void *data);
 extern int kprobe_int3_handler(struct pt_regs *regs);
 extern int kprobe_debug_handler(struct pt_regs *regs);
+#else
+static inline int kprobe_fault_handler(struct pt_regs *regs, int trapnr)
+{
+	return 0;
+}
 
 #endif /* CONFIG_KPROBES */
 #endif /* _ASM_X86_KPROBES_H */
diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
index 04bdaf01112c..e106f3018804 100644
--- a/include/linux/kprobes.h
+++ b/include/linux/kprobes.h
@@ -182,11 +182,19 @@ DECLARE_PER_CPU(struct kprobe_ctlblk, kprobe_ctlblk);
 /*
  * For #ifdef avoidance:
  */
-static inline int kprobes_built_in(void)
+
+/*
+ * Architectures need to override this with their own implementation
+ * if they care to call kprobe_page_fault(). This will just ensure
+ * that kprobe_page_fault() returns false when called without having
+ * a proper platform specific definition for kprobe_fault_handler().
+ */
+#ifndef kprobe_fault_handler
+static inline int kprobe_fault_handler(struct pt_regs *regs, int trapnr)
 {
-	return 1;
+	return 0;
 }
-
+#endif
 #ifdef CONFIG_KRETPROBES
 extern void arch_prepare_kretprobe(struct kretprobe_instance *ri,
 				   struct pt_regs *regs);
@@ -375,14 +383,6 @@ void free_insn_page(void *page);
 
 #else /* !CONFIG_KPROBES: */
 
-static inline int kprobes_built_in(void)
-{
-	return 0;
-}
-static inline int kprobe_fault_handler(struct pt_regs *regs, int trapnr)
-{
-	return 0;
-}
 static inline struct kprobe *get_kprobe(void *addr)
 {
 	return NULL;
@@ -458,12 +458,11 @@ static inline bool is_kprobe_optinsn_slot(unsigned long addr)
 }
 #endif
 
+#ifdef CONFIG_KPROBES
 /* Returns true if kprobes handled the fault */
 static nokprobe_inline bool kprobe_page_fault(struct pt_regs *regs,
 					      unsigned int trap)
 {
-	if (!kprobes_built_in())
-		return false;
 	if (user_mode(regs))
 		return false;
 	/*
@@ -476,5 +475,12 @@ static nokprobe_inline bool kprobe_page_fault(struct pt_regs *regs,
 		return false;
 	return kprobe_fault_handler(regs, trap);
 }
+#else
+static nokprobe_inline bool kprobe_page_fault(struct pt_regs *regs,
+					      unsigned int trap)
+{
+	return false;
+}
+#endif
 
 #endif /* _LINUX_KPROBES_H */
-- 
2.20.1

