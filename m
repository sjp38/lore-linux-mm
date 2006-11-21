Date: Tue, 21 Nov 2006 12:36:52 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20061121203652.30802.6539.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20061121203647.30802.20845.sendpatchset@schroedinger.engr.sgi.com>
References: <20061121203647.30802.20845.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 1/6] Move sighand_cachep to include/signal.h
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Move sighand_cachep definitioni to linux/signal.h

The sighand cache is only used in fs/exec.c and kernel/fork.c.
It is defined in kernel/fork.c but only used in fs/exec.c.

The sighand_cachep is related to signal processing. So add the definition
to signal.h.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc5-mm2/include/linux/slab.h
===================================================================
--- linux-2.6.19-rc5-mm2.orig/include/linux/slab.h	2006-11-21 14:11:50.000000000 -0600
+++ linux-2.6.19-rc5-mm2/include/linux/slab.h	2006-11-21 14:12:25.500080559 -0600
@@ -302,7 +302,6 @@ extern kmem_cache_t	*names_cachep;
 extern kmem_cache_t	*files_cachep;
 extern kmem_cache_t	*filp_cachep;
 extern kmem_cache_t	*fs_cachep;
-extern kmem_cache_t	*sighand_cachep;
 
 #endif	/* __KERNEL__ */
 
Index: linux-2.6.19-rc5-mm2/include/linux/signal.h
===================================================================
--- linux-2.6.19-rc5-mm2.orig/include/linux/signal.h	2006-11-21 14:11:29.000000000 -0600
+++ linux-2.6.19-rc5-mm2/include/linux/signal.h	2006-11-21 14:12:07.687985977 -0600
@@ -241,6 +241,8 @@ extern int sigprocmask(int, sigset_t *, 
 struct pt_regs;
 extern int get_signal_to_deliver(siginfo_t *info, struct k_sigaction *return_ka, struct pt_regs *regs, void *cookie);
 
+extern struct kmem_cache *sighand_cachep;
+
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_SIGNAL_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
