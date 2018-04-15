Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 70F586B0003
	for <linux-mm@kvack.org>; Sun, 15 Apr 2018 14:22:03 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id b9so10620634wrj.15
        for <linux-mm@kvack.org>; Sun, 15 Apr 2018 11:22:03 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id u17si2478475edf.290.2018.04.15.11.22.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Apr 2018 11:22:01 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v4 0/3] restructure memfd code
Date: Sun, 15 Apr 2018 11:21:16 -0700
Message-Id: <20180415182119.4517-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@gmail.com>, David Herrmann <dh.herrmann@gmail.com>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

This is a replacement for "Patch series restructure memfd code, v2"
which was previously in mmotm.  This previous series incorrectly moved
the memfd code out of shemm.c as a separate commit.  Please let me know
if there are any issues with the way code is restructured/moved in this
series.  Specifically, the last patch.

While redoing the series, all sparse warnings in mm/shmem.c are fixed
in patch 1.  Patch 2 updates comments, definitions, function names and
file checking such that patch 3 is code movement only.

v4 adds more cleanups in patch 2 before code movement.

Mike Kravetz (3):
  mm/shmem: add __rcu annotations and properly deref radix entry
  mm/shmem: update file sealing comments and file checking
  mm: restructure memfd code

 fs/Kconfig               |   3 +
 fs/fcntl.c               |   2 +-
 include/linux/memfd.h    |  16 +++
 include/linux/shmem_fs.h |  13 --
 mm/Makefile              |   1 +
 mm/memfd.c               | 345 +++++++++++++++++++++++++++++++++++++++++++++++
 mm/shmem.c               | 338 ++--------------------------------------------
 7 files changed, 377 insertions(+), 341 deletions(-)
 create mode 100644 include/linux/memfd.h
 create mode 100644 mm/memfd.c

-- 
2.13.6
