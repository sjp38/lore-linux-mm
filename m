Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 65EC86B0008
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 19:05:45 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id i204so6213951ywb.14
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 16:05:45 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id y36-v6si269195ybi.1.2018.04.09.16.05.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 16:05:44 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v3 0/3] restructure memfd code
Date: Mon,  9 Apr 2018 16:05:02 -0700
Message-Id: <20180409230505.18953-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@gmail.com>, David Herrmann <dh.herrmann@gmail.com>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

This is a replacement for "Patch series restructure memfd code, v2"
which is currently in mmotm and consists of:
- mm: hugetlbfs: move HUGETLBFS_I outside #ifdef CONFIG_HUGETLBFS
- mm: memfd: split out memfd for use by multiple filesystems
- mm: memfd: remove memfd code from shmem files and use new memfd files

The above series incorrectly moves the memfd code out of shemm.c as
a separate commit.  Please let me know if there are any issues with
the way code is restructured/moved in this series.  Specifically,
the last patch.

While redoing the series, all sparse warnings in mm/shmem.c are fixed
in patch 1.  Patch 2 updates comments and file checking such that patch
3 is only code movement.

Mike Kravetz (3):
  mm/shmem: add __rcu annotations and properly deref radix entry
  mm/shmem: update file sealing comments and file checking
  mm: restructure memfd code

 fs/Kconfig               |   3 +
 fs/fcntl.c               |   2 +-
 include/linux/memfd.h    |  16 +++
 include/linux/shmem_fs.h |  13 --
 mm/Makefile              |   1 +
 mm/memfd.c               | 344 +++++++++++++++++++++++++++++++++++++++++++++++
 mm/shmem.c               | 338 ++--------------------------------------------
 7 files changed, 376 insertions(+), 341 deletions(-)
 create mode 100644 include/linux/memfd.h
 create mode 100644 mm/memfd.c

-- 
2.13.6
