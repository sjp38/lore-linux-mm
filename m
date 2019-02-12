Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25403C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:56:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE0A9214DA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:56:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE0A9214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6747A8E0115; Mon, 11 Feb 2019 21:56:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 625178E000E; Mon, 11 Feb 2019 21:56:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 514EC8E0115; Mon, 11 Feb 2019 21:56:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 267FC8E000E
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 21:56:49 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id 42so1270507qtr.7
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:56:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=znZskinMlqejREYUC3J95DT4fIEM5KhPmZXsDEmY9lU=;
        b=efCyvwbFcNJSkF+9DkVQxmykKfefvRw9DL/HD+wkkzn5l5qUU0eK+KM+4AFa+G6hmI
         YVLF4PMiH4QBhxQaocEweNjfNuMxQLEK3meOJ9XVWmeGn/dAV2S9j62mwA4yAOonkd/S
         FvfF3YD5RbW8PLTJinSvHm0BngkzI9w+GHI+y7uIQe3D+9Lyxi3fKKeIr4bjvJqcl1MK
         h+UJHmHaZgNnpPPVVBFlVkEw2j43PFo/C6zrUPU9EriIq5NxoTRC+IavjRJro03FInnA
         ky4re4X1Tt1VmSXPDfJ/HkQN3c8KyKOHUnlLY8OWZOiIT/oX90vJYr/A8KhIx/LfIiWR
         7bwQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuac/nxXIek6SHPLtx0IU58QhN86D/PWhb1n8qUSF0PkQn1ICjID
	WAb0FSDk+tdOVu1Jx71Wm56HhGsDVDoWchk2xtvCGXfRkzuoAWCR/hYki5hEiGDcIkJkS6GWMLl
	CuS/Hb6gkoRVAQpi7IrBDGDJTeA8muXZyQ7cQ0TSd82LRmzUoVWfQIyB0ZGGJWo2ecg==
X-Received: by 2002:a0c:f184:: with SMTP id m4mr1016545qvl.178.1549940208866;
        Mon, 11 Feb 2019 18:56:48 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iap4NA7KlXGOqgbmZwwvGnNwAdUrDPtv21p0Y0lkkq54dibW3mr5nbtnd0fxdT0j8KkezEF
X-Received: by 2002:a0c:f184:: with SMTP id m4mr1016511qvl.178.1549940207980;
        Mon, 11 Feb 2019 18:56:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549940207; cv=none;
        d=google.com; s=arc-20160816;
        b=T/NJ4Uyh5peI4kIwThhOl2Wl6hWloJXg+IuFtt7PhxWLVoWjiM9r6IAp0y0w84//4W
         nm2ZOIiprJAKKDOlJyd/zJmg6L47a0ilx7PaG555vDkb9uqsImVrUdFqH72PwEkjT5Vz
         5IQrz1VEWLMiL29BP7xA0GyLuHPOh8A+Iud/xiHMfKdWI5TYG9TfpfgRUR5N8cCcdKpI
         ieswayTPqKw7BzQ8IM8njlwpcxEKf0dVQsEPswCCUYRrncJ5XjzkVG96U/LMe3eIFq9D
         +OucVYzoT/tX/Lw07xnkyFfAM9KXZai7vSiEJFWcywshwcd/niLXYJGDJlpW6aeGxDVW
         njAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=znZskinMlqejREYUC3J95DT4fIEM5KhPmZXsDEmY9lU=;
        b=Jr78/E97eGlCzJ+ohnNL6vkNNM54Gw6QJc8HZTp3ue/in9SbG9M0scWjThykZq2l8X
         fcFDXYrOGE6zq68zA/OAYikeZIdPayr5fhTYj+2Zrxiw0bPl/MPtxB14EIsyQp6Y60EU
         equL6NZxArKtDHDnQcTYKN+Dcl4+aCTrcfpzfQluyNkjhFg5IGlprqUhbKDXy1B1lUuy
         nbn4MCjD+OosuxD7OF8FbecMNmpWxnRZ6oqTVc08x1YMfPG+YzdV4p+8XTps0NRJHBYx
         Zs4VsbyZqsN5YudVrUgSmPJlKNW+7aQgwu4ElAef5qqQHszVSM37fE52aNEnM6Pm5Yng
         uOuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f188si6594950qkb.226.2019.02.11.18.56.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 18:56:47 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F1650285B1;
	Tue, 12 Feb 2019 02:56:45 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 418A3600C6;
	Tue, 12 Feb 2019 02:56:33 +0000 (UTC)
From: Peter Xu <peterx@redhat.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	peterx@redhat.com,
	Martin Cracauer <cracauer@cons.org>,
	Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v2 00/26] userfaultfd: write protection support
Date: Tue, 12 Feb 2019 10:56:06 +0800
Message-Id: <20190212025632.28946-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Tue, 12 Feb 2019 02:56:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series implements initial write protection support for
userfaultfd.  Currently both shmem and hugetlbfs are not supported
yet, but only anonymous memory.  This is the 2nd version of it.

The latest code can also be found at:

  https://github.com/xzpeter/linux/tree/uffd-wp-merged

Since there's no objection on the design on previous RFC series, and
the tree has been run through various tests already so I'm removing
RFC tag starting from this version.

During previous v1 discussion, Mike asked about using userfaultfd to
track mprotect()-allowed processes.  So far I don't have good idea on
how that could work easily, so I'll assume it's not an initial goal
for current uffd-wp work.

Note again that the first 5 patches in the series can be seen as
isolated work on page fault mechanism.  I would hope that they can be
considered to be reviewed/picked even earlier than the rest of the
series since it's even useful for existing userfaultfd MISSING case
[8].

v2 changelog:
- add some r-bs
- split the patch "mm: userfault: return VM_FAULT_RETRY on signals"
  into two: one to focus on the signal behavior change, the other to
  remove the NOPAGE special path in handle_userfault().  Removing the
  ARC specific change and remove that part of commit message since
  it's fixed in 4d447455e73b already [Jerome]
- return -ENOENT when VMA is invalid for UFFDIO_WRITEPROTECT to match
  UFFDIO_COPY errno [Mike]
- add a new patch to introduce helper to find valid VMA for uffd
  [Mike]
- check against VM_MAYWRITE instead of VM_WRITE when registering UFFD
  WP [Mike]
- MM_CP_DIRTY_ACCT is used incorrectly, fix it up [Jerome]
- make sure the lock_page behavior will not be changed [Jerome]
- reorder the whole series, introduce the new ioctl last. [Jerome]
- fix up the uffdio_writeprotect() following commit df2cc96e77011cf79
  to return -EAGAIN when detected mm layout changes [Mike]

v1 can be found at: https://lkml.org/lkml/2019/1/21/130

Any comment would be greatly welcomed.   Thanks.

Overview
====================

The uffd-wp work was initialized by Shaohua Li [1], and later
continued by Andrea [2]. This series is based upon Andrea's latest
userfaultfd tree, and it is a continuous works from both Shaohua and
Andrea.  Many of the follow up ideas come from Andrea too.

Besides the old MISSING register mode of userfaultfd, the new uffd-wp
support provides another alternative register mode called
UFFDIO_REGISTER_MODE_WP that can be used to listen to not only missing
page faults but also write protection page faults, or even they can be
registered together.  At the same time, the new feature also provides
a new userfaultfd ioctl called UFFDIO_WRITEPROTECT which allows the
userspace to write protect a range or memory or fixup write permission
of faulted pages.

Please refer to the document patch "userfaultfd: wp:
UFFDIO_REGISTER_MODE_WP documentation update" for more information on
the new interface and what it can do.

The major workflow of an uffd-wp program should be:

  1. Register a memory region with WP mode using UFFDIO_REGISTER_MODE_WP

  2. Write protect part of the whole registered region using
     UFFDIO_WRITEPROTECT, passing in UFFDIO_WRITEPROTECT_MODE_WP to
     show that we want to write protect the range.

  3. Start a working thread that modifies the protected pages,
     meanwhile listening to UFFD messages.

  4. When a write is detected upon the protected range, page fault
     happens, a UFFD message will be generated and reported to the
     page fault handling thread

  5. The page fault handler thread resolves the page fault using the
     new UFFDIO_WRITEPROTECT ioctl, but this time passing in
     !UFFDIO_WRITEPROTECT_MODE_WP instead showing that we want to
     recover the write permission.  Before this operation, the fault
     handler thread can do anything it wants, e.g., dumps the page to
     a persistent storage.

  6. The worker thread will continue running with the correctly
     applied write permission from step 5.

Currently there are already two projects that are based on this new
userfaultfd feature.

QEMU Live Snapshot: The project provides a way to allow the QEMU
                    hypervisor to take snapshot of VMs without
                    stopping the VM [3].

LLNL umap library:  The project provides a mmap-like interface and
                    "allow to have an application specific buffer of
                    pages cached from a large file, i.e. out-of-core
                    execution using memory map" [4][5].

Before posting the patchset, this series was smoke tested against QEMU
live snapshot and the LLNL umap library (by doing parallel quicksort
using 128 sorting threads + 80 uffd servicing threads).  My sincere
thanks to Marty Mcfadden and Denis Plotnikov for the help along the
way.

TODO
=============

- hugetlbfs/shmem support
- performance
- more architectures
- cooperate with mprotect()-allowed processes (???)
- ...

References
==========

[1] https://lwn.net/Articles/666187/
[2] https://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git/log/?h=userfault
[3] https://github.com/denis-plotnikov/qemu/commits/background-snapshot-kvm
[4] https://github.com/LLNL/umap
[5] https://llnl-umap.readthedocs.io/en/develop/
[6] https://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git/commit/?h=userfault&id=b245ecf6cf59156966f3da6e6b674f6695a5ffa5
[7] https://lkml.org/lkml/2018/11/21/370
[8] https://lkml.org/lkml/2018/12/30/64

Andrea Arcangeli (5):
  userfaultfd: wp: hook userfault handler to write protection fault
  userfaultfd: wp: add WP pagetable tracking to x86
  userfaultfd: wp: userfaultfd_pte/huge_pmd_wp() helpers
  userfaultfd: wp: add UFFDIO_COPY_MODE_WP
  userfaultfd: wp: add the writeprotect API to userfaultfd ioctl

Martin Cracauer (1):
  userfaultfd: wp: UFFDIO_REGISTER_MODE_WP documentation update

Peter Xu (17):
  mm: gup: rename "nonblocking" to "locked" where proper
  mm: userfault: return VM_FAULT_RETRY on signals
  userfaultfd: don't retake mmap_sem to emulate NOPAGE
  mm: allow VM_FAULT_RETRY for multiple times
  mm: gup: allow VM_FAULT_RETRY for multiple times
  mm: merge parameters for change_protection()
  userfaultfd: wp: apply _PAGE_UFFD_WP bit
  mm: export wp_page_copy()
  userfaultfd: wp: handle COW properly for uffd-wp
  userfaultfd: wp: drop _PAGE_UFFD_WP properly when fork
  userfaultfd: wp: add pmd_swp_*uffd_wp() helpers
  userfaultfd: wp: support swap and page migration
  khugepaged: skip collapse if uffd-wp detected
  userfaultfd: introduce helper vma_find_uffd
  userfaultfd: wp: don't wake up when doing write protect
  userfaultfd: selftests: refactor statistics
  userfaultfd: selftests: add write-protect test

Shaohua Li (3):
  userfaultfd: wp: add helper for writeprotect check
  userfaultfd: wp: support write protection for userfault vma range
  userfaultfd: wp: enabled write protection in userfaultfd API

 Documentation/admin-guide/mm/userfaultfd.rst |  51 +++++
 arch/alpha/mm/fault.c                        |   4 +-
 arch/arc/mm/fault.c                          |  12 +-
 arch/arm/mm/fault.c                          |   9 +-
 arch/arm64/mm/fault.c                        |  11 +-
 arch/hexagon/mm/vm_fault.c                   |   3 +-
 arch/ia64/mm/fault.c                         |   3 +-
 arch/m68k/mm/fault.c                         |   5 +-
 arch/microblaze/mm/fault.c                   |   3 +-
 arch/mips/mm/fault.c                         |   3 +-
 arch/nds32/mm/fault.c                        |   7 +-
 arch/nios2/mm/fault.c                        |   5 +-
 arch/openrisc/mm/fault.c                     |   3 +-
 arch/parisc/mm/fault.c                       |   4 +-
 arch/powerpc/mm/fault.c                      |   7 +-
 arch/riscv/mm/fault.c                        |   9 +-
 arch/s390/mm/fault.c                         |  14 +-
 arch/sh/mm/fault.c                           |   5 +-
 arch/sparc/mm/fault_32.c                     |   4 +-
 arch/sparc/mm/fault_64.c                     |   4 +-
 arch/um/kernel/trap.c                        |   6 +-
 arch/unicore32/mm/fault.c                    |  10 +-
 arch/x86/Kconfig                             |   1 +
 arch/x86/include/asm/pgtable.h               |  67 ++++++
 arch/x86/include/asm/pgtable_64.h            |   8 +-
 arch/x86/include/asm/pgtable_types.h         |  11 +-
 arch/x86/mm/fault.c                          |   7 +-
 arch/xtensa/mm/fault.c                       |   4 +-
 fs/userfaultfd.c                             | 114 ++++++----
 include/asm-generic/pgtable.h                |   1 +
 include/asm-generic/pgtable_uffd.h           |  66 ++++++
 include/linux/huge_mm.h                      |   2 +-
 include/linux/mm.h                           |  21 +-
 include/linux/swapops.h                      |   2 +
 include/linux/userfaultfd_k.h                |  42 +++-
 include/trace/events/huge_memory.h           |   1 +
 include/uapi/linux/userfaultfd.h             |  28 ++-
 init/Kconfig                                 |   5 +
 mm/filemap.c                                 |   2 +-
 mm/gup.c                                     |  61 ++---
 mm/huge_memory.c                             |  28 ++-
 mm/hugetlb.c                                 |   8 +-
 mm/khugepaged.c                              |  23 ++
 mm/memory.c                                  |  28 ++-
 mm/mempolicy.c                               |   2 +-
 mm/migrate.c                                 |   7 +
 mm/mprotect.c                                |  98 ++++++--
 mm/rmap.c                                    |   6 +
 mm/userfaultfd.c                             | 148 ++++++++++---
 tools/testing/selftests/vm/userfaultfd.c     | 222 ++++++++++++++-----
 50 files changed, 919 insertions(+), 276 deletions(-)
 create mode 100644 include/asm-generic/pgtable_uffd.h

-- 
2.17.1

