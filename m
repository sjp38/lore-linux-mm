Message-Id: <200405222205.i4MM5Sr12689@mail.osdl.org>
Subject: [patch 17/57] numa api: x86_64 support
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:04:57 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

From: Andi Kleen <ak@suse.de>

Add NUMA API system calls on x86-64

This includes a bugfix to prevent miscompilation on gcc 3.2 of bitmap.h


---

 25-akpm/include/asm-x86_64/unistd.h |    4 ++--
 25-akpm/include/linux/bitmap.h      |    3 ++-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff -puN include/asm-x86_64/unistd.h~numa-api-x86_64 include/asm-x86_64/unistd.h
--- 25/include/asm-x86_64/unistd.h~numa-api-x86_64	2004-05-22 14:56:24.245405664 -0700
+++ 25-akpm/include/asm-x86_64/unistd.h	2004-05-22 14:56:24.251404752 -0700
@@ -534,7 +534,7 @@ __SYSCALL(__NR_utimes, sys_utimes)
 __SYSCALL(__NR_vserver, sys_ni_syscall)
 #define __NR_vserver		236
 __SYSCALL(__NR_vserver, sys_ni_syscall)
-#define __NR_mbind 			237
+#define __NR_mbind 		237
 __SYSCALL(__NR_mbind, sys_ni_syscall)
 #define __NR_set_mempolicy 	238
 __SYSCALL(__NR_set_mempolicy, sys_ni_syscall)
@@ -546,7 +546,7 @@ __SYSCALL(__NR_mq_open, sys_mq_open)
 __SYSCALL(__NR_mq_unlink, sys_mq_unlink)
 #define __NR_mq_timedsend 	242
 __SYSCALL(__NR_mq_timedsend, sys_mq_timedsend)
-#define __NR_mq_timedreceive 243
+#define __NR_mq_timedreceive	243
 __SYSCALL(__NR_mq_timedreceive, sys_mq_timedreceive)
 #define __NR_mq_notify 		244
 __SYSCALL(__NR_mq_notify, sys_mq_notify)
diff -puN include/linux/bitmap.h~numa-api-x86_64 include/linux/bitmap.h
--- 25/include/linux/bitmap.h~numa-api-x86_64	2004-05-22 14:56:24.246405512 -0700
+++ 25-akpm/include/linux/bitmap.h	2004-05-22 14:56:24.251404752 -0700
@@ -29,7 +29,8 @@ static inline void bitmap_fill(unsigned 
 static inline void bitmap_copy(unsigned long *dst,
 			const unsigned long *src, int bits)
 {
-	memcpy(dst, src, BITS_TO_LONGS(bits)*sizeof(unsigned long));
+	int len = BITS_TO_LONGS(bits)*sizeof(unsigned long);
+	memcpy(dst, src, len);
 }
 
 void bitmap_shift_right(unsigned long *dst,

_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
