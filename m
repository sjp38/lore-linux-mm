Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2FF266B02B4
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 02:21:08 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l43so17668555wrl.2
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 23:21:08 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id u13si11870787wrc.318.2017.06.19.23.21.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 23:21:06 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5K6Ig1o137408
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 02:21:05 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2b6mkmw3dv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 02:21:04 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 20 Jun 2017 07:21:00 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 0/7] userfaultfd: enable zeropage support for shmem 
Date: Tue, 20 Jun 2017 09:20:45 +0300
Message-Id: <1497939652-16528-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

These patches enable support for UFFDIO_ZEROPAGE for shared memory.

The first two patches are not strictly related to userfaultfd, they are
just minor refactoring to reduce amount of code duplication.

Mike Rapoport (7):
  shmem: shmem_charge: verify max_block is not exceeded before inode update
  shmem: introduce shmem_inode_acct_block
  userfaultfd: shmem: add shmem_mfill_zeropage_pte for userfaultfd support
  userfaultfd: mcopy_atomic: introduce mfill_atomic_pte helper
  userfaultfd: shmem: wire up shmem_mfill_zeropage_pte
  userfaultfd: report UFFDIO_ZEROPAGE as available for shmem VMAs
  userfaultfd: selftest: enable testing of UFFDIO_ZEROPAGE for shmem

 fs/userfaultfd.c                         |  10 +-
 include/linux/shmem_fs.h                 |   6 ++
 mm/shmem.c                               | 167 +++++++++++++++++--------------
 mm/userfaultfd.c                         |  48 ++++++---
 tools/testing/selftests/vm/userfaultfd.c |   2 +-
 5 files changed, 136 insertions(+), 97 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
