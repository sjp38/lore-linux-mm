Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3387C3A5A0
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:32:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48D1E216F4
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:32:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="Iy1iGa1b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48D1E216F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B75406B027B; Wed, 21 Aug 2019 14:32:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD7A66B027C; Wed, 21 Aug 2019 14:32:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99F076B027D; Wed, 21 Aug 2019 14:32:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0060.hostedemail.com [216.40.44.60])
	by kanga.kvack.org (Postfix) with ESMTP id 4F7706B027B
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:32:29 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id F325762E9
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:32:28 +0000 (UTC)
X-FDA: 75847280418.13.deer53_32b7dac6cc42b
X-HE-Tag: deer53_32b7dac6cc42b
X-Filterd-Recvd-Size: 14989
Received: from mail-qt1-f196.google.com (mail-qt1-f196.google.com [209.85.160.196])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:32:28 +0000 (UTC)
Received: by mail-qt1-f196.google.com with SMTP id v38so4306867qtb.0
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:32:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ek/psKNiEPLky43TmrYUVJvkSvC5jnPT3UFlytaaDQY=;
        b=Iy1iGa1b81fh1Fi13YtlbdONJCyl8bPNOtT4RR287nes1zMRYErVzdsFYI5zNc824f
         pzb6nDvT1FtYAq/tvqyW4vnbyDBkkLVxAVQvOZK/Oi2s4zUHDwzZeEMmF8nB3btfCwrp
         C1dSKooTRHoatauZCBh0WyBJ+peHcjXkC7gCRvY+YlC9eevNRf9dqIkWwKhB9O+Z8PeK
         tSpBBrU+XIS9Ra0/3kgRctyF7mrCNe3Kha4KXpQkVqDd8lZzOZZZn3yu/YCHvs1iZLdA
         F/PmaDLUG+1Vx1uCoQ01OVh7C8vcNDkdkGjTT86VJXtACPkChXg7gHfg/1ZjL5qL4MtA
         k/KQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ek/psKNiEPLky43TmrYUVJvkSvC5jnPT3UFlytaaDQY=;
        b=gZcyRDfDz/fTH9JkQizGWE3ZQYCNbR56Mz/ZY8eSTPiKNvbqa2vsi0XbX+y/FwZ5Dp
         Cuwptu9gLMH3CjuH4G5ZHp8USxH74xN9BJK1MPE4Cn3NSxyYwJBo2B1HvP52+U+Oo681
         MPhUl3FXDUGCDCXTchdLKjEVQc8fOefAZ3mC3OIg89uDxdPzXs31CBSZBMN9BN3mpKJ1
         9nKh4taRWjSSuSQ82Ztu6k5o8fL+3L/eK3tBQ1yabN6uMD9KvI2UFQ+OJ0BXmIlh3bjT
         ovKKlLi2o1GZHtPCpKklXrKev+YRwn+w18S9vJuvWOBkht2HxqNtaX9LpIFMfzZalnHD
         JJcQ==
X-Gm-Message-State: APjAAAUFg8XjzFyyxWDjW2Nqzq+ECTTw5iBzlrxEMsaUyjPBKQ5m1vTb
	FG0YbPvlmpQKTwhnT78WbYGbSw==
X-Google-Smtp-Source: APXvYqxFjXm2SCZNPdf2J+k8uZMngcL1fFYhkNE3bQKuqJ4Tirl8DtbEeDMXCG9RO27U1Qf3DDJAfw==
X-Received: by 2002:ac8:6112:: with SMTP id a18mr33002860qtm.272.1566412347605;
        Wed, 21 Aug 2019 11:32:27 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id q13sm10443332qkm.120.2019.08.21.11.32.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 21 Aug 2019 11:32:27 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: pasha.tatashin@soleen.com,
	jmorris@namei.org,
	sashal@kernel.org,
	ebiederm@xmission.com,
	kexec@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	corbet@lwn.net,
	catalin.marinas@arm.com,
	will@kernel.org,
	linux-arm-kernel@lists.infradead.org,
	marc.zyngier@arm.com,
	james.morse@arm.com,
	vladimir.murzin@arm.com,
	matthias.bgg@gmail.com,
	bhsharma@redhat.com,
	linux-mm@kvack.org,
	mark.rutland@arm.com
Subject: [PATCH v3 15/17] arm64, kexec: add expandable argument to relocation function
Date: Wed, 21 Aug 2019 14:32:02 -0400
Message-Id: <20190821183204.23576-16-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20190821183204.23576-1-pasha.tatashin@soleen.com>
References: <20190821183204.23576-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, kexec relocation function (arm64_relocate_new_kernel) accepts
the following arguments:

head:		start of array that contains relocation information.
entry:		entry point for new kernel or purgatory.
dtb_mem:	first and only argument to entry.

The number of arguments cannot be easily expended, because this
function is also called from HVC_SOFT_RESTART, which preserves only
three arguments. And, also arm64_relocate_new_kernel is written in
assembly but called without stack, thus no place to move extra
arguments to free registers.

Soon, we will need to pass more arguments: once we enable MMU we
will need to pass information about page tables.

Another benefit of allowing this function to accept more arguments, is th=
at
kernel can actually accept up to 4 arguments (x0-x3), however currently
only one is used, but if in the future we will need for more (for example=
,
pass information about when previous kernel exited to have a precise
measurement in time spent in purgatory), we won't be easilty do that
if arm64_relocate_new_kernel can't accept more arguments.

So, add a new struct: kern_reloc_arg, and place it in kexec safe page (i.=
e
memory that is not overwritten during relocation).
Thus, make arm64_relocate_new_kernel to only take one argument, that
contains all the needed information.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/include/asm/kexec.h      | 18 ++++++
 arch/arm64/kernel/asm-offsets.c     |  9 +++
 arch/arm64/kernel/cpu-reset.S       |  4 +-
 arch/arm64/kernel/cpu-reset.h       |  8 +--
 arch/arm64/kernel/machine_kexec.c   | 28 ++++++++-
 arch/arm64/kernel/relocate_kernel.S | 88 ++++++++++-------------------
 6 files changed, 86 insertions(+), 69 deletions(-)

diff --git a/arch/arm64/include/asm/kexec.h b/arch/arm64/include/asm/kexe=
c.h
index d15ca1ca1e83..d5b79d4c7fae 100644
--- a/arch/arm64/include/asm/kexec.h
+++ b/arch/arm64/include/asm/kexec.h
@@ -90,12 +90,30 @@ static inline void crash_prepare_suspend(void) {}
 static inline void crash_post_resume(void) {}
 #endif
=20
+/*
+ * kern_reloc_arg is passed to kernel relocation function as an argument=
.
+ * head		kimage->head, allows to traverse through relocation segments.
+ * entry_addr	kimage->start, where to jump from relocation function (new
+ *		kernel, or purgatory entry address).
+ * kern_arg0	first argument to kernel is its dtb address. The other
+ *		arguments are currently unused, and must be set to 0
+ */
+struct kern_reloc_arg {
+	unsigned long	head;
+	unsigned long	entry_addr;
+	unsigned long	kern_arg0;
+	unsigned long	kern_arg1;
+	unsigned long	kern_arg2;
+	unsigned long	kern_arg3;
+};
+
 #define ARCH_HAS_KIMAGE_ARCH
=20
 struct kimage_arch {
 	void *dtb;
 	unsigned long dtb_mem;
 	unsigned long kern_reloc;
+	unsigned long kern_reloc_arg;
 };
=20
 #ifdef CONFIG_KEXEC_FILE
diff --git a/arch/arm64/kernel/asm-offsets.c b/arch/arm64/kernel/asm-offs=
ets.c
index 214685760e1c..900394907fd8 100644
--- a/arch/arm64/kernel/asm-offsets.c
+++ b/arch/arm64/kernel/asm-offsets.c
@@ -23,6 +23,7 @@
 #include <asm/suspend.h>
 #include <linux/kbuild.h>
 #include <linux/arm-smccc.h>
+#include <linux/kexec.h>
=20
 int main(void)
 {
@@ -126,6 +127,14 @@ int main(void)
 #ifdef CONFIG_ARM_SDE_INTERFACE
   DEFINE(SDEI_EVENT_INTREGS,	offsetof(struct sdei_registered_event, inte=
rrupted_regs));
   DEFINE(SDEI_EVENT_PRIORITY,	offsetof(struct sdei_registered_event, pri=
ority));
+#endif
+#ifdef CONFIG_KEXEC_CORE
+  DEFINE(KRELOC_HEAD,		offsetof(struct kern_reloc_arg, head));
+  DEFINE(KRELOC_ENTRY_ADDR,	offsetof(struct kern_reloc_arg, entry_addr))=
;
+  DEFINE(KRELOC_KERN_ARG0,	offsetof(struct kern_reloc_arg, kern_arg0));
+  DEFINE(KRELOC_KERN_ARG1,	offsetof(struct kern_reloc_arg, kern_arg1));
+  DEFINE(KRELOC_KERN_ARG2,	offsetof(struct kern_reloc_arg, kern_arg2));
+  DEFINE(KRELOC_KERN_ARG3,	offsetof(struct kern_reloc_arg, kern_arg3));
 #endif
   return 0;
 }
diff --git a/arch/arm64/kernel/cpu-reset.S b/arch/arm64/kernel/cpu-reset.=
S
index 6ea337d464c4..64c78a42919f 100644
--- a/arch/arm64/kernel/cpu-reset.S
+++ b/arch/arm64/kernel/cpu-reset.S
@@ -43,9 +43,7 @@ ENTRY(__cpu_soft_restart)
 	hvc	#0				// no return
=20
 1:	mov	x18, x1				// entry
-	mov	x0, x2				// arg0
-	mov	x1, x3				// arg1
-	mov	x2, x4				// arg2
+	mov	x0, x2				// arg
 	br	x18
 ENDPROC(__cpu_soft_restart)
=20
diff --git a/arch/arm64/kernel/cpu-reset.h b/arch/arm64/kernel/cpu-reset.=
h
index ed50e9587ad8..7a8720ff186f 100644
--- a/arch/arm64/kernel/cpu-reset.h
+++ b/arch/arm64/kernel/cpu-reset.h
@@ -11,12 +11,10 @@
 #include <asm/virt.h>
=20
 void __cpu_soft_restart(unsigned long el2_switch, unsigned long entry,
-	unsigned long arg0, unsigned long arg1, unsigned long arg2);
+			unsigned long arg);
=20
 static inline void __noreturn cpu_soft_restart(unsigned long entry,
-					       unsigned long arg0,
-					       unsigned long arg1,
-					       unsigned long arg2)
+					       unsigned long arg)
 {
 	typeof(__cpu_soft_restart) *restart;
=20
@@ -25,7 +23,7 @@ static inline void __noreturn cpu_soft_restart(unsigned=
 long entry,
 	restart =3D (void *)__pa_symbol(__cpu_soft_restart);
=20
 	cpu_install_idmap();
-	restart(el2_switch, entry, arg0, arg1, arg2);
+	restart(el2_switch, entry, arg);
 	unreachable();
 }
=20
diff --git a/arch/arm64/kernel/machine_kexec.c b/arch/arm64/kernel/machin=
e_kexec.c
index 9b41da50e6f7..d745ea2051df 100644
--- a/arch/arm64/kernel/machine_kexec.c
+++ b/arch/arm64/kernel/machine_kexec.c
@@ -43,6 +43,7 @@ static void _kexec_image_info(const char *func, int lin=
e,
 	pr_debug("    head:        %lx\n", kimage->head);
 	pr_debug("    nr_segments: %lu\n", kimage->nr_segments);
 	pr_debug("    kern_reloc: %pa\n", &kimage->arch.kern_reloc);
+	pr_debug("    kern_reloc_arg: %pa\n", &kimage->arch.kern_reloc_arg);
=20
 	for (i =3D 0; i < kimage->nr_segments; i++) {
 		pr_debug("      segment[%lu]: %016lx - %016lx, 0x%lx bytes, %lu pages\=
n",
@@ -59,14 +60,38 @@ void machine_kexec_cleanup(struct kimage *kimage)
 	/* Empty routine needed to avoid build errors. */
 }
=20
+/* Allocates pages for kexec page table */
+static void *kexec_page_alloc(void *arg)
+{
+	struct kimage *kimage =3D (struct kimage *)arg;
+	struct page *page =3D kimage_alloc_control_pages(kimage, 0);
+
+	if (!page)
+		return NULL;
+
+	return page_address(page);
+}
+
 int machine_kexec_post_load(struct kimage *kimage)
 {
 	unsigned long kern_reloc;
+	struct kern_reloc_arg *kern_reloc_arg;
=20
 	kern_reloc =3D page_to_phys(kimage->control_code_page);
 	memcpy(__va(kern_reloc), arm64_relocate_new_kernel,
 	       arm64_relocate_new_kernel_size);
+
+	kern_reloc_arg =3D kexec_page_alloc(kimage);
+	if (!kern_reloc_arg)
+		return -ENOMEM;
+	memset(kern_reloc_arg, 0, sizeof(struct kern_reloc_arg));
+
 	kimage->arch.kern_reloc =3D kern_reloc;
+	kimage->arch.kern_reloc_arg =3D __pa(kern_reloc_arg);
+
+	kern_reloc_arg->head =3D kimage->head;
+	kern_reloc_arg->entry_addr =3D kimage->start;
+	kern_reloc_arg->kern_arg0 =3D kimage->arch.dtb_mem;
=20
 	kexec_image_info(kimage);
 	return 0;
@@ -203,8 +228,7 @@ void machine_kexec(struct kimage *kimage)
 	 * userspace (kexec-tools).
 	 * In kexec_file case, the kernel starts directly without purgatory.
 	 */
-	cpu_soft_restart(kimage->arch.kern_reloc, kimage->head, kimage->start,
-			 kimage->arch.dtb_mem);
+	cpu_soft_restart(kimage->arch.kern_reloc, kimage->arch.kern_reloc_arg);
=20
 	BUG(); /* Should never get here. */
 }
diff --git a/arch/arm64/kernel/relocate_kernel.S b/arch/arm64/kernel/relo=
cate_kernel.S
index c1d7db71a726..d352faf7cbe6 100644
--- a/arch/arm64/kernel/relocate_kernel.S
+++ b/arch/arm64/kernel/relocate_kernel.S
@@ -8,7 +8,7 @@
=20
 #include <linux/kexec.h>
 #include <linux/linkage.h>
-
+#include <asm/asm-offsets.h>
 #include <asm/assembler.h>
 #include <asm/kexec.h>
 #include <asm/page.h>
@@ -17,86 +17,58 @@
 /*
  * arm64_relocate_new_kernel - Put a 2nd stage image in place and boot i=
t.
  *
- * The memory that the old kernel occupies may be overwritten when copin=
g the
+ * The memory that the old kernel occupies may be overwritten when copyi=
ng the
  * new image to its final location.  To assure that the
  * arm64_relocate_new_kernel routine which does that copy is not overwri=
tten,
  * all code and data needed by arm64_relocate_new_kernel must be between=
 the
  * symbols arm64_relocate_new_kernel and arm64_relocate_new_kernel_end. =
 The
  * machine_kexec() routine will copy arm64_relocate_new_kernel to the ke=
xec
- * control_code_page, a special page which has been set up to be preserv=
ed
- * during the copy operation.
+ * safe memory that has been set up to be preserved during the copy oper=
ation.
  */
 ENTRY(arm64_relocate_new_kernel)
-
-	/* Setup the list loop variables. */
-	mov	x18, x2				/* x18 =3D dtb address */
-	mov	x17, x1				/* x17 =3D kimage_start */
-	mov	x16, x0				/* x16 =3D kimage_head */
-	raw_dcache_line_size x15, x0		/* x15 =3D dcache line size */
-	mov	x14, xzr			/* x14 =3D entry ptr */
-	mov	x13, xzr			/* x13 =3D copy dest */
-
 	/* Clear the sctlr_el2 flags. */
-	mrs	x0, CurrentEL
-	cmp	x0, #CurrentEL_EL2
+	mrs	x2, CurrentEL
+	cmp	x2, #CurrentEL_EL2
 	b.ne	1f
-	mrs	x0, sctlr_el2
+	mrs	x2, sctlr_el2
 	ldr	x1, =3DSCTLR_ELx_FLAGS
-	bic	x0, x0, x1
+	bic	x2, x2, x1
 	pre_disable_mmu_workaround
-	msr	sctlr_el2, x0
+	msr	sctlr_el2, x2
 	isb
-1:
-
-	/* Check if the new image needs relocation. */
+1:	/* Check if the new image needs relocation. */
+	ldr	x16, [x0, #KRELOC_HEAD]		/* x16 =3D kimage_head */
 	tbnz	x16, IND_DONE_BIT, .Ldone
-
+	raw_dcache_line_size x15, x1		/* x15 =3D dcache line size */
 .Lloop:
 	and	x12, x16, PAGE_MASK		/* x12 =3D addr */
-
 	/* Test the entry flags. */
 .Ltest_source:
 	tbz	x16, IND_SOURCE_BIT, .Ltest_indirection
=20
 	/* Invalidate dest page to PoC. */
-	mov     x0, x13
-	add     x20, x0, #PAGE_SIZE
+	mov     x2, x13
+	add     x20, x2, #PAGE_SIZE
 	sub     x1, x15, #1
-	bic     x0, x0, x1
-2:	dc      ivac, x0
-	add     x0, x0, x15
-	cmp     x0, x20
+	bic     x2, x2, x1
+2:	dc      ivac, x2
+	add     x2, x2, x15
+	cmp     x2, x20
 	b.lo    2b
 	dsb     sy
=20
-	mov x20, x13
-	mov x21, x12
-	copy_page x20, x21, x0, x1, x2, x3, x4, x5, x6, x7
-
-	/* dest +=3D PAGE_SIZE */
-	add	x13, x13, PAGE_SIZE
+	copy_page x13, x12, x1, x2, x3, x4, x5, x6, x7, x8
 	b	.Lnext
-
 .Ltest_indirection:
 	tbz	x16, IND_INDIRECTION_BIT, .Ltest_destination
-
-	/* ptr =3D addr */
-	mov	x14, x12
+	mov	x14, x12			/* ptr =3D addr */
 	b	.Lnext
-
 .Ltest_destination:
 	tbz	x16, IND_DESTINATION_BIT, .Lnext
-
-	/* dest =3D addr */
-	mov	x13, x12
-
+	mov	x13, x12			/* dest =3D addr */
 .Lnext:
-	/* entry =3D *ptr++ */
-	ldr	x16, [x14], #8
-
-	/* while (!(entry & DONE)) */
-	tbz	x16, IND_DONE_BIT, .Lloop
-
+	ldr	x16, [x14], #8			/* entry =3D *ptr++ */
+	tbz	x16, IND_DONE_BIT, .Lloop	/* while (!(entry & DONE)) */
 .Ldone:
 	/* wait for writes from copy_page to finish */
 	dsb	nsh
@@ -105,18 +77,16 @@ ENTRY(arm64_relocate_new_kernel)
 	isb
=20
 	/* Start new image. */
-	mov	x0, x18
-	mov	x1, xzr
-	mov	x2, xzr
-	mov	x3, xzr
-	br	x17
-
-ENDPROC(arm64_relocate_new_kernel)
+	ldr	x4, [x0, #KRELOC_ENTRY_ADDR]	/* x4 =3D kimage_start */
+	ldr	x3, [x0, #KRELOC_KERN_ARG3]
+	ldr	x2, [x0, #KRELOC_KERN_ARG2]
+	ldr	x1, [x0, #KRELOC_KERN_ARG1]
+	ldr	x0, [x0, #KRELOC_KERN_ARG0]	/* x0 =3D dtb address */
+	br	x4
+END(arm64_relocate_new_kernel)
=20
 .ltorg
-
 .align 3	/* To keep the 64-bit values below naturally aligned. */
-
 .Lcopy_end:
 .org	KEXEC_CONTROL_PAGE_SIZE
=20
--=20
2.23.0


