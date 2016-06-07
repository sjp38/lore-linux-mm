Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0DDC56B0260
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 16:47:28 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id u203so179056991itc.0
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 13:47:28 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id a16si36713910pfg.217.2016.06.07.13.47.27
        for <linux-mm@kvack.org>;
        Tue, 07 Jun 2016 13:47:27 -0700 (PDT)
Subject: [PATCH 7/9] generic syscalls: wire up memory protection keys syscalls
From: Dave Hansen <dave@sr71.net>
Date: Tue, 07 Jun 2016 13:47:25 -0700
References: <20160607204712.594DE00A@viggo.jf.intel.com>
In-Reply-To: <20160607204712.594DE00A@viggo.jf.intel.com>
Message-Id: <20160607204725.A731CB1E@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, arnd@arndb.de


From: Dave Hansen <dave.hansen@linux.intel.com>

These new syscalls are implemented as generic code, so enable
them for architectures like arm64 which use the generic syscall
table.

According to Arnd:

	Even if the support is x86 specific for the forseeable
	future, it may be good to reserve the number just in
	case.  The other architecture specific syscall lists are
	usually left to the individual arch maintainers, most a
	lot of the newer architectures share this table.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>
---

 b/include/uapi/asm-generic/unistd.h |   12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff -puN include/uapi/asm-generic/unistd.h~pkeys-119-syscalls-generic include/uapi/asm-generic/unistd.h
--- a/include/uapi/asm-generic/unistd.h~pkeys-119-syscalls-generic	2016-06-07 13:22:21.703083776 -0700
+++ b/include/uapi/asm-generic/unistd.h	2016-06-07 13:22:21.707083961 -0700
@@ -724,9 +724,19 @@ __SYSCALL(__NR_copy_file_range, sys_copy
 __SC_COMP(__NR_preadv2, sys_preadv2, compat_sys_preadv2)
 #define __NR_pwritev2 287
 __SC_COMP(__NR_pwritev2, sys_pwritev2, compat_sys_pwritev2)
+#define __NR_pkey_mprotect 288
+__SYSCALL(__NR_pkey_mprotect, sys_pkey_mprotect)
+#define __NR_pkey_alloc 289
+__SYSCALL(__NR_pkey_alloc,    sys_pkey_alloc)
+#define __NR_pkey_free 290
+__SYSCALL(__NR_pkey_free,     sys_pkey_free)
+#define __NR_pkey_get 291
+__SYSCALL(__NR_pkey_get,      sys_pkey_get)
+#define __NR_pkey_set 292
+__SYSCALL(__NR_pkey_set,      sys_pkey_set)
 
 #undef __NR_syscalls
-#define __NR_syscalls 288
+#define __NR_syscalls 293
 
 /*
  * All syscalls below here should go away really,
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
