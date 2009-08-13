Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 56BE76B0055
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 05:57:07 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7D9qiTV025392
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 03:52:44 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7D9vB0b233826
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 03:57:11 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7D9vBGS024811
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 03:57:11 -0600
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: [PATCH 0/3] Add pseudo-anonymous huge page mappings V2
Date: Thu, 13 Aug 2009 10:57:03 +0100
Message-Id: <cover.1250156841.git.ebmunson@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: linux-man@vger.kernel.org, akpm@linux-foundation.org, mtk.manpages@gmail.com, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This patch set adds a flag to mmap that allows the user to request
a mapping to be backed with huge pages.  This mapping will borrow
functionality from the huge page shm code to create a file on the
kernel internal mount and uses it to approximate an anonymous
mapping.  The MAP_HUGETLB flag is a modifier to MAP_ANONYMOUS
and will not work without both flags being preset.

A new flag is necessary because there is no other way to hook into
huge pages without creating a file on a hugetlbfs mount which
wouldn't be MAP_ANONYMOUS.

To userspace, this mapping will behave just like an anonymous mapping
because the file is not accessible outside of the kernel.

Eric B Munson (3):
  hugetlbfs: Allow the creation of files suitable for MAP_PRIVATE on
    the vfs internal mount
  Add MAP_HUGETLB for mmaping pseudo-anonymous huge page regions
  Add MAP_HUGETLB example to vm/hugetlbpage.txt

 Documentation/vm/hugetlbpage.txt  |   80 +++++++++++++++++++++++++++++++++++++
 fs/hugetlbfs/inode.c              |   22 ++++++++--
 include/asm-generic/mman-common.h |    1 +
 include/linux/hugetlb.h           |   17 +++++++-
 ipc/shm.c                         |    3 +-
 mm/mmap.c                         |   16 +++++++
 6 files changed, 133 insertions(+), 6 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
