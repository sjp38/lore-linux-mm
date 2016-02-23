Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0B64782F69
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 20:11:16 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id e127so102149449pfe.3
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 17:11:16 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id 10si43275680pfb.71.2016.02.22.17.11.14
        for <linux-mm@kvack.org>;
        Mon, 22 Feb 2016 17:11:14 -0800 (PST)
Subject: [RFC][PATCH 4/7] x86: wire up mprotect_key() system call
From: Dave Hansen <dave@sr71.net>
Date: Mon, 22 Feb 2016 17:11:13 -0800
References: <20160223011107.FB9B8215@viggo.jf.intel.com>
In-Reply-To: <20160223011107.FB9B8215@viggo.jf.intel.com>
Message-Id: <20160223011113.1019C54D@viggo.jf.intel.com>
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

diff -puN arch/x86/entry/syscalls/syscall_32.tbl~pkeys-85b-x86-mprotect_key arch/x86/entry/syscalls/syscall_32.tbl
--- a/arch/x86/entry/syscalls/syscall_32.tbl~pkeys-85b-x86-mprotect_key	2016-02-22 17:09:24.183334806 -0800
+++ b/arch/x86/entry/syscalls/syscall_32.tbl	2016-02-22 17:09:24.188335034 -0800
@@ -384,3 +384,4 @@
 375	i386	membarrier		sys_membarrier
 376	i386	mlock2			sys_mlock2
 377	i386	copy_file_range		sys_copy_file_range
+378	i386	pkey_mprotect		sys_pkey_mprotect
diff -puN arch/x86/entry/syscalls/syscall_64.tbl~pkeys-85b-x86-mprotect_key arch/x86/entry/syscalls/syscall_64.tbl
--- a/arch/x86/entry/syscalls/syscall_64.tbl~pkeys-85b-x86-mprotect_key	2016-02-22 17:09:24.185334897 -0800
+++ b/arch/x86/entry/syscalls/syscall_64.tbl	2016-02-22 17:09:24.188335034 -0800
@@ -333,6 +333,7 @@
 324	common	membarrier		sys_membarrier
 325	common	mlock2			sys_mlock2
 326	common	copy_file_range		sys_copy_file_range
+327	common	pkey_mprotect		sys_pkey_mprotect
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
