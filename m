Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id B549D280324
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 08:22:09 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so41277596wic.1
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 05:22:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w2si2242243wiy.40.2015.07.17.05.22.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 17 Jul 2015 05:22:08 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/3] Deferred memory initialisation fixes
Date: Fri, 17 Jul 2015 13:22:01 +0100
Message-Id: <1437135724-20110-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nicolai Stange <nicstange@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Alex Ng <alexng@microsoft.com>, Fengguang Wu <fengguang.wu@intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This series addresses problems reported with deferred memory initialisation
and are needed for 4.2. The first and second patches have not been confirmed
by the reporters as fixing their problems but I could replicate the issues
and they Worked For Me. The last one has been verified as working.

 fs/dcache.c        | 13 +++----------
 fs/file_table.c    | 24 +++++++++++++++---------
 include/linux/fs.h |  5 +++--
 init/main.c        |  2 +-
 mm/page_alloc.c    | 44 ++++++++++++++++++++++++++++++--------------
 5 files changed, 52 insertions(+), 36 deletions(-)

-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
