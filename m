Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 25F536B0007
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 08:38:19 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id q15so11170136wra.22
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 05:38:19 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id r66si4735833wmf.22.2018.03.05.05.38.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 05:38:17 -0800 (PST)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH 0/3] indirectly reclaimable memory
Date: Mon, 5 Mar 2018 13:37:39 +0000
Message-ID: <20180305133743.12746-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

This patch set introduces the concept of indirectly reclaimable
memory and applies it to fix the issue, when a big number
of dentries with external names can significantly affect
the MemAvailable value.

v2:
1) removed comments specific to unreclaimable slabs
2) splitted into 3 patches

v1:
https://lkml.org/lkml/2018/3/1/961

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: kernel-team@fb.com

Roman Gushchin (3):
  mm: introduce NR_INDIRECTLY_RECLAIMABLE_BYTES
  mm: treat indirectly reclaimable memory as available in MemAvailable
  dcache: account external names as indirectly reclaimable memory

 fs/dcache.c            | 29 ++++++++++++++++++++++++-----
 include/linux/mmzone.h |  1 +
 mm/page_alloc.c        |  7 +++++++
 mm/vmstat.c            |  1 +
 4 files changed, 33 insertions(+), 5 deletions(-)

-- 
2.14.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
