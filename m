Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2231FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:17:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6F74213A2
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:17:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="figi3DEp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6F74213A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C08168E0015; Tue, 12 Mar 2019 18:16:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B90EE8E0011; Tue, 12 Mar 2019 18:16:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A34DE8E0015; Tue, 12 Mar 2019 18:16:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3D1B18E0011
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:16:28 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id g7so1248943wrp.23
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:16:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=QZsl/Ru3+/IhFFfMtEstuOanA3qKYxjkILWkI1v0IwY=;
        b=guzMJ1tatsNmGV/b0IwZqMXt8OrDNwzucviC6W+g+9chpLiQyHKTByS3UsbS/2YrsT
         61DimWmzU5hcxnBA875JmIG5H34TJH/7N6TugJ6wa2bgeXkdGqFYKu/va6uQ7AuTLvFf
         79dDsXHx0zl7tCIdZNXO7SodaUSJ3B/z9OGKDjZ7anNrafwqGz6j/2i4vqjgNZHd8eNE
         ZAVdDgvV+1zFnfuUSeQ9DRkNQvFv7+unoSA8S1z1gE93UdhmJQN1c8PYXlU9yhslrm3l
         c/clYoniKlj7dJ/DFMGQyvQZs8FeoznpeFB5lerqtqzlMVcNRGDoa29eOvJhOKYw+Msd
         4DUQ==
X-Gm-Message-State: APjAAAUGATGYrqtKTDOLWDpuy2ywSl4q9h/ugCM3vTYnjSm+vgkQroCp
	AszvjI+opqHpBGpSJbhZ/lLd6wqhu8LC2lkzKfktxqgBpDpHBsa6/G4DxJYjCyH+R2NhUKyqmFv
	z02wURWe6M8UGKHRwYyZBKZtrmhTshM69YO1UXB3wb8EQlg2Z9Yunsw33ZuKcRXUHeA==
X-Received: by 2002:adf:ce90:: with SMTP id r16mr25111039wrn.64.1552428987437;
        Tue, 12 Mar 2019 15:16:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTet7ufUUnl6TDPejvpGn1GO9EuUMlhohV8/ZDE9j2RcrFkIehNLsrFZf0MlCv7CSzYo11
X-Received: by 2002:adf:ce90:: with SMTP id r16mr25110962wrn.64.1552428985393;
        Tue, 12 Mar 2019 15:16:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552428985; cv=none;
        d=google.com; s=arc-20160816;
        b=vBer8mQ5hxYXMaqChFc39S9M+lWMU5gAH2MZb/rZvnksvkfnmTzC9zF3huA83zbSV/
         cr7ypYIEiK3RtWROBP5b4IsC/qzdaE32jEeTCaRz5Td0iEX7AOlJtLLEueY6sqlj8Kpo
         Yjn4n9rYRZKTHFOTBMtqqj7TQoiE6FefAJe4ViaOejHseJVrWC6Ebol/jAaYlxW704J1
         b/fUo2HIPiRMyV2kKf/jkX9MOqEX5I6bQFl1sct35O9PJykWwmZT9VdAt6eXn+6Vr5n/
         st40dyiyjhzni1EIKiMj342eF70hVRPB7YqRYeicuBviOeSDKvxC+UthbwDeOYUYaxSU
         ukLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=QZsl/Ru3+/IhFFfMtEstuOanA3qKYxjkILWkI1v0IwY=;
        b=BCHc0xNVZPQYY5axSQQtWiMfTtchfbJ0MlyVksK/cUxBxxst03kwz5Xl+bqHSq34NO
         0AaWXex5y5DW9VugXHtS9NaIKqQR5HHGOi8BmlJSfQGYaofo960qYhZQbGiwkfvt9lG7
         K8XJkb12wHos3liiNBD/dh69AweoPUxXlOBUwkEqE2vgvG4DXVkOZeUFobSHvOZGNoGT
         HqBw41UHseTtVizylgZRJwepF2ec4PNgv/AE/Ve+MilgLbdszzFwM4sMB3ZRsOwItOp8
         3gjCLK1gRQOXoZD7xWGy1TYJFkZqnFZwsAmHxY8YVfsLx0VB19JOdnJzt6NE+saCRD+U
         BCUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=figi3DEp;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id a18si5973236wrx.194.2019.03.12.15.16.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 15:16:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=figi3DEp;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44Jq7X5bKZz9tyls;
	Tue, 12 Mar 2019 23:16:24 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=figi3DEp; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id EVsQyKb7Wlnp; Tue, 12 Mar 2019 23:16:24 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44Jq7X4F2Qz9tyll;
	Tue, 12 Mar 2019 23:16:24 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1552428984; bh=QZsl/Ru3+/IhFFfMtEstuOanA3qKYxjkILWkI1v0IwY=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=figi3DEpy672YkUFS5X5eRxrv3Kb0CtlE9a5CafpdoUrGP3PGVQVNX4d+D3E1G271
	 dWDd15Av7efTvva1yHz6GRkWTpS0/R+LQzi4PWx1pIsSH1lebvRD5klY7hPx0K2hl4
	 yG8aJxXwHoNWyd4eIfknHOxH1lUOUVOhxq25BwPw=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id C675F8B8B1;
	Tue, 12 Mar 2019 23:16:24 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id mAvbpiVo68Nq; Tue, 12 Mar 2019 23:16:24 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 827728B8A7;
	Tue, 12 Mar 2019 23:16:24 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 3CB036FA15; Tue, 12 Mar 2019 22:16:24 +0000 (UTC)
Message-Id: <3e97aba429c769bd99ccd8d6f16eda98f7d378a7.1552428161.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1552428161.git.christophe.leroy@c-s.fr>
References: <cover.1552428161.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH RFC v3 18/18] powerpc: KASAN for 64bit Book3E
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 12 Mar 2019 22:16:24 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Daniel Axtens <dja@axtens.net>

Wire up KASAN. Only outline instrumentation is supported.

The KASAN shadow area is mapped into vmemmap space:
0x8000 0400 0000 0000 to 0x8000 0600 0000 0000.
To do this we require that vmemmap be disabled. (This is the default
in the kernel config that QorIQ provides for the machine in their
SDK anyway - they use flat memory.)

Only the kernel linear mapping (0xc000...) is checked. The vmalloc and
ioremap areas (also in 0x800...) are all mapped to the zero page. As
with the Book3S hash series, this requires overriding the memory <->
shadow mapping.

Also, as with both previous 64-bit series, early instrumentation is not
supported.  It would allow us to drop the check_return_arch_not_ready()
hook in the KASAN core, but it's tricky to get it set up early enough:
we need it setup before the first call to instrumented code like printk().
Perhaps in the future.

Only KASAN_MINIMAL works.

Tested on e6500. KVM, kexec and xmon have not been tested.

The test_kasan module fires warnings as expected, except for the
following tests:

 - Expected/by design:
kasan test: memcg_accounted_kmem_cache allocate memcg accounted object

 - Due to only supporting KASAN_MINIMAL:
kasan test: kasan_stack_oob out-of-bounds on stack
kasan test: kasan_global_oob out-of-bounds global variable
kasan test: kasan_alloca_oob_left out-of-bounds to left on alloca
kasan test: kasan_alloca_oob_right out-of-bounds to right on alloca
kasan test: use_after_scope_test use-after-scope on int
kasan test: use_after_scope_test use-after-scope on array

Thanks to those who have done the heavy lifting over the past several
years:
 - Christophe's 32 bit series: https://lists.ozlabs.org/pipermail/linuxppc-dev/2019-February/185379.html
 - Aneesh's Book3S hash series: https://lwn.net/Articles/655642/
 - Balbir's Book3S radix series: https://patchwork.ozlabs.org/patch/795211/

Cc: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Balbir Singh <bsingharora@gmail.com>
Signed-off-by: Daniel Axtens <dja@axtens.net>
[- Removed EXPORT_SYMBOL of the static key
 - Fixed most checkpatch problems
 - Replaced kasan_zero_page[] by kasan_early_shadow_page[]
 - Reduced casting mess by using intermediate locals
 - Fixed build failure on pmac32_defconfig]
Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/Kconfig                         |  1 +
 arch/powerpc/Kconfig.debug                   |  2 +-
 arch/powerpc/include/asm/kasan.h             | 71 ++++++++++++++++++++++++++++
 arch/powerpc/mm/Makefile                     |  2 +
 arch/powerpc/mm/kasan/Makefile               |  1 +
 arch/powerpc/mm/kasan/kasan_init_book3e_64.c | 50 ++++++++++++++++++++
 6 files changed, 126 insertions(+), 1 deletion(-)
 create mode 100644 arch/powerpc/mm/kasan/kasan_init_book3e_64.c

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index d9364368329b..51ef9fac6c5d 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -174,6 +174,7 @@ config PPC
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_ARCH_JUMP_LABEL
 	select HAVE_ARCH_KASAN			if PPC32
+	select HAVE_ARCH_KASAN			if PPC_BOOK3E_64 && !SPARSEMEM_VMEMMAP
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_MMAP_RND_BITS
 	select HAVE_ARCH_MMAP_RND_COMPAT_BITS	if COMPAT
diff --git a/arch/powerpc/Kconfig.debug b/arch/powerpc/Kconfig.debug
index 61febbbdd02b..fc1f5fa7554e 100644
--- a/arch/powerpc/Kconfig.debug
+++ b/arch/powerpc/Kconfig.debug
@@ -369,5 +369,5 @@ config PPC_FAST_ENDIAN_SWITCH
 
 config KASAN_SHADOW_OFFSET
 	hex
-	depends on KASAN
+	depends on KASAN && PPC32
 	default 0xe0000000
diff --git a/arch/powerpc/include/asm/kasan.h b/arch/powerpc/include/asm/kasan.h
index 296e51c2f066..ae410f0e060d 100644
--- a/arch/powerpc/include/asm/kasan.h
+++ b/arch/powerpc/include/asm/kasan.h
@@ -21,12 +21,15 @@
 #define KASAN_SHADOW_START	(KASAN_SHADOW_OFFSET + \
 				 (PAGE_OFFSET >> KASAN_SHADOW_SCALE_SHIFT))
 
+#ifdef CONFIG_PPC32
 #define KASAN_SHADOW_OFFSET	ASM_CONST(CONFIG_KASAN_SHADOW_OFFSET)
 
 #define KASAN_SHADOW_END	0UL
 
 #define KASAN_SHADOW_SIZE	(KASAN_SHADOW_END - KASAN_SHADOW_START)
 
+#endif /* CONFIG_PPC32 */
+
 #ifdef CONFIG_KASAN
 void kasan_early_init(void);
 void kasan_mmu_init(void);
@@ -36,5 +39,73 @@ static inline void kasan_init(void) { }
 static inline void kasan_mmu_init(void) { }
 #endif
 
+#ifdef CONFIG_PPC_BOOK3E_64
+#include <asm/pgtable.h>
+#include <linux/jump_label.h>
+
+/*
+ * We don't put this in Kconfig as we only support KASAN_MINIMAL, and
+ * that will be disabled if the symbol is available in Kconfig
+ */
+#define KASAN_SHADOW_OFFSET	ASM_CONST(0x6800040000000000)
+
+#define KASAN_SHADOW_SIZE	(KERN_VIRT_SIZE >> KASAN_SHADOW_SCALE_SHIFT)
+
+extern struct static_key_false powerpc_kasan_enabled_key;
+extern unsigned char kasan_early_shadow_page[];
+
+static inline bool kasan_arch_is_ready_book3e(void)
+{
+	if (static_branch_likely(&powerpc_kasan_enabled_key))
+		return true;
+	return false;
+}
+#define kasan_arch_is_ready kasan_arch_is_ready_book3e
+
+static inline void *kasan_mem_to_shadow_book3e(const void *ptr)
+{
+	unsigned long addr = (unsigned long)ptr;
+
+	if (addr >= KERN_VIRT_START && addr < KERN_VIRT_START + KERN_VIRT_SIZE)
+		return kasan_early_shadow_page;
+
+	return (void *)(addr >> KASAN_SHADOW_SCALE_SHIFT) + KASAN_SHADOW_OFFSET;
+}
+#define kasan_mem_to_shadow kasan_mem_to_shadow_book3e
+
+static inline void *kasan_shadow_to_mem_book3e(const void *shadow_addr)
+{
+	/*
+	 * We map the entire non-linear virtual mapping onto the zero page so if
+	 * we are asked to map the zero page back just pick the beginning of that
+	 * area.
+	 */
+	if (shadow_addr >= (void *)kasan_early_shadow_page &&
+	    shadow_addr < (void *)(kasan_early_shadow_page + PAGE_SIZE))
+		return (void *)KERN_VIRT_START;
+
+	return (void *)(((unsigned long)shadow_addr - KASAN_SHADOW_OFFSET) <<
+			KASAN_SHADOW_SCALE_SHIFT);
+}
+#define kasan_shadow_to_mem kasan_shadow_to_mem_book3e
+
+static inline bool kasan_addr_has_shadow_book3e(const void *ptr)
+{
+	unsigned long addr = (unsigned long)ptr;
+
+	/*
+	 * We want to specifically assert that the addresses in the 0x8000...
+	 * region have a shadow, otherwise they are considered by the kasan
+	 * core to be wild pointers
+	 */
+	if (addr >= KERN_VIRT_START && addr < (KERN_VIRT_START + KERN_VIRT_SIZE))
+		return true;
+
+	return (ptr >= kasan_shadow_to_mem((void *)KASAN_SHADOW_START));
+}
+#define kasan_addr_has_shadow kasan_addr_has_shadow_book3e
+
+#endif /* CONFIG_PPC_BOOK3E_64 */
+
 #endif /* __ASSEMBLY */
 #endif
diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
index 80382a2d169b..fc49231f807c 100644
--- a/arch/powerpc/mm/Makefile
+++ b/arch/powerpc/mm/Makefile
@@ -8,9 +8,11 @@ ccflags-$(CONFIG_PPC64)	:= $(NO_MINIMAL_TOC)
 CFLAGS_REMOVE_slb.o = $(CC_FLAGS_FTRACE)
 
 KASAN_SANITIZE_ppc_mmu_32.o := n
+KASAN_SANITIZE_fsl_booke_mmu.o := n
 
 ifdef CONFIG_KASAN
 CFLAGS_ppc_mmu_32.o  		+= -DDISABLE_BRANCH_PROFILING
+CFLAGS_fsl_booke_mmu.o		+= -DDISABLE_BRANCH_PROFILING
 endif
 
 obj-y				:= fault.o mem.o pgtable.o mmap.o \
diff --git a/arch/powerpc/mm/kasan/Makefile b/arch/powerpc/mm/kasan/Makefile
index 6577897673dd..f8f164ad8ade 100644
--- a/arch/powerpc/mm/kasan/Makefile
+++ b/arch/powerpc/mm/kasan/Makefile
@@ -3,3 +3,4 @@
 KASAN_SANITIZE := n
 
 obj-$(CONFIG_PPC32)           += kasan_init_32.o
+obj-$(CONFIG_PPC_BOOK3E_64)   += kasan_init_book3e_64.o
diff --git a/arch/powerpc/mm/kasan/kasan_init_book3e_64.c b/arch/powerpc/mm/kasan/kasan_init_book3e_64.c
new file mode 100644
index 000000000000..f116c211d83c
--- /dev/null
+++ b/arch/powerpc/mm/kasan/kasan_init_book3e_64.c
@@ -0,0 +1,50 @@
+// SPDX-License-Identifier: GPL-2.0
+
+#define DISABLE_BRANCH_PROFILING
+
+#include <linux/kasan.h>
+#include <linux/printk.h>
+#include <linux/memblock.h>
+#include <linux/sched/task.h>
+#include <asm/pgalloc.h>
+
+DEFINE_STATIC_KEY_FALSE(powerpc_kasan_enabled_key);
+
+static void __init kasan_init_region(struct memblock_region *reg)
+{
+	void *start = __va(reg->base);
+	void *end = __va(reg->base + reg->size);
+	unsigned long k_start, k_end, k_cur;
+
+	if (start >= end)
+		return;
+
+	k_start = (unsigned long)kasan_mem_to_shadow(start);
+	k_end = (unsigned long)kasan_mem_to_shadow(end);
+
+	for (k_cur = k_start; k_cur < k_end; k_cur += PAGE_SIZE) {
+		void *va = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+
+		map_kernel_page(k_cur, __pa(va), PAGE_KERNEL);
+	}
+	flush_tlb_kernel_range(k_start, k_end);
+}
+
+void __init kasan_init(void)
+{
+	struct memblock_region *reg;
+
+	for_each_memblock(memory, reg)
+		kasan_init_region(reg);
+
+	/* map the zero page RO */
+	map_kernel_page((unsigned long)kasan_early_shadow_page,
+			__pa(kasan_early_shadow_page), PAGE_KERNEL_RO);
+
+	/* Turn on checking */
+	static_branch_inc(&powerpc_kasan_enabled_key);
+
+	/* Enable error messages */
+	init_task.kasan_depth = 0;
+	pr_info("KASAN init done (64-bit Book3E)\n");
+}
-- 
2.13.3

