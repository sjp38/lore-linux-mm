Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2CC626B025E
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 11:54:31 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id ot11so40264485pab.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 08:54:31 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id g29si4156254pfj.135.2016.04.11.08.54.28
        for <linux-mm@kvack.org>;
        Mon, 11 Apr 2016 08:54:28 -0700 (PDT)
Subject: [PATCH 4/8] x86: wire up mprotect_key() system call
From: Dave Hansen <dave@sr71.net>
Date: Mon, 11 Apr 2016 08:54:28 -0700
References: <20160411155422.A2B8FD0C@viggo.jf.intel.com>
In-Reply-To: <20160411155422.A2B8FD0C@viggo.jf.intel.com>
Message-Id: <20160411155428.8935D2E7@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, linux-api@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, akpm@linux-foundation.org


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
--- a/arch/x86/entry/syscalls/syscall_32.tbl~pkeys-114-x86-mprotect_key	2016-04-11 08:38:41.821293673 -0700
+++ b/arch/x86/entry/syscalls/syscall_32.tbl	2016-04-11 08:38:41.826293899 -0700
@@ -386,3 +386,4 @@
 377	i386	copy_file_range		sys_copy_file_range
 378	i386	preadv2			sys_preadv2
 379	i386	pwritev2		sys_pwritev2
+380	i386	pkey_mprotect		sys_pkey_mprotect
diff -puN arch/x86/entry/syscalls/syscall_64.tbl~pkeys-114-x86-mprotect_key arch/x86/entry/syscalls/syscall_64.tbl
--- a/arch/x86/entry/syscalls/syscall_64.tbl~pkeys-114-x86-mprotect_key	2016-04-11 08:38:41.823293763 -0700
+++ b/arch/x86/entry/syscalls/syscall_64.tbl	2016-04-11 08:38:41.826293899 -0700
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
