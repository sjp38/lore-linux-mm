Date: Mon, 30 Oct 2006 18:18:26 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH 2/2] [POWERPC] Wire up sys_migrate_pages
Message-Id: <20061030181826.634e086d.sfr@canb.auug.org.au>
In-Reply-To: <20061030181701.23ea7cba.sfr@canb.auug.org.au>
References: <20061030181701.23ea7cba.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: ppc-dev <linuxppc-dev@ozlabs.org>, paulus@samba.org, ak@suse.de, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, pj@sgi.com
List-ID: <linux-mm.kvack.org>

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 include/asm-powerpc/systbl.h |    2 +-
 include/asm-powerpc/unistd.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --git a/include/asm-powerpc/systbl.h b/include/asm-powerpc/systbl.h
index eac85ce..c6a0318 100644
--- a/include/asm-powerpc/systbl.h
+++ b/include/asm-powerpc/systbl.h
@@ -261,7 +261,7 @@ SYSX(sys_ni_syscall, ppc_fadvise64_64, p
 PPC_SYS_SPU(rtas)
 OLDSYS(debug_setcontext)
 SYSCALL(ni_syscall)
-SYSCALL(ni_syscall)
+COMPAT_SYS(migrate_pages)
 COMPAT_SYS(mbind)
 COMPAT_SYS(get_mempolicy)
 COMPAT_SYS(set_mempolicy)
diff --git a/include/asm-powerpc/unistd.h b/include/asm-powerpc/unistd.h
index 464a48c..b5fe932 100644
--- a/include/asm-powerpc/unistd.h
+++ b/include/asm-powerpc/unistd.h
@@ -276,7 +276,7 @@ #endif
 #define __NR_rtas		255
 #define __NR_sys_debug_setcontext 256
 /* Number 257 is reserved for vserver */
-/* 258 currently unused */
+#define __NR_migrate_pages	258
 #define __NR_mbind		259
 #define __NR_get_mempolicy	260
 #define __NR_set_mempolicy	261
-- 
1.4.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
