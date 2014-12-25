Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6907C6B0032
	for <linux-mm@kvack.org>; Thu, 25 Dec 2014 04:57:13 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id z10so11445235pdj.14
        for <linux-mm@kvack.org>; Thu, 25 Dec 2014 01:57:13 -0800 (PST)
Received: from mx1.mxmail.xiaomi.com ([58.68.235.87])
        by mx.google.com with ESMTP id kk6si21092313pbc.100.2014.12.25.01.57.10
        for <linux-mm@kvack.org>;
        Thu, 25 Dec 2014 01:57:11 -0800 (PST)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [PATCH 0/3] CMA: Handle the issues of aggressively allocate the
Date: Thu, 25 Dec 2014 17:43:25 +0800
Message-ID: <1419500608-11656-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: m.szyprowski@samsung.com, mina86@mina86.com, akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, pintu.k@samsung.com, weijie.yang@samsung.com, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com, vbabka@suse.cz, laurent.pinchart+renesas@ideasonboard.com, rientjes@google.com, sasha.levin@oracle.com, liuweixing@xiaomi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: teawater@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

I tried the Joonsoo's CMA patches [1] in my part and found that they works
better than mine [2] about handle LRU and other issues even if they
don't shrink the memory before cma_alloc.  So I began to test it in my
part.
But my colleague Weixing found some issues around it.  So we make 2 patches to
handle the issues.
And I merged cma_alloc_counter from [2] to cma_alloc work better.

This patchset is based on aa39477b5692611b91ac9455ae588738852b3f60 and [1].

[1] https://lkml.org/lkml/2014/5/28/64
[2] https://lkml.org/lkml/2014/10/15/623

Hui Zhu (3):
CMA: Fix the bug that CMA's page number is substructed twice
CMA: Fix the issue that nr_try_movable just count MIGRATE_MOVABLE memory
CMA: Add cma_alloc_counter to make cma_alloc work better if it meet busy range

 include/linux/cma.h    |    2 +
 include/linux/mmzone.h |    3 +
 mm/cma.c               |    6 +++
 mm/page_alloc.c        |   76 ++++++++++++++++++++++++++++++++++---------------
 4 files changed, 65 insertions(+), 22 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
