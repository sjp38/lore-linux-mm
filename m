Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 01C286B0260
	for <linux-mm@kvack.org>; Sat, 17 Sep 2016 12:05:22 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id b133so87960049vka.0
        for <linux-mm@kvack.org>; Sat, 17 Sep 2016 09:05:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q8si7346710ybb.144.2016.09.17.09.05.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Sep 2016 09:05:18 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/1] mm: vma_merge: fix vm_page_prot SMP race condition against rmap_walk v2
Date: Sat, 17 Sep 2016 18:05:14 +0200
Message-Id: <1474128315-22726-1-git-send-email-aarcange@redhat.com>
In-Reply-To: <20160916205441.GB4743@redhat.com>
References: <20160916205441.GB4743@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Jan Vorlicek <janvorli@microsoft.com>, Aditya Mandaleeka <adityam@microsoft.com>

This version 2 supersedes the 2/2 patch I previously sent in this
thread, and restricts the fix to case 8 as all other vma_merge cases
were already correct as Hugh pointed out, and the testcase of course
reproduced only case 8.

I verified that this fixes the race condition with the testcase as
good as the v1 patch did.

The code is the same I sent yesterday inline in the reply, but this
further improves a few comments and it's a more proper submit.

Andrea Arcangeli (1):
  mm: vma_merge: fix vm_page_prot SMP race condition against rmap_walk

 mm/mmap.c | 40 +++++++++++++++++++++++++++++++++++++---
 1 file changed, 37 insertions(+), 3 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
