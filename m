Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id BDE566B0253
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 10:50:29 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id r97so10707787lfi.2
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 07:50:29 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id pv4si1535165wjb.165.2016.07.18.07.50.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Jul 2016 07:50:27 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id C8E1398CF6
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 14:50:26 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 0/3] Follow-up fixes to node-lru series v3
Date: Mon, 18 Jul 2016 15:50:23 +0100
Message-Id: <1468853426-12858-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

This is another round of fixups to the node-lru series. The most important
patch is the last one which deals with a highmem accounting issue.

 include/linux/mm_inline.h |  8 ++------
 mm/vmscan.c               | 25 +++++++++++--------------
 2 files changed, 13 insertions(+), 20 deletions(-)

-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
