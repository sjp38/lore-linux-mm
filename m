Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f44.google.com (mail-vk0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id B4C3F6B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 08:00:57 -0500 (EST)
Received: by vkgy188 with SMTP id y188so15793159vkg.3
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 05:00:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h199si3878759vkf.183.2015.11.19.05.00.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 05:00:57 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/2] THP MMU gather
Date: Thu, 19 Nov 2015 14:00:50 +0100
Message-Id: <1447938052-22165-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: "\\\"Kirill A. Shutemov\\\"" <kirill@shutemov.name>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>

Hello,

there are two SMP race conditions that needs fixing, but the side
effects are none... it's all theoretical.

I'll be offline until Monday but I wanted to push this out now so it
can be reviewed sooner than later.

Thanks,
Andrea

Andrea Arcangeli (2):
  mm: thp: introduce thp_mmu_gather to pin tail pages during MMU gather
  mm: thp: put_huge_zero_page() with MMU gather

 Documentation/vm/transhuge.txt |  60 ++++++++++++++++++
 include/linux/huge_mm.h        |  85 ++++++++++++++++++++++++++
 include/linux/mm_types.h       |   1 +
 mm/huge_memory.c               |  39 ++++++++++--
 mm/page_alloc.c                |  14 +++++
 mm/swap.c                      | 134 +++++++++++++++++++++++++++++++++++------
 mm/swap_state.c                |  17 ++++--
 7 files changed, 320 insertions(+), 30 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
