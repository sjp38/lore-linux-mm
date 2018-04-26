Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7CC466B0028
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 19:43:44 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id d9-v6so38018ywd.15
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 16:43:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 66-v6sor7188ywx.3.2018.04.26.16.43.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Apr 2018 16:43:43 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 0/2] mm: tweaks for improving use of vmap_area
Date: Fri, 27 Apr 2018 03:42:41 +0400
Message-Id: <20180426234243.22267-1-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, igor.stoppa@huawei.com

These two patches were written in preparation for the creation of
protectable memory, however their use is not limited to pmalloc and can
improve the use of virtally contigous memory.

The first provides a faster path from struct page to the vm_struct that
tracks it.

The second patch renames a single linked list field inside of vmap_area.
The list is currently used only for disposing of the data structure, once
it is not in use anymore.
Which means that it cold be used for other purposes while it'not queued
for destruction.

The patches can also be obtained from here:

https://github.com/Igor-security/linux/tree/preparations-for-mm


Igor Stoppa (2):
  struct page: add field for vm_struct
  vmalloc: rename llist field in vmap_area

 include/linux/mm_types.h | 1 +
 include/linux/vmalloc.h  | 2 +-
 mm/vmalloc.c             | 8 +++++---
 3 files changed, 7 insertions(+), 4 deletions(-)

-- 
2.14.1
