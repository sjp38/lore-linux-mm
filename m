Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3F1846B0035
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 18:21:19 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id cc10so1449919wib.3
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 15:21:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id cz6si3828162wjc.27.2014.06.12.15.21.16
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 15:21:17 -0700 (PDT)
Message-ID: <539a27dd.a6b2c20a.123e.ffff8f52SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH -mm v2 00/11] pagewalk: standardize current users, move pmd locking, apply to mincore
Date: Thu, 12 Jun 2014 18:21:05 -0400
In-Reply-To: <20140612145617.5debf04bd1a2978be4a1fb88@linux-foundation.org>
References: <1402609691-13950-1-git-send-email-n-horiguchi@ah.jp.nec.com> <20140612145617.5debf04bd1a2978be4a1fb88@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

On Thu, Jun 12, 2014 at 02:56:17PM -0700, Andrew Morton wrote:
> On Thu, 12 Jun 2014 17:48:00 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > This is ver.2 of page table walker patchset.
> > 
> > I move forward on this cleanup work, and added some improvement from the
> > previous version. Major changes are:
> >  - removed walk->skip which becomes removable due to refactoring existing
> >    users
> >  - commonalized the argments of entry handlers (pte|pmd|hugetlb)_entry()
> >    which allows us to use the same function as multiple handlers.
> > 
> 
> Are you sure you didn't miss anything?
> 
> mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff.patch
> mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v2.patch
> mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v3.patch
> mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v3-fix.patch
> pagewalk-update-page-table-walker-core.patch
> pagewalk-update-page-table-walker-core-fix-end-address-calculation-in-walk_page_range.patch
> pagewalk-update-page-table-walker-core-fix-end-address-calculation-in-walk_page_range-fix.patch
> pagewalk-update-page-table-walker-core-fix.patch
> pagewalk-add-walk_page_vma.patch
> smaps-redefine-callback-functions-for-page-table-walker.patch
> clear_refs-redefine-callback-functions-for-page-table-walker.patch
> pagemap-redefine-callback-functions-for-page-table-walker.patch
> pagemap-redefine-callback-functions-for-page-table-walker-fix.patch
> numa_maps-redefine-callback-functions-for-page-table-walker.patch
> memcg-redefine-callback-functions-for-page-table-walker.patch
> arch-powerpc-mm-subpage-protc-use-walk_page_vma-instead-of-walk_page_range.patch
> pagewalk-remove-argument-hmask-from-hugetlb_entry.patch
> pagewalk-remove-argument-hmask-from-hugetlb_entry-fix.patch
> pagewalk-remove-argument-hmask-from-hugetlb_entry-fix-fix.patch
> mempolicy-apply-page-table-walker-on-queue_pages_range.patch
> mm-pagewalkc-move-pte-null-check.patch

This patchset is based on mmotm-2014-05-21-16, so supposed to be applied
on top of the above patches.

> mm-prom-pid-clear_refs-avoid-split_huge_page.patch

I didn't assume this patch as a base, so if my patchset conflicts with it,
please let me know.

> #
> mm-pagewalk-remove-pgd_entry-and-pud_entry.patch
> mm-pagewalk-replace-mm_walk-skip-with-more-general-mm_walk-control.patch
> madvise-cleanup-swapin_walk_pmd_entry.patch
> memcg-separate-mem_cgroup_move_charge_pte_range.patch
> memcg-separate-mem_cgroup_move_charge_pte_range-checkpatch-fixes.patch
> arch-powerpc-mm-subpage-protc-cleanup-subpage_walk_pmd_entry.patch
> mm-pagewalk-move-pmd_trans_huge_lock-from-callbacks-to-common-code.patch
> mm-pagewalk-move-pmd_trans_huge_lock-from-callbacks-to-common-code-checkpatch-fixes.patch
> mincore-apply-page-table-walker-on-do_mincore.patch

Yes, the current post is the revision of these patches.

And to be precise, this patchset also depends on a patch which I posted today
for the fix discussed in the thread about "kmemleak: Unable to handle kernel
paging request." So it might be a source of conflict.

Sorry if it's confusing.

Thanks,
Naoya Horiguchi

> 
> mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff.patch
> apepars to have disappeared, I didn't check the rest.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
