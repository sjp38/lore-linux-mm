Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id D2A926B0255
	for <linux-mm@kvack.org>; Fri, 11 Sep 2015 08:19:49 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so75346028pac.2
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 05:19:49 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id l3si156609pbq.44.2015.09.11.05.19.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Sep 2015 05:19:49 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so75345827pac.2
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 05:19:49 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH v2 0/2] mm:constify zpool/zs_pool char members
Date: Fri, 11 Sep 2015 21:18:35 +0900
Message-Id: <1441973917-6948-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hi,
Two trivial patches to constify zs_pool and zpool ->name and ->type
members and functions' signatures that set/return them.


Sergey Senozhatsky (2):
  mm:zpool: constify struct zpool type
  mm:zsmalloc: constify struct zs_pool name

 include/linux/zpool.h    | 10 ++++++----
 include/linux/zsmalloc.h |  2 +-
 mm/zbud.c                |  2 +-
 mm/zpool.c               | 10 +++++-----
 mm/zsmalloc.c            | 10 +++++-----
 5 files changed, 18 insertions(+), 16 deletions(-)

-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
