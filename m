Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E3DC6B0645
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 23:58:46 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id r30so56842092qtc.5
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:58:46 -0700 (PDT)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id v39si12061876qta.394.2017.07.15.20.58.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 20:58:45 -0700 (PDT)
Received: by mail-qk0-x243.google.com with SMTP id a66so16022030qkb.0
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:58:45 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v6 18/62] powerpc: sys_pkey_alloc() and sys_pkey_free() system calls
Date: Sat, 15 Jul 2017 20:56:20 -0700
Message-Id: <1500177424-13695-19-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

Finally this patch provides the ability for a process to
allocate and free a protection key.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/systbl.h      |    2 ++
 arch/powerpc/include/asm/unistd.h      |    4 +---
 arch/powerpc/include/uapi/asm/unistd.h |    2 ++
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/arch/powerpc/include/asm/systbl.h b/arch/powerpc/include/asm/systbl.h
index 1c94708..22dd776 100644
--- a/arch/powerpc/include/asm/systbl.h
+++ b/arch/powerpc/include/asm/systbl.h
@@ -388,3 +388,5 @@
 COMPAT_SYS_SPU(pwritev2)
 SYSCALL(kexec_file_load)
 SYSCALL(statx)
+SYSCALL(pkey_alloc)
+SYSCALL(pkey_free)
diff --git a/arch/powerpc/include/asm/unistd.h b/arch/powerpc/include/asm/unistd.h
index 9ba11db..e0273bc 100644
--- a/arch/powerpc/include/asm/unistd.h
+++ b/arch/powerpc/include/asm/unistd.h
@@ -12,13 +12,11 @@
 #include <uapi/asm/unistd.h>
 
 
-#define NR_syscalls		384
+#define NR_syscalls		386
 
 #define __NR__exit __NR_exit
 
 #define __IGNORE_pkey_mprotect
-#define __IGNORE_pkey_alloc
-#define __IGNORE_pkey_free
 
 #ifndef __ASSEMBLY__
 
diff --git a/arch/powerpc/include/uapi/asm/unistd.h b/arch/powerpc/include/uapi/asm/unistd.h
index b85f142..7993a07 100644
--- a/arch/powerpc/include/uapi/asm/unistd.h
+++ b/arch/powerpc/include/uapi/asm/unistd.h
@@ -394,5 +394,7 @@
 #define __NR_pwritev2		381
 #define __NR_kexec_file_load	382
 #define __NR_statx		383
+#define __NR_pkey_alloc		384
+#define __NR_pkey_free		385
 
 #endif /* _UAPI_ASM_POWERPC_UNISTD_H_ */
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
