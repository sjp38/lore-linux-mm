Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 20E6C830E0
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:22:08 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id wb13so146231255obb.1
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:22:08 -0800 (PST)
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com. [32.97.110.152])
        by mx.google.com with ESMTPS id f3si15291583obr.60.2016.02.08.01.22.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 01:22:06 -0800 (PST)
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 8 Feb 2016 02:22:06 -0700
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 1736019D8045
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 02:09:42 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u189LhI229294708
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 02:21:43 -0700
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u189LgYv000823
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 02:21:43 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 23/29] powerpc/mm: Move hash related mmu-*.h headers to book3s/
Date: Mon,  8 Feb 2016 14:50:35 +0530
Message-Id: <1454923241-6681-24-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/{mmu-hash32.h => book3s/32/mmu-hash.h} | 0
 arch/powerpc/include/asm/{mmu-hash64.h => book3s/64/mmu-hash.h} | 0
 arch/powerpc/include/asm/mmu.h                                  | 4 ++--
 arch/powerpc/kernel/idle_power7.S                               | 2 +-
 arch/powerpc/kvm/book3s_32_mmu_host.c                           | 2 +-
 arch/powerpc/kvm/book3s_64_mmu.c                                | 2 +-
 arch/powerpc/kvm/book3s_64_mmu_host.c                           | 2 +-
 arch/powerpc/kvm/book3s_64_mmu_hv.c                             | 2 +-
 arch/powerpc/kvm/book3s_64_vio.c                                | 2 +-
 arch/powerpc/kvm/book3s_64_vio_hv.c                             | 2 +-
 arch/powerpc/kvm/book3s_hv_rm_mmu.c                             | 2 +-
 arch/powerpc/kvm/book3s_hv_rmhandlers.S                         | 2 +-
 12 files changed, 11 insertions(+), 11 deletions(-)
 rename arch/powerpc/include/asm/{mmu-hash32.h => book3s/32/mmu-hash.h} (100%)
 rename arch/powerpc/include/asm/{mmu-hash64.h => book3s/64/mmu-hash.h} (100%)

diff --git a/arch/powerpc/include/asm/mmu-hash32.h b/arch/powerpc/include/asm/book3s/32/mmu-hash.h
similarity index 100%
rename from arch/powerpc/include/asm/mmu-hash32.h
rename to arch/powerpc/include/asm/book3s/32/mmu-hash.h
diff --git a/arch/powerpc/include/asm/mmu-hash64.h b/arch/powerpc/include/asm/book3s/64/mmu-hash.h
similarity index 100%
rename from arch/powerpc/include/asm/mmu-hash64.h
rename to arch/powerpc/include/asm/book3s/64/mmu-hash.h
diff --git a/arch/powerpc/include/asm/mmu.h b/arch/powerpc/include/asm/mmu.h
index 3d5abfe6ba67..18a1b7dbf5fb 100644
--- a/arch/powerpc/include/asm/mmu.h
+++ b/arch/powerpc/include/asm/mmu.h
@@ -182,10 +182,10 @@ static inline void assert_pte_locked(struct mm_struct *mm, unsigned long addr)
 
 #if defined(CONFIG_PPC_STD_MMU_64)
 /* 64-bit classic hash table MMU */
-#  include <asm/mmu-hash64.h>
+#include <asm/book3s/64/mmu-hash.h>
 #elif defined(CONFIG_PPC_STD_MMU_32)
 /* 32-bit classic hash table MMU */
-#  include <asm/mmu-hash32.h>
+#include <asm/book3s/32/mmu-hash.h>
 #elif defined(CONFIG_40x)
 /* 40x-style software loaded TLB */
 #  include <asm/mmu-40x.h>
diff --git a/arch/powerpc/kernel/idle_power7.S b/arch/powerpc/kernel/idle_power7.S
index cf4fb5429cf1..470ceebd2d23 100644
--- a/arch/powerpc/kernel/idle_power7.S
+++ b/arch/powerpc/kernel/idle_power7.S
@@ -19,7 +19,7 @@
 #include <asm/kvm_book3s_asm.h>
 #include <asm/opal.h>
 #include <asm/cpuidle.h>
-#include <asm/mmu-hash64.h>
+#include <asm/book3s/64/mmu-hash.h>
 
 #undef DEBUG
 
diff --git a/arch/powerpc/kvm/book3s_32_mmu_host.c b/arch/powerpc/kvm/book3s_32_mmu_host.c
index 55c4d51ea3e2..999106991a76 100644
--- a/arch/powerpc/kvm/book3s_32_mmu_host.c
+++ b/arch/powerpc/kvm/book3s_32_mmu_host.c
@@ -22,7 +22,7 @@
 
 #include <asm/kvm_ppc.h>
 #include <asm/kvm_book3s.h>
-#include <asm/mmu-hash32.h>
+#include <asm/book3s/32/mmu-hash.h>
 #include <asm/machdep.h>
 #include <asm/mmu_context.h>
 #include <asm/hw_irq.h>
diff --git a/arch/powerpc/kvm/book3s_64_mmu.c b/arch/powerpc/kvm/book3s_64_mmu.c
index 9bf7031a67ff..b9131aa1aedf 100644
--- a/arch/powerpc/kvm/book3s_64_mmu.c
+++ b/arch/powerpc/kvm/book3s_64_mmu.c
@@ -26,7 +26,7 @@
 #include <asm/tlbflush.h>
 #include <asm/kvm_ppc.h>
 #include <asm/kvm_book3s.h>
-#include <asm/mmu-hash64.h>
+#include <asm/book3s/64/mmu-hash.h>
 
 /* #define DEBUG_MMU */
 
diff --git a/arch/powerpc/kvm/book3s_64_mmu_host.c b/arch/powerpc/kvm/book3s_64_mmu_host.c
index 30fc2d83dffa..d7959b2a8b32 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_host.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_host.c
@@ -23,7 +23,7 @@
 
 #include <asm/kvm_ppc.h>
 #include <asm/kvm_book3s.h>
-#include <asm/mmu-hash64.h>
+#include <asm/book3s/64/mmu-hash.h>
 #include <asm/machdep.h>
 #include <asm/mmu_context.h>
 #include <asm/hw_irq.h>
diff --git a/arch/powerpc/kvm/book3s_64_mmu_hv.c b/arch/powerpc/kvm/book3s_64_mmu_hv.c
index fb37290a57b4..c7b78d8336b2 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_hv.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_hv.c
@@ -32,7 +32,7 @@
 #include <asm/tlbflush.h>
 #include <asm/kvm_ppc.h>
 #include <asm/kvm_book3s.h>
-#include <asm/mmu-hash64.h>
+#include <asm/book3s/64/mmu-hash.h>
 #include <asm/hvcall.h>
 #include <asm/synch.h>
 #include <asm/ppc-opcode.h>
diff --git a/arch/powerpc/kvm/book3s_64_vio.c b/arch/powerpc/kvm/book3s_64_vio.c
index 54cf9bc94dad..9c3b76bb69d9 100644
--- a/arch/powerpc/kvm/book3s_64_vio.c
+++ b/arch/powerpc/kvm/book3s_64_vio.c
@@ -30,7 +30,7 @@
 #include <asm/tlbflush.h>
 #include <asm/kvm_ppc.h>
 #include <asm/kvm_book3s.h>
-#include <asm/mmu-hash64.h>
+#include <asm/book3s/64/mmu-hash.h>
 #include <asm/hvcall.h>
 #include <asm/synch.h>
 #include <asm/ppc-opcode.h>
diff --git a/arch/powerpc/kvm/book3s_64_vio_hv.c b/arch/powerpc/kvm/book3s_64_vio_hv.c
index 89e96b3e0039..039028d3ccb5 100644
--- a/arch/powerpc/kvm/book3s_64_vio_hv.c
+++ b/arch/powerpc/kvm/book3s_64_vio_hv.c
@@ -29,7 +29,7 @@
 #include <asm/tlbflush.h>
 #include <asm/kvm_ppc.h>
 #include <asm/kvm_book3s.h>
-#include <asm/mmu-hash64.h>
+#include <asm/book3s/64/mmu-hash.h>
 #include <asm/hvcall.h>
 #include <asm/synch.h>
 #include <asm/ppc-opcode.h>
diff --git a/arch/powerpc/kvm/book3s_hv_rm_mmu.c b/arch/powerpc/kvm/book3s_hv_rm_mmu.c
index 91700518bbf3..4cb8db05f3e5 100644
--- a/arch/powerpc/kvm/book3s_hv_rm_mmu.c
+++ b/arch/powerpc/kvm/book3s_hv_rm_mmu.c
@@ -17,7 +17,7 @@
 #include <asm/tlbflush.h>
 #include <asm/kvm_ppc.h>
 #include <asm/kvm_book3s.h>
-#include <asm/mmu-hash64.h>
+#include <asm/book3s/64/mmu-hash.h>
 #include <asm/hvcall.h>
 #include <asm/synch.h>
 #include <asm/ppc-opcode.h>
diff --git a/arch/powerpc/kvm/book3s_hv_rmhandlers.S b/arch/powerpc/kvm/book3s_hv_rmhandlers.S
index 6ee26de9a1de..c613fee0b9f7 100644
--- a/arch/powerpc/kvm/book3s_hv_rmhandlers.S
+++ b/arch/powerpc/kvm/book3s_hv_rmhandlers.S
@@ -27,7 +27,7 @@
 #include <asm/asm-offsets.h>
 #include <asm/exception-64s.h>
 #include <asm/kvm_book3s_asm.h>
-#include <asm/mmu-hash64.h>
+#include <asm/book3s/64/mmu-hash.h>
 #include <asm/tm.h>
 
 #define VCPU_GPRS_TM(reg) (((reg) * ULONG_SIZE) + VCPU_GPR_TM)
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
