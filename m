Date: Mon, 3 Mar 2008 04:39:04 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] mmu notifiers #v8
Message-ID: <20080303033903.GE3301@wotan.suse.de>
References: <20080219084357.GA22249@wotan.suse.de> <20080219135851.GI7128@v2.random> <20080219231157.GC18912@wotan.suse.de> <20080220010941.GR7128@v2.random> <20080220103942.GU7128@v2.random> <20080221045430.GC15215@wotan.suse.de> <20080221144023.GC9427@v2.random> <20080221161028.GA14220@sgi.com> <20080227192610.GF28483@v2.random> <20080302155457.GK8091@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080302155457.GK8091@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Jack Steiner <steiner@sgi.com>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Sun, Mar 02, 2008 at 04:54:57PM +0100, Andrea Arcangeli wrote:
> Difference between #v7 and #v8:

Here is just a couple of checkpatch fixes on top of the last patches.

Index: linux-2.6/include/linux/mmu_notifier.h
===================================================================
--- linux-2.6.orig/include/linux/mmu_notifier.h
+++ linux-2.6/include/linux/mmu_notifier.h
@@ -46,7 +46,7 @@ struct mmu_notifier_ops {
 	 */
 	void (*invalidate_range_begin)(struct mmu_notifier *mn,
 				       struct mm_struct *mm,
-				       unsigned long start, unsigned long end);       
+				       unsigned long start, unsigned long end);
 	void (*invalidate_range_end)(struct mmu_notifier *mn,
 				     struct mm_struct *mm,
 				     unsigned long start, unsigned long end);
@@ -137,7 +137,7 @@ static inline void mmu_notifier_mm_init(
 #define ptep_clear_flush_notify(__vma, __address, __ptep)		\
 ({									\
 	pte_t __pte;							\
-	struct vm_area_struct * ___vma = __vma;				\
+	struct vm_area_struct *___vma = __vma;				\
 	unsigned long ___address = __address;				\
 	__pte = ptep_clear_flush(___vma, ___address, __ptep);		\
 	mmu_notifier_invalidate_page(___vma->vm_mm, ___address);	\
@@ -147,7 +147,7 @@ static inline void mmu_notifier_mm_init(
 #define ptep_clear_flush_young_notify(__vma, __address, __ptep)		\
 ({									\
 	int __young;							\
-	struct vm_area_struct * ___vma = __vma;				\
+	struct vm_area_struct *___vma = __vma;				\
 	unsigned long ___address = __address;				\
 	__young = ptep_clear_flush_young(___vma, ___address, __ptep);	\
 	__young |= mmu_notifier_clear_flush_young(___vma->vm_mm,	\

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
