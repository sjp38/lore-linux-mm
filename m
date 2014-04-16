Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9DE046B0031
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 20:18:43 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id p10so10033603pdj.17
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 17:18:43 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id tc10si8726070pbc.461.2014.04.15.17.18.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Apr 2014 17:18:42 -0700 (PDT)
From: Mitchel Humpherys <mitchelh@codeaurora.org>
Subject: [PATCH v4] Some printk cleanup in mm
Date: Tue, 15 Apr 2014 17:18:29 -0700
Message-Id: <1397607510-16084-1-git-send-email-mitchelh@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Mitchel Humpherys <mitchelh@codeaurora.org>

This series cleans up some printks in the mm code that were missing
log levels.

Changelog:

  - v4: Remove redundant prefixes due to pr_fmt, improve commit
    message (suggested by Andrew Morton)

  - v3: Leaving slub.c alone. It's using hand-tagged printk's
    correctly so it's probably just churn to convert everything to the
    pr_ macros.

  - v2: Suggestions by Joe Perches (pr_fmt, pr_cont, pr_err, __func__,
    missing \n)

Mitchel Humpherys (1):
  mm: convert some level-less printks to pr_*

 mm/bounce.c    |  7 +++++--
 mm/mempolicy.c |  5 ++++-
 mm/mmap.c      | 21 ++++++++++++---------
 mm/nommu.c     |  5 ++++-
 mm/vmscan.c    |  5 ++++-
 5 files changed, 29 insertions(+), 14 deletions(-)

-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
