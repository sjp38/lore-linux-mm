Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC96E6B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 16:57:44 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h24so155197961pfh.0
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 13:57:44 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id yx10si19177532pac.96.2016.10.17.13.57.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Oct 2016 13:57:42 -0700 (PDT)
Subject: [PATCH] x86, pkeys: remove cruft from never-merged syscalls
From: Dave Hansen <dave@sr71.net>
Date: Mon, 17 Oct 2016 13:57:09 -0700
Message-Id: <20161017205709.FC7C0C1D@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, tglx@linutronix.de, linux-arch@vger.kernel.org, mgorman@techsingularity.net, arnd@arndb.de, linux-api@vger.kernel.org, linux-mm@kvack.org, luto@kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org


From: Dave Hansen <dave.hansen@linux.intel.com>

pkey_set() and pkey_get() were syscalls present in older versions
of the protection keys patches.  The syscall number definitions
were inadvertently left in place.  This patch removes them.

I did a git grep and verified that these are the last places in
the tree that these appear, save for the protection_keys.c tests
and Documentation.  Those spots talk about functions called
pkey_get/set() which are wrappers for the direct PKRU
instructions, not the syscalls.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-arch@vger.kernel.org
Cc: mgorman@techsingularity.net
Cc: arnd@arndb.de
Cc: linux-api@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: luto@kernel.org
Cc: akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org
Fixes: f9afc6197e9bb ("x86: Wire up protection keys system calls")
---

 b/arch/x86/entry/syscalls/syscall_32.tbl |    2 --
 b/arch/x86/entry/syscalls/syscall_64.tbl |    2 --
 2 files changed, 4 deletions(-)

diff -puN arch/x86/entry/syscalls/syscall_32.tbl~kill-x86-pkey-syscall-nr-cruft arch/x86/entry/syscalls/syscall_32.tbl
--- a/arch/x86/entry/syscalls/syscall_32.tbl~kill-x86-pkey-syscall-nr-cruft	2016-10-17 13:00:11.607811388 -0700
+++ b/arch/x86/entry/syscalls/syscall_32.tbl	2016-10-17 13:00:14.216930557 -0700
@@ -389,5 +389,3 @@
 380	i386	pkey_mprotect		sys_pkey_mprotect
 381	i386	pkey_alloc		sys_pkey_alloc
 382	i386	pkey_free		sys_pkey_free
-#383	i386	pkey_get		sys_pkey_get
-#384	i386	pkey_set		sys_pkey_set
diff -puN arch/x86/entry/syscalls/syscall_64.tbl~kill-x86-pkey-syscall-nr-cruft arch/x86/entry/syscalls/syscall_64.tbl
--- a/arch/x86/entry/syscalls/syscall_64.tbl~kill-x86-pkey-syscall-nr-cruft	2016-10-17 13:00:11.609811480 -0700
+++ b/arch/x86/entry/syscalls/syscall_64.tbl	2016-10-17 13:00:21.896281301 -0700
@@ -338,8 +338,6 @@
 329	common	pkey_mprotect		sys_pkey_mprotect
 330	common	pkey_alloc		sys_pkey_alloc
 331	common	pkey_free		sys_pkey_free
-#332	common	pkey_get		sys_pkey_get
-#333	common	pkey_set		sys_pkey_set
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
