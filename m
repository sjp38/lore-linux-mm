Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28C60C3A59D
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 02:47:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4AC721019
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 02:46:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="EyOdBGyu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4AC721019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFA5F6B0278; Fri, 16 Aug 2019 22:46:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BD516B0279; Fri, 16 Aug 2019 22:46:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 85A216B027A; Fri, 16 Aug 2019 22:46:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0133.hostedemail.com [216.40.44.133])
	by kanga.kvack.org (Postfix) with ESMTP id 65AD36B0278
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 22:46:52 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 0F29E1854F
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:46:52 +0000 (UTC)
X-FDA: 75830382264.09.bike66_1b0aeb508d10
X-HE-Tag: bike66_1b0aeb508d10
X-Filterd-Recvd-Size: 11466
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:46:51 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id k13so8179841qtm.12
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 19:46:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UH0zFVccGO7e1caCnvJXY2DYLwaevfd114xWoNKcSgE=;
        b=EyOdBGyufsOhE5w4xhjAwKtADSmqOJvoElKsjsXMUQVBX/cKLD3bZQH7Rm5S84S2a5
         qFCsV6m/IeOjLzNTYTnxxTR8D/VuybHo63L2/QON/5AOLlf9FLDyluolghS3jzQOZtXR
         gg5vZOtdgLn3q4oUz61XVL13j6cPzx1vo7wF6ZUvoaT/H/aS3DMUpd1cbCD4M2EbYRrL
         w2HQ2vIa+OGoQZPYZgXEg657TiLqBdPz0zMPnBdn4R98/XoHQT3oOVb4noZ15xhS7qAN
         UyArvy+DDHkpQYPIsRTlTH+Ikmiqos/QIjszrgtPR9S4R+SjFByd9fi2ONPLS/l8Ros6
         50Pw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=UH0zFVccGO7e1caCnvJXY2DYLwaevfd114xWoNKcSgE=;
        b=hizY6x3qgU9xt/zqA/FwoE+oZeV9YcqpQICDklkeRf4HzHyKXfJ/elLjRNsauyY57g
         yFU1wsjDPatZ4n8x1jy9Hz8YRkZum50QKl/lTLrWyR8Y8YspN2trIoMoJfJk18BZZVlZ
         ZS8+Tq55Ytdq+aHitR+u1Kc9hLMTuRy3Rco37xa3HC6DLdwAo+/BnQW9GKRmcuc9XcKn
         RZhUkItjHVxgsze8B6NP+B4niNHuK5dByDVFhAlnBJQufSHicke29weXJRhQcu/ofE5m
         uQ0+Ym1psLKfiKSNhik1Bj4DEMtzTX4575JwZIHauq0GhVxXhkIRZb1HCby9QEy5saez
         9g6g==
X-Gm-Message-State: APjAAAUynSQlT3aG2JkOfjiAUduN4AXFj6/dR1P13z4/g6MOy8dxm+H0
	D13JR+9xGVVjfd5McG5Iiwg6Uw==
X-Google-Smtp-Source: APXvYqzl+ZApQ07RXZDfgOqjVREU5C1UddINYXX0JoK4+KUJ7gy5Q33XOJqMAPuLdQototgzBE2jAQ==
X-Received: by 2002:ac8:7299:: with SMTP id v25mr11616966qto.381.1566010010942;
        Fri, 16 Aug 2019 19:46:50 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id o9sm3454657qtr.71.2019.08.16.19.46.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 16 Aug 2019 19:46:50 -0700 (PDT)
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
	linux-mm@kvack.org
Subject: [PATCH v2 14/14] arm64, kexec: enable MMU during kexec relocation
Date: Fri, 16 Aug 2019 22:46:29 -0400
Message-Id: <20190817024629.26611-15-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.22.1
In-Reply-To: <20190817024629.26611-1-pasha.tatashin@soleen.com>
References: <20190817024629.26611-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Now, that we have transitional page tables configured, temporarily enable
MMU to allow faster relocation of segments to final destination.

The performance data: for a moderate size kernel + initramfs: 25M the
relocation was taking 0.382s, with enabled MMU it now takes
0.019s only or x20 improvement.

The time is proportional to the size of relocation, therefore if initramf=
s
is larger, 100M it could take over a second.

Also, remove reloc_arg->head, as it is not needed anymore once MMU is
enabled.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/include/asm/kexec.h      |   2 -
 arch/arm64/kernel/asm-offsets.c     |   1 -
 arch/arm64/kernel/machine_kexec.c   |   1 -
 arch/arm64/kernel/relocate_kernel.S | 136 +++++++++++++++++-----------
 4 files changed, 84 insertions(+), 56 deletions(-)

diff --git a/arch/arm64/include/asm/kexec.h b/arch/arm64/include/asm/kexe=
c.h
index 450d8440f597..ad81ed3e5751 100644
--- a/arch/arm64/include/asm/kexec.h
+++ b/arch/arm64/include/asm/kexec.h
@@ -109,7 +109,6 @@ extern const unsigned long kexec_el1_sync_size;
 			((UL(0xffffffffffffffff) - PAGE_OFFSET) >> 1) + 1)
 /*
  * kern_reloc_arg is passed to kernel relocation function as an argument=
.
- * head		kimage->head, allows to traverse through relocation segments.
  * entry_addr	kimage->start, where to jump from relocation function (new
  *		kernel, or purgatory entry address).
  * kern_arg0	first argument to kernel is its dtb address. The other
@@ -125,7 +124,6 @@ extern const unsigned long kexec_el1_sync_size;
  * copy_len	Number of bytes that need to be copied
  */
 struct kern_reloc_arg {
-	unsigned long	head;
 	unsigned long	entry_addr;
 	unsigned long	kern_arg0;
 	unsigned long	kern_arg1;
diff --git a/arch/arm64/kernel/asm-offsets.c b/arch/arm64/kernel/asm-offs=
ets.c
index 7c2ba09a8ceb..13ad00b1b90f 100644
--- a/arch/arm64/kernel/asm-offsets.c
+++ b/arch/arm64/kernel/asm-offsets.c
@@ -129,7 +129,6 @@ int main(void)
   DEFINE(SDEI_EVENT_PRIORITY,	offsetof(struct sdei_registered_event, pri=
ority));
 #endif
 #ifdef CONFIG_KEXEC_CORE
-  DEFINE(KRELOC_HEAD,		offsetof(struct kern_reloc_arg, head));
   DEFINE(KRELOC_ENTRY_ADDR,	offsetof(struct kern_reloc_arg, entry_addr))=
;
   DEFINE(KRELOC_KERN_ARG0,	offsetof(struct kern_reloc_arg, kern_arg0));
   DEFINE(KRELOC_KERN_ARG1,	offsetof(struct kern_reloc_arg, kern_arg1));
diff --git a/arch/arm64/kernel/machine_kexec.c b/arch/arm64/kernel/machin=
e_kexec.c
index 16f761fc50c8..b5ff5fdb4777 100644
--- a/arch/arm64/kernel/machine_kexec.c
+++ b/arch/arm64/kernel/machine_kexec.c
@@ -199,7 +199,6 @@ int machine_kexec_post_load(struct kimage *kimage)
 	kimage->arch.kern_reloc =3D kern_reloc;
 	kimage->arch.kern_reloc_arg =3D __pa(kern_reloc_arg);
=20
-	kern_reloc_arg->head =3D kimage->head;
 	kern_reloc_arg->entry_addr =3D kimage->start;
 	kern_reloc_arg->el2_vector =3D el2_vector;
 	kern_reloc_arg->kern_arg0 =3D kimage->arch.dtb_mem;
diff --git a/arch/arm64/kernel/relocate_kernel.S b/arch/arm64/kernel/relo=
cate_kernel.S
index 14243a678277..96ff6760bd9c 100644
--- a/arch/arm64/kernel/relocate_kernel.S
+++ b/arch/arm64/kernel/relocate_kernel.S
@@ -4,6 +4,8 @@
  *
  * Copyright (C) Linaro.
  * Copyright (C) Huawei Futurewei Technologies.
+ * Copyright (c) 2019, Microsoft Corporation.
+ * Pavel Tatashin <patatash@linux.microsoft.com>
  */
=20
 #include <linux/kexec.h>
@@ -14,6 +16,49 @@
 #include <asm/page.h>
 #include <asm/sysreg.h>
=20
+/* Invalidae TLB */
+.macro tlb_invalidate
+	dsb	sy
+	dsb	ish
+	tlbi	vmalle1
+	dsb	ish
+	isb
+.endm
+
+/* Turn-off mmu at level specified by sctlr */
+.macro turn_off_mmu sctlr, tmp1, tmp2
+	mrs	\tmp1, \sctlr
+	ldr	\tmp2, =3DSCTLR_ELx_FLAGS
+	bic	\tmp1, \tmp1, \tmp2
+	pre_disable_mmu_workaround
+	msr	\sctlr, \tmp1
+	isb
+.endm
+
+/* Turn-on mmu at level specified by sctlr */
+.macro turn_on_mmu sctlr, tmp1, tmp2
+	mrs	\tmp1, \sctlr
+	ldr	\tmp2, =3DSCTLR_ELx_FLAGS
+	orr	\tmp1, \tmp1, \tmp2
+	msr	\sctlr, \tmp1
+	ic	iallu
+	dsb	nsh
+	isb
+.endm
+
+/*
+ * Set ttbr0 and ttbr1, called while MMU is disabled, so no need to temp=
orarily
+ * set zero_page table. Invalidate TLB after new tables are set.
+ */
+.macro set_ttbr arg, tmp
+	ldr	\tmp, [\arg, #KRELOC_TRANS_TTBR0]
+	msr	ttbr0_el1, \tmp
+	ldr	\tmp, [\arg, #KRELOC_TRANS_TTBR1]
+	offset_ttbr1 \tmp
+	msr	ttbr1_el1, \tmp
+	isb
+.endm
+
 /*
  * arm64_relocate_new_kernel - Put a 2nd stage image in place and boot i=
t.
  *
@@ -24,65 +69,52 @@
  * symbols arm64_relocate_new_kernel and arm64_relocate_new_kernel_end. =
 The
  * machine_kexec() routine will copy arm64_relocate_new_kernel to the ke=
xec
  * safe memory that has been set up to be preserved during the copy oper=
ation.
+ *
+ * This function temporarily enables MMU if kernel relocation is needed.
+ * Also, if we enter this function at EL2 on non-VHE kernel, we temporar=
ily go
+ * to EL1 to enable MMU, and escalate back to EL2 at the end to do the j=
ump to
+ * the new kernel. This is determined by presence of el2_vector.
  */
 ENTRY(arm64_relocate_new_kernel)
-	/* Clear the sctlr_el2 flags. */
-	mrs	x2, CurrentEL
-	cmp	x2, #CurrentEL_EL2
+	mrs	x1, CurrentEL
+	cmp	x1, #CurrentEL_EL2
 	b.ne	1f
-	mrs	x2, sctlr_el2
-	ldr	x1, =3DSCTLR_ELx_FLAGS
-	bic	x2, x2, x1
-	pre_disable_mmu_workaround
-	msr	sctlr_el2, x2
-	isb
-1:	/* Check if the new image needs relocation. */
-	ldr	x16, [x0, #KRELOC_HEAD]		/* x16 =3D kimage_head */
-	tbnz	x16, IND_DONE_BIT, .Ldone
-	raw_dcache_line_size x15, x1		/* x15 =3D dcache line size */
-.Lloop:
-	and	x12, x16, PAGE_MASK		/* x12 =3D addr */
-	/* Test the entry flags. */
-.Ltest_source:
-	tbz	x16, IND_SOURCE_BIT, .Ltest_indirection
-
-	/* Invalidate dest page to PoC. */
-	mov     x2, x13
-	add     x20, x2, #PAGE_SIZE
-	sub     x1, x15, #1
-	bic     x2, x2, x1
-2:	dc      ivac, x2
-	add     x2, x2, x15
-	cmp     x2, x20
-	b.lo    2b
-	dsb     sy
-
-	copy_page x13, x12, x1, x2, x3, x4, x5, x6, x7, x8
-	b	.Lnext
-.Ltest_indirection:
-	tbz	x16, IND_INDIRECTION_BIT, .Ltest_destination
-	mov	x14, x12			/* ptr =3D addr */
-	b	.Lnext
-.Ltest_destination:
-	tbz	x16, IND_DESTINATION_BIT, .Lnext
-	mov	x13, x12			/* dest =3D addr */
-.Lnext:
-	ldr	x16, [x14], #8			/* entry =3D *ptr++ */
-	tbz	x16, IND_DONE_BIT, .Lloop	/* while (!(entry & DONE)) */
-.Ldone:
-	/* wait for writes from copy_page to finish */
-	dsb	nsh
-	ic	iallu
-	dsb	nsh
-	isb
-
-	/* Start new image. */
-	ldr	x4, [x0, #KRELOC_ENTRY_ADDR]	/* x4 =3D kimage_start */
+	turn_off_mmu sctlr_el2, x1, x2		/* Turn off MMU at EL2 */
+1:	mov	x20, xzr			/* x20 will hold vector value */
+	ldr	x11, [x0, #KRELOC_COPY_LEN]
+	cbz	x11, 5f				/* Check if need to relocate */
+	ldr	x20, [x0, #KRELOC_EL2_VECTOR]
+	cbz	x20, 2f				/* need to reduce to EL1? */
+	msr	vbar_el2, x20			/* el2_vector present, means */
+	adr	x1, 2f				/* we will do copy in el1 but */
+	msr	elr_el2, x1			/* do final jump from el2 */
+	eret					/* Reduce to EL1 */
+2:	set_ttbr x0, x1				/* Set our page tables */
+	tlb_invalidate
+	turn_on_mmu sctlr_el1, x1, x2		/* Turn MMU back on */
+	ldr	x1, [x0, #KRELOC_DST_ADDR];
+	ldr	x2, [x0, #KRELOC_SRC_ADDR];
+	mov	x12, x1				/* x12 dst backup */
+3:	copy_page x1, x2, x3, x4, x5, x6, x7, x8, x9, x10
+	sub	x11, x11, #PAGE_SIZE
+	cbnz	x11, 3b				/* page copy loop */
+	raw_dcache_line_size x2, x3		/* x2 =3D dcache line size */
+	sub	x3, x2, #1			/* x3 =3D dcache_size - 1 */
+	bic	x12, x12, x3
+4:	dc	cvau, x12			/* Flush D-cache */
+	add	x12, x12, x2
+	cmp	x12, x1				/* Compare to dst + len */
+	b.ne	4b				/* D-cache flush loop */
+	turn_off_mmu sctlr_el1, x1, x2		/* Turn off MMU */
+	tlb_invalidate				/* Invalidate TLB */
+5:	ldr	x4, [x0, #KRELOC_ENTRY_ADDR]	/* x4 =3D kimage_start */
 	ldr	x3, [x0, #KRELOC_KERN_ARG3]
 	ldr	x2, [x0, #KRELOC_KERN_ARG2]
 	ldr	x1, [x0, #KRELOC_KERN_ARG1]
 	ldr	x0, [x0, #KRELOC_KERN_ARG0]	/* x0 =3D dtb address */
-	br	x4
+	cbnz	x20, 6f				/* need to escalate to el2? */
+	br	x4				/* Jump to new world */
+6:	hvc	#0				/* enters kexec_el1_sync */
 .ltorg
 .Larm64_relocate_new_kernel_end:
 END(arm64_relocate_new_kernel)
--=20
2.22.1


