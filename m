Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id C64FC6B0037
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 07:24:20 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id n3so7597159wiv.17
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 04:24:20 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gv8si4397192wib.98.2014.07.23.04.24.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Jul 2014 04:24:18 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/2] Avoid unnecessary overhead in fault paths due to memcg and rss stats
Date: Wed, 23 Jul 2014 12:24:14 +0100
Message-Id: <1406114656-16350-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

While looking for something else entirely I spotted two small issues in the
page fault fast path. Enabling memcg takes the RCU read lock unnecessarily
even when the task is not part of a memcg and we fiddle with RSS stats
more than necessary. Details in the patches.

 include/linux/memcontrol.h |  8 ++++++++
 include/linux/mm_types.h   |  1 -
 mm/memory.c                | 32 +++++++++++++-------------------
 3 files changed, 21 insertions(+), 20 deletions(-)

-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
