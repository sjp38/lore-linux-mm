From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199911052211.OAA61667@google.engr.sgi.com>
Subject: [PATCH] kanoj-mm24-2.3.25 nonPAE ia32 zap_low_mappings fix
Date: Fri, 5 Nov 1999 14:11:41 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus,

Could you please add in this patch into 2.3.26. It is needed for 
*(int *0) = 0 to panic (after smp_init()) to catch kernel problems. 

Thanks.

Kanoj

--- /usr/tmp/p_rdiff_a005Oh/init.c	Fri Nov  5 14:05:50 1999
+++ arch/i386/mm/init.c	Fri Nov  5 13:01:50 1999
@@ -382,7 +382,12 @@
 	 * Zap initial low-memory mappings:
 	 */
 	for (i = 0; i < USER_PTRS_PER_PGD; i++)
+#if CONFIG_X86_PAE
 		pgd_clear(swapper_pg_dir + i);
+#else
+		pmd_clear((pmd_t *)swapper_pg_dir + i);
+#endif
+	flush_tlb_all();
 }
 
 /*
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
