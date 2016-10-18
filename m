Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1B4926B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 11:18:09 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r16so225093860pfg.4
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 08:18:09 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id h64si24648745pfh.83.2016.10.18.08.18.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 08:18:02 -0700 (PDT)
Subject: [PATCH] x86, pkeys: remove cruft from never-merged syscalls
From: Dave Hansen <dave@sr71.net>
Date: Tue, 18 Oct 2016 08:18:01 -0700
Message-Id: <20161018151801.9C33BCC7@viggo.jf.intel.com>
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
