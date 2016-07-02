Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7E3BA6B0005
	for <linux-mm@kvack.org>; Sat,  2 Jul 2016 12:17:30 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ts6so263810635pac.1
        for <linux-mm@kvack.org>; Sat, 02 Jul 2016 09:17:30 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id e72si4995199pfd.241.2016.07.02.09.17.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Jul 2016 09:17:29 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id c74so12583878pfb.0
        for <linux-mm@kvack.org>; Sat, 02 Jul 2016 09:17:28 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH 0/3][RFC] mm/page:_owner: track page free call chain
Date: Sun,  3 Jul 2016 01:16:53 +0900
Message-Id: <20160702161656.14071-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hello,

	RFC

Page owner tracks a call chain that has allocated a page, this
patch set extends it with a PAGE_OWNER_TRACK_FREE functionality,
that now also tracks a call chain that has freed the page.

Page dump, thus, now has the following format:

	a) page allocated backtrace
	b) page free backtrace
	c) backtrace of path that has trigger bad page

For a quick example of a case when this new b) part can make a
difference please see 0003.

Sergey Senozhatsky (3):
  mm/page_owner: rename page_owner functions
  mm/page_owner: rename PAGE_EXT_OWNER flag
  mm/page_owner: track page free call chain

 include/linux/page_ext.h   |  15 ++++++-
 include/linux/page_owner.h |  16 +++----
 lib/Kconfig.debug          |  10 +++++
 mm/page_alloc.c            |   4 +-
 mm/page_owner.c            | 110 +++++++++++++++++++++++++++++++--------------
 mm/vmstat.c                |   5 ++-
 6 files changed, 113 insertions(+), 47 deletions(-)

-- 
2.9.0.37.g6d523a3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
