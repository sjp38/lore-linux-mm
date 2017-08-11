Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id E5F3E6B025F
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 17:06:03 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id g21so53014238ioe.12
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 14:06:03 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 17si1695297ioi.372.2017.08.11.14.06.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 14:06:03 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v2 0/1] discard memblock data later
Date: Fri, 11 Aug 2017 17:05:53 -0400
Message-Id: <1502485554-318703-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, mgorman@techsingularity.net

Changelog:
v1 - v2
        - Removed debugging change to INIT_MEMBLOCK_REGIONS

This fixes a problem with use after free that can happen when there are
many physical regions and deferred pages are enabled.

Also, this fix is needed for my upcoming improvements to deferred pages:
"complete deferred page initialization", where we do not zero the backing
struct page memory.

Pavel Tatashin (1):
  mm: discard memblock data later

 include/linux/memblock.h |  6 ++++--
 mm/memblock.c            | 38 +++++++++++++++++---------------------
 mm/nobootmem.c           | 16 ----------------
 mm/page_alloc.c          |  4 ++++
 4 files changed, 25 insertions(+), 39 deletions(-)

-- 
2.14.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
