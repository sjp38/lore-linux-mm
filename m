Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1D8BE6B005C
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 10:09:19 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e39.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7EE4JGO023072
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 08:04:19 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7EE96kJ097570
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 08:09:12 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7EE8uWE031223
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 08:08:56 -0600
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: [PATCH 0/3] Add pseudo-anonymous huge page mappings V3
Date: Fri, 14 Aug 2009 15:08:46 +0100
Message-Id: <cover.1250258125.git.ebmunson@us.ibm.com>
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
  Add MAP_HUGETLB example

 Documentation/vm/00-INDEX         |    2 +
 Documentation/vm/hugetlbpage.txt  |   14 ++++---
 Documentation/vm/map_hugetlb.c    |   77 +++++++++++++++++++++++++++++++++++++
 fs/hugetlbfs/inode.c              |   22 +++++++++--
 include/asm-generic/mman-common.h |    1 +
 include/linux/hugetlb.h           |   17 ++++++++-
 ipc/shm.c                         |    3 +-
 mm/mmap.c                         |   16 ++++++++
 8 files changed, 140 insertions(+), 12 deletions(-)
 create mode 100644 Documentation/vm/map_hugetlb.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
