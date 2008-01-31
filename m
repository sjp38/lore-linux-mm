Date: Thu, 31 Jan 2008 14:16:10 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: mmu_notifier: reduce size of mm_struct if !CONFIG_MMU_NOTIFIER
In-Reply-To: <Pine.LNX.4.64.0801311355260.27804@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0801311415280.15573@schroedinger.engr.sgi.com>
References: <20080131045750.855008281@sgi.com> <20080131045812.785269387@sgi.com>
 <20080131123118.GK7185@v2.random> <Pine.LNX.4.64.0801311355260.27804@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

Andrea and Peter had a concern about this.

Use an #ifdef to make the mmu_notifer_head structure empty if we have
no notifier. That allows the use of the structure in inline functions
(which allows parameter verification even if !CONFIG_MMU_NOTIFIER)

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/mm_types.h |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h	2008-01-31 14:03:23.000000000 -0800
+++ linux-2.6/include/linux/mm_types.h	2008-01-31 14:03:38.000000000 -0800
@@ -154,7 +154,9 @@ struct vm_area_struct {
 };
 
 struct mmu_notifier_head {
+#ifdef CONFIG_MMU_NOTIFIER
 	struct hlist_head head;
+#endif
 };
 
 struct mm_struct {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
