Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id DDCCD6B0031
	for <linux-mm@kvack.org>; Wed, 26 Mar 2014 19:49:48 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id rp16so2631028pbb.31
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 16:49:48 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id wt1si104374pbc.290.2014.03.26.16.49.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Mar 2014 16:49:47 -0700 (PDT)
From: Mitchel Humpherys <mitchelh@codeaurora.org>
Subject: [PATCH] Some printk cleanup in mm
Date: Wed, 26 Mar 2014 16:49:42 -0700
Message-Id: <1395877783-18910-1-git-send-email-mitchelh@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Mitchel Humpherys <mitchelh@codeaurora.org>

This series cleans up some printks in the mm code that were missing
log levels.

Mitchel Humpherys (1):
  mm: convert some level-less printks to pr_*

 mm/bounce.c    |  5 +++--
 mm/mempolicy.c |  3 ++-
 mm/mmap.c      | 19 ++++++++++---------
 mm/nommu.c     |  3 ++-
 mm/slub.c      |  7 ++++---
 mm/vmscan.c    |  3 ++-
 6 files changed, 23 insertions(+), 17 deletions(-)

-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
