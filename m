Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id AB89C6B0031
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 11:31:40 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ey11so403204pad.12
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 08:31:40 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ja1si33165094pbc.254.2014.07.03.08.31.38
        for <linux-mm@kvack.org>;
        Thu, 03 Jul 2014 08:31:39 -0700 (PDT)
Date: Thu, 03 Jul 2014 23:31:15 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [amirv:for-linux-rdma 2/5] mm/page_io.c:268:3: error: 'from'
 undeclared
Message-ID: <53b57743.uLgBMdpCvdAn3Tlh%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Amir Vadai <amirv@mellanox.com>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org

tree:   git://flatbed.openfabrics.org/~amirv/linux.git for-linux-rdma
head:   e5838d516194045c687a64d9daf482cd5b531d64
commit: 1ed9b8773efbae7a4b3685dcd9402e2fe3c710f1 [2/5] regression: mm/page_io.c: work around gcc bug
config: make ARCH=xtensa allyesconfig

All error/warnings:

   mm/page_io.c: In function '__swap_writepage':
>> mm/page_io.c:268:3: error: 'from' undeclared (first use in this function)
      from.bvec = &bv;
      ^
   mm/page_io.c:268:3: note: each undeclared identifier is reported only once for each function it appears in
>> mm/page_io.c:268:16: error: 'bv' undeclared (first use in this function)
      from.bvec = &bv;
                   ^

vim +/from +268 mm/page_io.c

   262			struct iovec iov = {
   263				.iov_base = kmap(page),
   264				.iov_len  = PAGE_SIZE,
   265			};
   266	
   267			/* Do this by hand because old gcc messes up the initializer */
 > 268			from.bvec = &bv;
   269	
   270			init_sync_kiocb(&kiocb, swap_file);
   271			kiocb.ki_pos = page_file_offset(page);

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
