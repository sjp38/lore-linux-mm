Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id D7DF46B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 07:49:51 -0400 (EDT)
Received: by ioii196 with SMTP id i196so57078875ioi.3
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 04:49:51 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id l13si5903967igt.73.2015.09.10.04.49.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Sep 2015 04:49:51 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so41433778pad.1
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 04:49:51 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH 0/2] mm:constify zpool/zs_pool char members
Date: Thu, 10 Sep 2015 20:48:36 +0900
Message-Id: <1441885718-32580-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hi,
Two trivial patches to constify zs_pool and zpool ->name and ->type
members and functions' signatures that set/return them.

Sergey SENOZHATSKY (2):
  mm:zpool: constify struct zpool type
  mm:zsmalloc: constify struct zs_pool name

 include/linux/zpool.h    | 12 +++++++-----
 include/linux/zsmalloc.h |  2 +-
 mm/zbud.c                |  2 +-
 mm/zpool.c               | 12 ++++++------
 mm/zsmalloc.c            | 10 +++++-----
 5 files changed, 20 insertions(+), 18 deletions(-)

-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
