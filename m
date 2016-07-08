Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id D60306B0260
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 08:12:02 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ts6so85616572pac.1
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 05:12:02 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id c138si5668173pfb.9.2016.07.08.05.12.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 05:12:02 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id t190so6414765pfb.2
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 05:12:01 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH v2 0/3] mm/page:_owner: track page free call chain
Date: Fri,  8 Jul 2016 21:11:29 +0900
Message-Id: <20160708121132.8253-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hello,

Page owner tracks a call chain that has allocated a page, this
patch set extends it with a free_pages call chain tracking
functionality.

Page dump, thus, now has the following format:

        a) page allocated backtrace
        b) page free backtrace
        c) backtrace of the path that has trigger bad page

For a quick example of a case when this new b) part can make a
difference please see 0003.

v2:
-- do not add PAGE_OWNER_TRACK_FREE .config -- Joonsoo
-- minor improvements

Sergey Senozhatsky (3):
  mm/page_owner: rename page_owner functions
  mm/page_owner: rename PAGE_EXT_OWNER flag
  mm/page_owner: track page free call chain

 include/linux/page_ext.h   | 13 +++++--
 include/linux/page_owner.h | 16 ++++-----
 mm/page_alloc.c            |  4 +--
 mm/page_owner.c            | 86 ++++++++++++++++++++++++++++------------------
 mm/vmstat.c                |  5 ++-
 5 files changed, 77 insertions(+), 47 deletions(-)

-- 
2.9.0.37.g6d523a3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
