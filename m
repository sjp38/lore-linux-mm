Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 42DCA6B025F
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 17:00:30 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 77so53854336itj.4
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 14:00:30 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id x190si38704ite.36.2017.08.11.14.00.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 14:00:29 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v1 0/1] discard memblock data later
Date: Fri, 11 Aug 2017 17:00:17 -0400
Message-Id: <1502485218-318324-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, mgorman@techsingularity.net

This fixes a problem with use after free that can happen when there are
many physical regions and deferred pages are enabled.

Also, this fix is needed for my upcoming improvements to deferred pages:
"complete deferred page initialization", where we do not zero the backing
struct page memory.

Pavel Tatashin (1):
  mm: discard memblock data later

 include/linux/memblock.h |  8 +++++---
 mm/memblock.c            | 38 +++++++++++++++++---------------------
 mm/nobootmem.c           | 16 ----------------
 mm/page_alloc.c          |  4 ++++
 4 files changed, 26 insertions(+), 40 deletions(-)

-- 
2.14.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
