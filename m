Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3F4CF8E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 20:25:02 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id a10so13354684plp.14
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 17:25:02 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q26si12691462pgk.162.2018.12.18.17.25.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 17:25:00 -0800 (PST)
Date: Wed, 19 Dec 2018 01:24:59 +0000
From: Sasha Levin <sashal@kernel.org>
Subject: Re: [PATCH v2 1/2] hugetlbfs: use i_mmap_rwsem for more pmd sharing synchronization
In-Reply-To: <20181218223557.5202-2-mike.kravetz@oracle.com>
References: <20181218223557.5202-2-mike.kravetz@oracle.com>
Message-Id: <20181219012500.5291A218AD@mail.kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sashal@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, stable@vger.kernel.orgstable@vger.kernel.org

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: 39dde65c9940 [PATCH] shared page table for hugetlb page.

The bot has tested the following trees: v4.19.10, v4.14.89, v4.9.146, v4.4.168, v3.18.130, 

v4.19.10: Build OK!
v4.14.89: Failed to apply! Possible dependencies:
    285b8dcaacfc ("mm, hugetlbfs: pass fault address to no page handler")

v4.9.146: Failed to apply! Possible dependencies:
    1a1aad8a9b7b ("userfaultfd: hugetlbfs: add userfaultfd hugetlb hook")
    369cd2121be4 ("userfaultfd: hugetlbfs: userfaultfd_huge_must_wait for hugepmd ranges")
    7868a2087ec1 ("mm/hugetlb: add size parameter to huge_pte_offset()")
    82b0f8c39a38 ("mm: join struct fault_env and vm_fault")
    8fb5debc5fcd ("userfaultfd: hugetlbfs: add hugetlb_mcopy_atomic_pte for userfaultfd support")
    953c66c2b22a ("mm: THP page cache support for ppc64")
    ace71a19cec5 ("mm: introduce page_vma_mapped_walk()")
    fd60775aea80 ("mm, thp: avoid unlikely branches for split_huge_pmd")

v4.4.168: Failed to apply! Possible dependencies:
    01c8f1c44b83 ("mm, dax, gpu: convert vm_insert_mixed to pfn_t")
    0e749e54244e ("dax: increase granularity of dax_clear_blocks() operations")
    34c0fd540e79 ("mm, dax, pmem: introduce pfn_t")
    369cd2121be4 ("userfaultfd: hugetlbfs: userfaultfd_huge_must_wait for hugepmd ranges")
    52db400fcd50 ("pmem, dax: clean up clear_pmem()")
    66b3923a1a0f ("arm64: hugetlb: add support for PTE contiguous bit")
    7868a2087ec1 ("mm/hugetlb: add size parameter to huge_pte_offset()")
    82b0f8c39a38 ("mm: join struct fault_env and vm_fault")
    9973c98ecfda ("dax: add support for fsync/sync")
    ac401cc78242 ("dax: New fault locking")
    b2e0d1625e19 ("dax: fix lifetime of in-kernel dax mappings with dax_map_atomic()")
    bae473a423f6 ("mm: introduce fault_env")
    bc2466e42573 ("dax: Use radix tree entry lock to protect cow faults")
    e4b274915863 ("DAX: move RADIX_DAX_ definitions to dax.c")
    f9fe48bece3a ("dax: support dirty DAX entries in radix tree")

v3.18.130: Failed to apply! Possible dependencies:
    1038628d80e9 ("userfaultfd: uAPI")
    15b726ef048b ("userfaultfd: optimize read() and poll() to be O(1)")
    25edd8bffd0f ("userfaultfd: linux/Documentation/vm/userfaultfd.txt")
    2f4b829c625e ("arm64: Add support for hardware updates of the access and dirty pte bits")
    369cd2121be4 ("userfaultfd: hugetlbfs: userfaultfd_huge_must_wait for hugepmd ranges")
    3f602d2724b1 ("userfaultfd: Rename uffd_api.bits into .features")
    66b3923a1a0f ("arm64: hugetlb: add support for PTE contiguous bit")
    6910fa16dbe1 ("arm64: enable PTE type bit in the mask for pte_modify")
    736d2169338a ("parisc: Add Huge Page and HUGETLBFS support")
    7868a2087ec1 ("mm/hugetlb: add size parameter to huge_pte_offset()")
    82b0f8c39a38 ("mm: join struct fault_env and vm_fault")
    83cde9e8ba95 ("mm: use new helper functions around the i_mmap_mutex")
    86039bd3b4e6 ("userfaultfd: add new syscall to provide memory externalization")
    874bfcaf79e3 ("mm/xip: share the i_mmap_rwsem")
    8d2afd96c203 ("userfaultfd: solve the race between UFFDIO_COPY|ZEROPAGE and read")
    93ef666a094f ("arm64: Macros to check/set/unset the contiguous bit")
    a9b85f9415fd ("userfaultfd: change the read API to return a uffd_msg")
    ac401cc78242 ("dax: New fault locking")
    ba85c702e4b2 ("userfaultfd: wake pending userfaults")
    bae473a423f6 ("mm: introduce fault_env")
    bc2466e42573 ("dax: Use radix tree entry lock to protect cow faults")
    d475c6346a38 ("dax,ext2: replace XIP read and write with DAX I/O")
    de1414a654e6 ("fs: export inode_to_bdi and use it in favor of mapping->backing_dev_info")
    dfa37dc3fc1f ("userfaultfd: allow signals to interrupt a userfault")
    e4b274915863 ("DAX: move RADIX_DAX_ definitions to dax.c")
    ecf35a237a85 ("arm64: PTE/PMD contiguous bit definition")
    f24ffde43237 ("parisc: expose number of page table levels on Kconfig level")


How should we proceed with this patch?

--
Thanks,
Sasha
