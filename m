Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B1B0F6B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 07:15:44 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f126so468710wma.3
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 04:15:44 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id s70si150338wme.28.2016.06.22.04.15.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 04:15:41 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id 187so199374wmz.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 04:15:41 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RFC PATCH v2 0/3] mm, thp: convert from optimistic swapin collapsing to conservative
Date: Wed, 22 Jun 2016 14:15:18 +0300
Message-Id: <1466594120-2905-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

This patch series supplies to decide to swapin looking the amount of
young pages. Removes allocstall comparing and fixes comment inconsistency.

Ebru Akagunduz (3):
  mm, thp: revert allocstall comparing
  mm, thp: convert from optimistic swapin collapsing to conservative
  mm, thp: fix comment inconsistency for swapin readahead functions

 include/trace/events/huge_memory.h | 19 ++++++-----
 mm/huge_memory.c                   | 70 +++++++++++++++++---------------------
 2 files changed, 43 insertions(+), 46 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
