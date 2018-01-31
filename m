Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0B93F6B0003
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 16:03:26 -0500 (EST)
Received: by mail-yw0-f197.google.com with SMTP id a81so15144145ywe.3
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 13:03:26 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 12si190305qtm.361.2018.01.31.13.03.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 13:03:24 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v2 0/2] optimize memory hotplug
Date: Wed, 31 Jan 2018 16:02:58 -0500
Message-Id: <20180131210300.22963-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, vbabka@suse.cz, bharata@linux.vnet.ibm.com

Changelog:
	v1 - v2
	Added struct page poisoning checking in order to verify that
	struct pages are never accessed until initialized during memory
	hotplug

Pavel Tatashin (2):
  mm: uninitialized struct page poisoning sanity checking
  mm, memory_hotplug: optimize memory hotplug

 drivers/base/memory.c          | 38 +++++++++++++++++++++-----------------
 drivers/base/node.c            | 17 ++++++++++-------
 include/linux/memory_hotplug.h |  2 ++
 include/linux/mm.h             |  4 +++-
 include/linux/node.h           |  4 ++--
 include/linux/page-flags.h     | 22 +++++++++++++++++-----
 mm/memblock.c                  |  2 +-
 mm/memory_hotplug.c            | 21 ++-------------------
 mm/page_alloc.c                | 28 ++++++++++------------------
 mm/sparse.c                    | 29 ++++++++++++++++++++++++++---
 10 files changed, 94 insertions(+), 73 deletions(-)

-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
