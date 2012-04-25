Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id F1C356B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 04:30:20 -0400 (EDT)
Received: by wgbdt14 with SMTP id dt14so1277351wgb.26
        for <linux-mm@kvack.org>; Wed, 25 Apr 2012 01:30:19 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 25 Apr 2012 16:30:19 +0800
Message-ID: <CAHnt0GXW-pyOUuBLB1n6qBP4WNGpET9er_HbJ29s5j5DE1xAdA@mail.gmail.com>
Subject: [BUG]memblock: fix overflow of array index
From: Peter Teoh <htmldeveloper@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, "H. Peter Anvin" <hpa@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org

Fixing the mismatch in signed and unsigned type assignment, which
potentially can lead to integer overflow bug.

Thanks.

Reviewed-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Peter Teoh <htmldeveloper@gmail.com>

diff --git a/mm/memblock.c b/mm/memblock.c
index a44eab3..2c621c5 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -553,8 +553,8 @@ void __init_memblock __next_free_mem_range(u64
*idx, int nid,
 {
      struct memblock_type *mem = &memblock.memory;
      struct memblock_type *rsv = &memblock.reserved;
-       int mi = *idx & 0xffffffff;
-       int ri = *idx >> 32;
+       unsigned int mi = *idx & 0xffffffff;
+       unsigned int ri = *idx >> 32;

      for ( ; mi < mem->cnt; mi++) {
              struct memblock_region *m = &mem->regions[mi];



--
Regards,
Peter Teoh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
