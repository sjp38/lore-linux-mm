Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id C3E686B0005
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 23:11:03 -0500 (EST)
Date: Wed, 23 Jan 2013 13:11:01 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Build error of mmotm-2013-01-18-15-48
Message-ID: <20130123041101.GC2723@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: linux-mm@kvack.org

Hi Tang Chen,

I encountered build error from mmotm-2013-01-18-15-48 when I try to
build ARM config. I know you sent a bunch of patches but not sure
it was fixed via them.

Thanks.

  CHK     include/generated/uapi/linux/version.h
  CHK     include/generated/utsrelease.h
make[1]: `include/generated/mach-types.h' is up to date.
  CALL    scripts/checksyscalls.sh
  CC      mm/memblock.o
mm/memblock.c: In function 'memblock_find_in_range_node':
mm/memblock.c:104: error: invalid use of undefined type 'struct movablecore_map'
mm/memblock.c:123: error: invalid use of undefined type 'struct movablecore_map'
mm/memblock.c:130: error: invalid use of undefined type 'struct movablecore_map'
mm/memblock.c:131: error: invalid use of undefined type 'struct movablecore_map'

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
