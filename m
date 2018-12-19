Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8DE388E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 20:25:01 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id s27so15304083pgm.4
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 17:25:01 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r8si13824473plo.203.2018.12.18.17.24.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 17:24:59 -0800 (PST)
Date: Wed, 19 Dec 2018 01:24:58 +0000
From: Sasha Levin <sashal@kernel.org>
Subject: Re: [PATCH v2 2/2] hugetlbfs: Use i_mmap_rwsem to fix page fault/truncate race
In-Reply-To: <20181218223557.5202-3-mike.kravetz@oracle.com>
References: <20181218223557.5202-3-mike.kravetz@oracle.com>
Message-Id: <20181219012459.2675721873@mail.kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sashal@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, stable@vger.kernel.orgstable@vger.kernel.org

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: ebed4bfc8da8 [PATCH] hugetlb: fix absurd HugePages_Rsvd.

The bot has tested the following trees: v4.19.10, v4.14.89, v4.9.146, v4.4.168, v3.18.130, 

v4.19.10: : Build OK!
v4.14.89: Failed to apply! Possible dependencies:
    285b8dcaacfc ("mm, hugetlbfs: pass fault address to no page handler")

v4.9.146: Failed to apply! Possible dependencies:
    1a1aad8a9b7b ("userfaultfd: hugetlbfs: add userfaultfd hugetlb hook")
    29f3ad7d8380 ("fs: Provide function to unmap metadata for a range of blocks")
    334fd34d76f2 ("vfs: Add page_cache_seek_hole_data helper")
    369cd2121be4 ("userfaultfd: hugetlbfs: userfaultfd_huge_must_wait for hugepmd ranges")
    7868a2087ec1 ("mm/hugetlb: add size parameter to huge_pte_offset()")
    7fc9e4722435 ("fs: Introduce filemap_range_has_page()")
    82b0f8c39a38 ("mm: join struct fault_env and vm_fault")
    8bea80520750 ("mm/hugetlb.c: use huge_pte_lock instead of opencoding the lock")
    953c66c2b22a ("mm: THP page cache support for ppc64")
    d72dc8a25afc ("mm: make pagevec_lookup() update index")

v4.4.168: Failed to apply! Possible dependencies:
    0070e28d97e7 ("radix_tree: loop based on shift count, not height")
    00f47b581105 ("radix-tree: rewrite radix_tree_tag_clear")
    0e749e54244e ("dax: increase granularity of dax_clear_blocks() operations")
    1366c37ed84b ("radix tree test harness")
    29f3ad7d8380 ("fs: Provide function to unmap metadata for a range of blocks")
    334fd34d76f2 ("vfs: Add page_cache_seek_hole_data helper")
    339e6353046d ("radix_tree: tag all internal tree nodes as indirect pointers")
    4aae8d1c051e ("mm/hugetlbfs: unmap pages if page fault raced with hole punch")
    52db400fcd50 ("pmem, dax: clean up clear_pmem()")
    72e2936c04f7 ("mm: remove unnecessary condition in remove_inode_hugepages")
    7fc9e4722435 ("fs: Introduce filemap_range_has_page()")
    83929372f629 ("filemap: prepare find and delete operations for huge pages")
    ac401cc78242 ("dax: New fault locking")
    b2e0d1625e19 ("dax: fix lifetime of in-kernel dax mappings with dax_map_atomic()")
    d604c324524b ("radix-tree: introduce radix_tree_replace_clear_tags()")
    d72dc8a25afc ("mm: make pagevec_lookup() update index")
    e4b274915863 ("DAX: move RADIX_DAX_ definitions to dax.c")
    e61452365372 ("radix_tree: add support for multi-order entries")
    f9fe48bece3a ("dax: support dirty DAX entries in radix tree")

v3.18.130: Failed to apply! Possible dependencies:
    1817889e3b2c ("mm/hugetlbfs: fix bugs in fallocate hole punch of areas with holes")
    1c5ecae3a93f ("hugetlbfs: add minimum size accounting to subpools")
    1dd308a7b49d ("mm/hugetlb: document the reserve map/region tracking routines")
    5e9113731a3c ("mm/hugetlb: add cache of descriptors to resv_map for region_add")
    83cde9e8ba95 ("mm: use new helper functions around the i_mmap_mutex")
    b5cec28d36f5 ("hugetlbfs: truncate_hugepages() takes a range of pages")
    c672c7f29f2f ("mm/hugetlb: expose hugetlb fault mutex for use by fallocate")
    cf3ad20bfead ("mm/hugetlb: compute/return the number of regions added by region_add()")
    feba16e25a57 ("mm/hugetlb: add region_del() to delete a specific range of entries")


How should we proceed with this patch?

--
Thanks,
Sasha
