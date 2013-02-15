Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 3FC3D6B0005
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 01:35:58 -0500 (EST)
Date: Fri, 15 Feb 2013 01:35:45 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/2] x86-64: hook up fincore() syscall
Message-ID: <20130215063545.GB24047@cmpxchg.org>
References: <87a9rbh7b4.fsf@rustcorp.com.au>
 <20130211162701.GB13218@cmpxchg.org>
 <20130211141239.f4decf03.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130211141239.f4decf03.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Stewart Smith <stewart@flamingspork.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 arch/x86/syscalls/syscall_64.tbl | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/x86/syscalls/syscall_64.tbl b/arch/x86/syscalls/syscall_64.tbl
index 38ae65d..c9ac047 100644
--- a/arch/x86/syscalls/syscall_64.tbl
+++ b/arch/x86/syscalls/syscall_64.tbl
@@ -320,6 +320,7 @@
 311	64	process_vm_writev	sys_process_vm_writev
 312	common	kcmp			sys_kcmp
 313	common	finit_module		sys_finit_module
+314	common	fincore			sys_fincore
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
