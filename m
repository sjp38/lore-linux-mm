Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2BD866B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 06:00:08 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id g18so29546379lfg.2
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 03:00:08 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id ju5si25049wjc.272.2016.07.13.03.00.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 03:00:06 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 425C11C1D03
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 11:00:06 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 0/4] Follow-up fixes to node-lru series v1
Date: Wed, 13 Jul 2016 11:00:00 +0100
Message-Id: <1468404004-5085-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

These are some follow-up fixes to the node-lru series based on feedback
from Johannes and Minchan.

 include/linux/vm_event_item.h |  2 +-
 mm/page-writeback.c           | 16 ++++++++++------
 mm/vmscan.c                   | 15 ++++++++-------
 mm/vmstat.c                   |  2 +-
 4 files changed, 20 insertions(+), 15 deletions(-)

-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
