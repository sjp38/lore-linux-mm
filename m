Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9DBB96B0038
	for <linux-mm@kvack.org>; Sun, 18 Dec 2016 09:48:34 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id a190so50565424pgc.0
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 06:48:34 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id q127si15341418pfb.189.2016.12.18.06.48.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Dec 2016 06:48:33 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id i88so6388254pfk.2
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 06:48:33 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH V2 0/2] mm/memblock.c: fix potential bug and code refine
Date: Sun, 18 Dec 2016 14:47:48 +0000
Message-Id: <1482072470-26151-1-git-send-email-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: trivial@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

Here are two patch of mm/memblock.c.
[1]. A trivial code refine in memblock_is_region_memory(), which removes an
unnecessary check on base address.
[2]. The original code forgets to check the return value of
memblock_reserve(), which may lead to potential problem. The patch fix this.

---
v2: remove a trivial code refine, which is already fixed in upstream 

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
