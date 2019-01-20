Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id A8A228E0001
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 07:01:51 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id w18so17578166qts.8
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 04:01:51 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y11si3008698qtm.124.2019.01.20.04.01.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Jan 2019 04:01:50 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0KBsuKu108751
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 07:01:50 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q4j2xx47v-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 07:01:49 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 20 Jan 2019 12:01:47 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 2/3] docs/core-api/mm: fix user memory accessors formatting
Date: Sun, 20 Jan 2019 14:01:36 +0200
In-Reply-To: <1547985697-24588-1-git-send-email-rppt@linux.ibm.com>
References: <1547985697-24588-1-git-send-email-rppt@linux.ibm.com>
Message-Id: <1547985697-24588-3-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>

The descriptions of userspace memory access functions had minor issues with
formatting that made kernel-doc unable to properly detect the
function/macro names and the return value sections:

./arch/x86/include/asm/uaccess.h:80: info: Scanning doc for
./arch/x86/include/asm/uaccess.h:139: info: Scanning doc for
./arch/x86/include/asm/uaccess.h:231: info: Scanning doc for
./arch/x86/include/asm/uaccess.h:505: info: Scanning doc for
./arch/x86/include/asm/uaccess.h:530: info: Scanning doc for
./arch/x86/lib/usercopy_32.c:58: info: Scanning doc for
./arch/x86/lib/usercopy_32.c:69: warning: No description found for return
value of 'clear_user'
./arch/x86/lib/usercopy_32.c:78: info: Scanning doc for
./arch/x86/lib/usercopy_32.c:90: warning: No description found for return
value of '__clear_user'

Fix the formatting.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/x86/include/asm/uaccess.h | 24 ++++++++++++------------
 arch/x86/lib/usercopy_32.c     |  8 ++++----
 2 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
index a77445d..83ce5faa 100644
--- a/arch/x86/include/asm/uaccess.h
+++ b/arch/x86/include/asm/uaccess.h
@@ -76,7 +76,7 @@ static inline bool __chk_range_not_ok(unsigned long addr, unsigned long size, un
 #endif
 
 /**
- * access_ok: - Checks if a user space pointer is valid
+ * access_ok - Checks if a user space pointer is valid
  * @addr: User space pointer to start of block to check
  * @size: Size of block to check
  *
@@ -85,12 +85,12 @@ static inline bool __chk_range_not_ok(unsigned long addr, unsigned long size, un
  *
  * Checks if a pointer to a block of memory in user space is valid.
  *
- * Returns true (nonzero) if the memory block may be valid, false (zero)
- * if it is definitely invalid.
- *
  * Note that, depending on architecture, this function probably just
  * checks that the pointer is in the user space range - after calling
  * this function, memory access functions may still return -EFAULT.
+ *
+ * Return: true (nonzero) if the memory block may be valid, false (zero)
+ * if it is definitely invalid.
  */
 #define access_ok(addr, size)					\
 ({									\
@@ -135,7 +135,7 @@ extern int __get_user_bad(void);
 __typeof__(__builtin_choose_expr(sizeof(x) > sizeof(0UL), 0ULL, 0UL))
 
 /**
- * get_user: - Get a simple variable from user space.
+ * get_user - Get a simple variable from user space.
  * @x:   Variable to store result.
  * @ptr: Source address, in user space.
  *
@@ -149,7 +149,7 @@ __typeof__(__builtin_choose_expr(sizeof(x) > sizeof(0UL), 0ULL, 0UL))
  * @ptr must have pointer-to-simple-variable type, and the result of
  * dereferencing @ptr must be assignable to @x without a cast.
  *
- * Returns zero on success, or -EFAULT on error.
+ * Return: zero on success, or -EFAULT on error.
  * On error, the variable @x is set to zero.
  */
 /*
@@ -227,7 +227,7 @@ extern void __put_user_4(void);
 extern void __put_user_8(void);
 
 /**
- * put_user: - Write a simple value into user space.
+ * put_user - Write a simple value into user space.
  * @x:   Value to copy to user space.
  * @ptr: Destination address, in user space.
  *
@@ -241,7 +241,7 @@ extern void __put_user_8(void);
  * @ptr must have pointer-to-simple-variable type, and @x must be assignable
  * to the result of dereferencing @ptr.
  *
- * Returns zero on success, or -EFAULT on error.
+ * Return: zero on success, or -EFAULT on error.
  */
 #define put_user(x, ptr)					\
 ({								\
@@ -501,7 +501,7 @@ struct __large_struct { unsigned long buf[100]; };
 } while (0)
 
 /**
- * __get_user: - Get a simple variable from user space, with less checking.
+ * __get_user - Get a simple variable from user space, with less checking.
  * @x:   Variable to store result.
  * @ptr: Source address, in user space.
  *
@@ -518,7 +518,7 @@ struct __large_struct { unsigned long buf[100]; };
  * Caller must check the pointer with access_ok() before calling this
  * function.
  *
- * Returns zero on success, or -EFAULT on error.
+ * Return: zero on success, or -EFAULT on error.
  * On error, the variable @x is set to zero.
  */
 
@@ -526,7 +526,7 @@ struct __large_struct { unsigned long buf[100]; };
 	__get_user_nocheck((x), (ptr), sizeof(*(ptr)))
 
 /**
- * __put_user: - Write a simple value into user space, with less checking.
+ * __put_user - Write a simple value into user space, with less checking.
  * @x:   Value to copy to user space.
  * @ptr: Destination address, in user space.
  *
@@ -543,7 +543,7 @@ struct __large_struct { unsigned long buf[100]; };
  * Caller must check the pointer with access_ok() before calling this
  * function.
  *
- * Returns zero on success, or -EFAULT on error.
+ * Return: zero on success, or -EFAULT on error.
  */
 
 #define __put_user(x, ptr)						\
diff --git a/arch/x86/lib/usercopy_32.c b/arch/x86/lib/usercopy_32.c
index bfd94e7..7d29077 100644
--- a/arch/x86/lib/usercopy_32.c
+++ b/arch/x86/lib/usercopy_32.c
@@ -54,13 +54,13 @@ do {									\
 } while (0)
 
 /**
- * clear_user: - Zero a block of memory in user space.
+ * clear_user - Zero a block of memory in user space.
  * @to:   Destination address, in user space.
  * @n:    Number of bytes to zero.
  *
  * Zero a block of memory in user space.
  *
- * Returns number of bytes that could not be cleared.
+ * Return: number of bytes that could not be cleared.
  * On success, this will be zero.
  */
 unsigned long
@@ -74,14 +74,14 @@ clear_user(void __user *to, unsigned long n)
 EXPORT_SYMBOL(clear_user);
 
 /**
- * __clear_user: - Zero a block of memory in user space, with less checking.
+ * __clear_user - Zero a block of memory in user space, with less checking.
  * @to:   Destination address, in user space.
  * @n:    Number of bytes to zero.
  *
  * Zero a block of memory in user space.  Caller must check
  * the specified block with access_ok() before calling this function.
  *
- * Returns number of bytes that could not be cleared.
+ * Return: number of bytes that could not be cleared.
  * On success, this will be zero.
  */
 unsigned long
-- 
2.7.4
