Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1BBCA6B060D
	for <linux-mm@kvack.org>; Thu, 10 May 2018 09:54:34 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b25-v6so1185791pfn.10
        for <linux-mm@kvack.org>; Thu, 10 May 2018 06:54:34 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id r15-v6si741218pgs.292.2018.05.10.06.54.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 10 May 2018 06:54:32 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: [PATCH 9/8] powerpc/pkeys: Drop private VM_PKEY definitions
Date: Thu, 10 May 2018 23:54:22 +1000
Message-Id: <20180510135422.6585-1-mpe@ellerman.id.au>
In-Reply-To: <20180508145948.9492-9-mpe@ellerman.id.au>
References: <20180508145948.9492-9-mpe@ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxram@us.ibm.com
Cc: mingo@redhat.com, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com

Now that we've updated the generic headers to support 5 PKEY bits for
powerpc we don't need our own #defines in arch code.

Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
---
 arch/powerpc/include/asm/pkeys.h | 15 ---------------
 1 file changed, 15 deletions(-)

One additional patch to finish cleaning things up.

I've added this to my branch.

cheers

diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index 18ef59a9886d..5ba80cffb505 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -15,21 +15,6 @@ DECLARE_STATIC_KEY_TRUE(pkey_disabled);
 extern int pkeys_total; /* total pkeys as per device tree */
 extern u32 initial_allocation_mask; /* bits set for reserved keys */
 
-/*
- * Define these here temporarily so we're not dependent on patching linux/mm.h.
- * Once it's updated we can drop these.
- */
-#ifndef VM_PKEY_BIT0
-# define VM_PKEY_SHIFT	VM_HIGH_ARCH_BIT_0
-# define VM_PKEY_BIT0	VM_HIGH_ARCH_0
-# define VM_PKEY_BIT1	VM_HIGH_ARCH_1
-# define VM_PKEY_BIT2	VM_HIGH_ARCH_2
-# define VM_PKEY_BIT3	VM_HIGH_ARCH_3
-# define VM_PKEY_BIT4	VM_HIGH_ARCH_4
-#elif !defined(VM_PKEY_BIT4)
-# define VM_PKEY_BIT4	VM_HIGH_ARCH_4
-#endif
-
 #define ARCH_VM_PKEY_FLAGS (VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2 | \
 			    VM_PKEY_BIT3 | VM_PKEY_BIT4)
 
-- 
2.14.1
