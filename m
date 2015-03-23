Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id E2A6C6B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 09:26:24 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so187778487pdb.1
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 06:26:24 -0700 (PDT)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id g2si936268pdm.213.2015.03.23.06.26.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Mar 2015 06:26:24 -0700 (PDT)
Received: by pdbni2 with SMTP id ni2so187778166pdb.1
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 06:26:23 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH 0/2] mm/zsmalloc: trivial clean up
Date: Mon, 23 Mar 2015 22:26:37 +0900
Message-Id: <1427117199-2763-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello,

Two trivial cleanup patches.

The first one removes synchronize_rcu() from zs_compact().
Neither zsmalloc nor zram use rcu.

The second one removes redundant cond_resched() call before
the compaction busy loop.

Sergey Senozhatsky (2):
  zsmalloc: remove synchronize_rcu from zs_compact()
  zsmalloc: remove extra cond_resched() in __zs_compact

 mm/zsmalloc.c | 4 ----
 1 file changed, 4 deletions(-)

-- 
2.3.3.262.ge80e85a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
