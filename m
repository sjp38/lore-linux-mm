Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1DBC2828E1
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 12:30:22 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ca5so111784397pac.0
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 09:30:22 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id dl1si19004302pab.216.2016.07.29.09.30.18
        for <linux-mm@kvack.org>;
        Fri, 29 Jul 2016 09:30:18 -0700 (PDT)
Subject: [PATCH 05/10] x86: wire up protection keys system calls
From: Dave Hansen <dave@sr71.net>
Date: Fri, 29 Jul 2016 09:30:17 -0700
References: <20160729163009.5EC1D38C@viggo.jf.intel.com>
In-Reply-To: <20160729163009.5EC1D38C@viggo.jf.intel.com>
Message-Id: <20160729163017.E3C06FD2@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, luto@kernel.org, mgorman@techsingularity.net, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, arnd@arndb.de


From: Dave Hansen <dave.hansen@linux.intel.com>

This is all that we need to get the new system calls themselves
working on x86.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-api@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Cc: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: mgorman@techsingularity.net
---

 b/arch/x86/entry/syscalls/syscall_32.tbl |    5 +++++
 b/arch/x86/entry/syscalls/syscall_64.tbl |    5 +++++
 2 files changed, 10 insertions(+)

diff -puN arch/x86/entry/syscalls/syscall_32.tbl~pkeys-114-x86-mprotect_key arch/x86/entry/syscalls/syscall_32.tbl
--- a/arch/x86/entry/syscalls/syscall_32.tbl~pkeys-114-x86-mprotect_key	2016-07-29 09:18:57.983542427 -0700
+++ b/arch/x86/entry/syscalls/syscall_32.tbl	2016-07-29 09:18:57.988542654 -0700
@@ -386,3 +386,8 @@
 377	i386	copy_file_range		sys_copy_file_range
 378	i386	preadv2			sys_preadv2			compat_sys_preadv2
 379	i386	pwritev2		sys_pwritev2			compat_sys_pwritev2
+380	i386	pkey_mprotect		sys_pkey_mprotect
+381	i386	pkey_alloc		sys_pkey_alloc
+382	i386	pkey_free		sys_pkey_free
+#383	i386	pkey_get		sys_pkey_get
+#384	i386	pkey_set		sys_pkey_set
diff -puN arch/x86/entry/syscalls/syscall_64.tbl~pkeys-114-x86-mprotect_key arch/x86/entry/syscalls/syscall_64.tbl
--- a/arch/x86/entry/syscalls/syscall_64.tbl~pkeys-114-x86-mprotect_key	2016-07-29 09:18:57.985542518 -0700
+++ b/arch/x86/entry/syscalls/syscall_64.tbl	2016-07-29 09:18:57.988542654 -0700
@@ -335,6 +335,11 @@
 326	common	copy_file_range		sys_copy_file_range
 327	64	preadv2			sys_preadv2
 328	64	pwritev2		sys_pwritev2
+329	common	pkey_mprotect		sys_pkey_mprotect
+330	common	pkey_alloc		sys_pkey_alloc
+331	common	pkey_free		sys_pkey_free
+#332	common	pkey_get		sys_pkey_get
+#333	common	pkey_set		sys_pkey_set
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
