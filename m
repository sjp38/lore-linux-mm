Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id D95F86B0031
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 19:57:29 -0400 (EDT)
Received: by mail-ob0-f175.google.com with SMTP id vb8so3494230obc.6
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 16:57:28 -0700 (PDT)
Received: from g2t2354.austin.hp.com (g2t2354.austin.hp.com. [15.217.128.53])
        by mx.google.com with ESMTPS id jh2si15128179obb.203.2014.04.14.16.57.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 14 Apr 2014 16:57:28 -0700 (PDT)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 0/3] mm: vmacache updates
Date: Mon, 14 Apr 2014 16:57:18 -0700
Message-Id: <1397519841-24847-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, davidlohr@hp.com, aswin@hp.com

Two additions really. The first patch adds some needed debugging info.
The second one includes an optimization suggested by Oleg. I preferred
waiting until 3.15 for these, giving the code a chance to settle a bit.

Thanks!

Davidlohr Bueso (3):
  mm: fix CONFIG_DEBUG_VM_RB description
  mm,vmacache: add debug data
  mm,vmacache: optimize overflow system-wide flushing

 include/linux/vm_event_item.h |  4 ++++
 include/linux/vmstat.h        |  6 ++++++
 lib/Kconfig.debug             | 13 +++++++++++--
 mm/vmacache.c                 | 19 ++++++++++++++++++-
 mm/vmstat.c                   |  4 ++++
 5 files changed, 43 insertions(+), 3 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
