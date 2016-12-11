Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 65FDB6B0069
	for <linux-mm@kvack.org>; Sun, 11 Dec 2016 08:01:32 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id p66so176562011pga.4
        for <linux-mm@kvack.org>; Sun, 11 Dec 2016 05:01:32 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id 44si40319014plc.225.2016.12.11.05.01.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Dec 2016 05:01:31 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id p66so7839663pga.2
        for <linux-mm@kvack.org>; Sun, 11 Dec 2016 05:01:31 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 0/2] mm/memblock.c: fix potential bug and code refine
Date: Sun, 11 Dec 2016 12:59:48 +0000
Message-Id: <1481461190-11780-1-git-send-email-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: trivial@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

Here are two patch of mm/memblock.c.
[1]. A trivial code refine in memblock_is_region_memory(), which removes an
unnecessary check on base address.
[2]. The original code forgets to check the return value of
memblock_reserve(), which may lead to potential problem. The patch fix this.

Wei Yang (2):
  mm/memblock.c: trivial code refine in memblock_is_region_memory()
  mm/memblock.c: check return value of memblock_reserve() in
    memblock_virt_alloc_internal()

 include/linux/memblock.h |    5 ++---
 mm/memblock.c            |    8 +++-----
 2 files changed, 5 insertions(+), 8 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
