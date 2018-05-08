Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AD4426B0266
	for <linux-mm@kvack.org>; Tue,  8 May 2018 06:42:32 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id m68so24280637pfm.20
        for <linux-mm@kvack.org>; Tue, 08 May 2018 03:42:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o15-v6sor4689669pgq.141.2018.05.08.03.42.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 May 2018 03:42:31 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm/memblock: print memblock_remove
Date: Tue,  8 May 2018 19:42:23 +0900
Message-Id: <20180508104223.8028-1-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>

memblock_remove report is useful to see why MemTotal of /proc/meminfo
between two kernels makes difference.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/memblock.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/memblock.c b/mm/memblock.c
index 5228f594b13c..03d48d8835ba 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -697,6 +697,11 @@ static int __init_memblock memblock_remove_range(struct memblock_type *type,
 
 int __init_memblock memblock_remove(phys_addr_t base, phys_addr_t size)
 {
+	phys_addr_t end = base + size - 1;
+
+	memblock_dbg("memblock_remove: [%pa-%pa] %pS\n",
+		     &base, &end, (void *)_RET_IP_);
+
 	return memblock_remove_range(&memblock.memory, base, size);
 }
 
-- 
2.17.0.441.gb46fe60e1d-goog
