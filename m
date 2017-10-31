Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id EBC0A6B0253
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 14:40:58 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id c77so20009051oig.4
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 11:40:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 6si1232504oic.146.2017.10.31.11.40.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 11:40:58 -0700 (PDT)
From: =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>
Subject: [PATCH 0/6] memfd: add sealing to hugetlb-backed memory
Date: Tue, 31 Oct 2017 19:40:46 +0100
Message-Id: <20171031184052.25253-1-marcandre.lureau@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com, mike.kravetz@oracle.com, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>

Hi,

Recently, Mike Kravetz added hugetlbfs support to memfd. However, he
didn't add sealing support. One of the reasons to use memfd is to have
shared memory sealing when doing IPC or sharing memory with another
process with some extra safety. qemu uses shared memory & hugetables
with vhost-user (used by dpdk), so it is reasonable to use memfd
now instead for convenience and security reasons.

Thanks!

RFC->v1:
- split rfc patch, after early review feedback
- added patch for memfd-test changes
- fix build with hugetlbfs disabled
- small code and commit messages improvements

Marc-AndrA(C) Lureau (6):
  shmem: unexport shmem_add_seals()/shmem_get_seals()
  shmem: rename functions that are memfd-related
  hugetlb: expose hugetlbfs_inode_info in header
  hugetlbfs: implement memfd sealing
  shmem: add sealing support to hugetlb-backed memfd
  memfd-tests: test hugetlbfs sealing

 fs/fcntl.c                                 |   2 +-
 fs/hugetlbfs/inode.c                       |  39 +++++---
 include/linux/hugetlb.h                    |  11 +++
 include/linux/shmem_fs.h                   |   6 +-
 mm/shmem.c                                 |  59 +++++++-----
 tools/testing/selftests/memfd/memfd_test.c | 150 +++--------------------------
 6 files changed, 89 insertions(+), 178 deletions(-)

-- 
2.15.0.rc0.40.gaefcc5f6f

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
