Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id E5E826B0264
	for <linux-mm@kvack.org>; Tue, 31 May 2016 11:28:32 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id f8so119819579pag.2
        for <linux-mm@kvack.org>; Tue, 31 May 2016 08:28:32 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id 7si44312836pfs.35.2016.05.31.08.28.31
        for <linux-mm@kvack.org>;
        Tue, 31 May 2016 08:28:32 -0700 (PDT)
Subject: [PATCH 4/8] x86: wire up mprotect_key() system call
From: Dave Hansen <dave@sr71.net>
Date: Tue, 31 May 2016 08:28:20 -0700
References: <20160531152814.36E0B9EE@viggo.jf.intel.com>
In-Reply-To: <20160531152814.36E0B9EE@viggo.jf.intel.com>
Message-Id: <20160531152820.07263396@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

This is all that we need to get the new system call itself
working on x86.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-api@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Cc: torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org
---

 b/arch/x86/entry/syscalls/syscall_32.tbl |    1 +
 b/arch/x86/entry/syscalls/syscall_64.tbl |    1 +
 2 files changed, 2 insertions(+)

diff -puN arch/x86/entry/syscalls/syscall_32.tbl~pkeys-114-x86-mprotect_key arch/x86/entry/syscalls/syscall_32.tbl
--- a/arch/x86/entry/syscalls/syscall_32.tbl~pkeys-114-x86-mprotect_key	2016-05-31 08:27:48.667093739 -0700
+++ b/arch/x86/entry/syscalls/syscall_32.tbl	2016-05-31 08:27:48.673094010 -0700
@@ -386,3 +386,4 @@
 377	i386	copy_file_range		sys_copy_file_range
 378	i386	preadv2			sys_preadv2			compat_sys_preadv2
 379	i386	pwritev2		sys_pwritev2			compat_sys_pwritev2
+380	i386	pkey_mprotect		sys_pkey_mprotect
diff -puN arch/x86/entry/syscalls/syscall_64.tbl~pkeys-114-x86-mprotect_key arch/x86/entry/syscalls/syscall_64.tbl
--- a/arch/x86/entry/syscalls/syscall_64.tbl~pkeys-114-x86-mprotect_key	2016-05-31 08:27:48.668093784 -0700
+++ b/arch/x86/entry/syscalls/syscall_64.tbl	2016-05-31 08:27:48.673094010 -0700
@@ -335,6 +335,7 @@
 326	common	copy_file_range		sys_copy_file_range
 327	64	preadv2			sys_preadv2
 328	64	pwritev2		sys_pwritev2
+329	common	pkey_mprotect		sys_pkey_mprotect
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
