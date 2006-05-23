Date: Tue, 23 May 2006 10:44:05 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060523174405.10156.45361.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060523174344.10156.66845.sendpatchset@schroedinger.engr.sgi.com>
References: <20060523174344.10156.66845.sendpatchset@schroedinger.engr.sgi.com>
Subject: [4/5] move_pages: x86_64 support
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Hugh Dickins <hugh@veritas.com>, linux-ia64@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

sys_move_pages support for x86_64

Only compile-tested.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc4-mm1/include/asm-x86_64/unistd.h
===================================================================
--- linux-2.6.17-rc4-mm1.orig/include/asm-x86_64/unistd.h	2006-05-21 00:18:04.000000000 +1000
+++ linux-2.6.17-rc4-mm1/include/asm-x86_64/unistd.h	2006-05-21 00:19:33.000000000 +1000
@@ -617,10 +617,12 @@
 __SYSCALL(__NR_sync_file_range, sys_sync_file_range)
 #define __NR_vmsplice		278
 __SYSCALL(__NR_vmsplice, sys_vmsplice)
+#define __NR_move_pages		279
+__SYSCALL(__NR_move_pages, sys_move_pages)
 
 #ifdef __KERNEL__
 
-#define __NR_syscall_max __NR_vmsplice
+#define __NR_syscall_max __NR_move_pages
 
 #ifndef __NO_STUBS
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
