Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7FC396B03EF
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 17:23:25 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 19so655681qty.2
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:23:25 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id q127si28902qkb.169.2017.07.05.14.23.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 14:23:24 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id p21so205136qke.0
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:23:24 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v5 23/38] powerpc: sys_pkey_mprotect() system call
Date: Wed,  5 Jul 2017 14:22:00 -0700
Message-Id: <1499289735-14220-24-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

Patch provides the ability for a process to
associate a pkey with a address range.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/systbl.h      |    1 +
 arch/powerpc/include/asm/unistd.h      |    4 +---
 arch/powerpc/include/uapi/asm/unistd.h |    1 +
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/powerpc/include/asm/systbl.h b/arch/powerpc/include/asm/systbl.h
index 22dd776..b33b551 100644
--- a/arch/powerpc/include/asm/systbl.h
+++ b/arch/powerpc/include/asm/systbl.h
@@ -390,3 +390,4 @@
 SYSCALL(statx)
 SYSCALL(pkey_alloc)
 SYSCALL(pkey_free)
+SYSCALL(pkey_mprotect)
diff --git a/arch/powerpc/include/asm/unistd.h b/arch/powerpc/include/asm/unistd.h
index e0273bc..daf1ba9 100644
--- a/arch/powerpc/include/asm/unistd.h
+++ b/arch/powerpc/include/asm/unistd.h
@@ -12,12 +12,10 @@
 #include <uapi/asm/unistd.h>
 
 
-#define NR_syscalls		386
+#define NR_syscalls		387
 
 #define __NR__exit __NR_exit
 
-#define __IGNORE_pkey_mprotect
-
 #ifndef __ASSEMBLY__
 
 #include <linux/types.h>
diff --git a/arch/powerpc/include/uapi/asm/unistd.h b/arch/powerpc/include/uapi/asm/unistd.h
index 7993a07..71ae45e 100644
--- a/arch/powerpc/include/uapi/asm/unistd.h
+++ b/arch/powerpc/include/uapi/asm/unistd.h
@@ -396,5 +396,6 @@
 #define __NR_statx		383
 #define __NR_pkey_alloc		384
 #define __NR_pkey_free		385
+#define __NR_pkey_mprotect	386
 
 #endif /* _UAPI_ASM_POWERPC_UNISTD_H_ */
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
