Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id E8F5138C26
	for <linux-mm@kvack.org>; Mon, 25 Jun 2001 20:04:25 -0300 (EST)
Received: from localhost (riel@localhost)
	by duckman.conectiva.com.br (8.11.4/8.11.3) with ESMTP id f5PN4PH30875
	for <linux-mm@kvack.org>; Mon, 25 Jun 2001 20:04:25 -0300
Date: Mon, 25 Jun 2001 20:04:25 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [RFC] VM statistics to gather
Message-ID: <Pine.LNX.4.33L.0106252002560.23373-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I am starting the process of adding more detailed instrumentation
to the VM subsystem and am wondering which statistics to add.
A quick start of things to measure are below, but I've probably
missed some things. Comments are welcome ...



--- kernel_stat.h.instr	Sun Jun 24 19:52:34 2001
+++ kernel_stat.h	Mon Jun 25 20:02:38 2001
@@ -26,6 +26,25 @@
 	unsigned int dk_drive_wblk[DK_MAX_MAJOR][DK_MAX_DISK];
 	unsigned int pgpgin, pgpgout;
 	unsigned int pswpin, pswpout;
+	unsigned int vm_pgscan;		/* Pages scanned by pageout code. */
+	unsigned int vm_pgdeact;	/* Pages deactivated by pageout code */
+	unsigned int vm_pgclean;	/* Pages moved to inactive_clean */
+	unsigned int vm_pgskiplaunder;	/* Pages skipped by page_launder */
+	unsigned int vm_pglaundered;	/* Pages laundered by page_launder */
+	unsigned int vm_pgreact;	/* Pages reactivated by page_launder
+					 * (rescued from inactive_clean list) */
+	unsigned int vm_pgrescue;	/* Pages reactivated by reclaim_page
+					 * (rescued from inactive_dirty list) */
+	unsigned int vm_majfault;	/* Major page faults (disk IO) */
+	unsigned int vm_minfault;	/* Minor page faults (no disk IO) */
+	unsigned int vm_cow_fault;	/* COW faults, copy needed */
+	unsigned int vm_cow_optim;	/* COW skipped copy */
+	unsigned int vm_zero_fault;	/* Zero-filled page given to process */
+	unsigned int vm_zero_optim;	/* COW of the EMPTY_ZERO_PAGE */
+	unsigned int vm_kswapd_wakeup;	/* kswapd wake-ups */
+	unsigned int vm_kswapd_loops;	/* kswapd go-arounds in kswapd() loop */
+	unsigned int vm_pg_freed;	/* Pages freed by pageout code, also
+					   pages moved to inactive_clean */
 #if !defined(CONFIG_ARCH_S390)
 	unsigned int irqs[NR_CPUS][NR_IRQS];
 #endif

Rik
--
Executive summary of a recent Microsoft press release:
   "we are concerned about the GNU General Public License (GPL)"


		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
