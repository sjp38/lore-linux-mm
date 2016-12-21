Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3FE1C6B03D9
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 18:30:48 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 127so38581254pfg.5
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 15:30:48 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id p15si740751pgg.270.2016.12.21.15.30.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 15:30:47 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id b1so17853856pgc.1
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 15:30:47 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH V3 0/2] mm/memblock.c: fix potential bug and code refine
Date: Wed, 21 Dec 2016 23:30:31 +0000
Message-Id: <1482363033-24754-1-git-send-email-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: trivial@kernel.org, akpm@linux-foundation.org, mhocko@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

Here are two patch of mm/memblock.c.
[1]. A trivial code refine in memblock_is_region_memory(), which removes an
unnecessary check on base address.
[2]. The original code forgets to check the return value of
memblock_reserve(), which may lead to potential problem. The patch fix this.

---
v3: 
   * remove the check for base instead of comment out
   * Reform the changelog
v2: 
   * remove a trivial code refine, which is already fixed in upstream 

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
