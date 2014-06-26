Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 525AD6B009A
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 13:18:39 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id w10so3280175pde.24
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 10:18:39 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id xk1si10803479pab.68.2014.06.26.10.18.38
        for <linux-mm@kvack.org>;
        Thu, 26 Jun 2014 10:18:38 -0700 (PDT)
Date: Fri, 27 Jun 2014 01:16:27 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 267/319]
 drivers/staging/emxx_udc/emxx_udc.c:3287:3: error: implicit declaration of
 function 'strict_strtol'
Message-ID: <53ac556b.+g45EjHnjjbYiaYP%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Walter <dwalter@google.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   9477ec75947f2cf0fc47e8ab781a5e9171099be2
commit: a8dd850199c85e4c424a6c4b0d80288d3b1f4ba5 [267/319] include/linux: remove strict_strto* definitions
config: make ARCH=arm allmodconfig

All error/warnings:

   drivers/staging/emxx_udc/emxx_udc.c: In function 'nbu2ss_drv_set_ep_info':
>> drivers/staging/emxx_udc/emxx_udc.c:3287:3: error: implicit declaration of function 'strict_strtol' [-Werror=implicit-function-declaration]
      res = strict_strtol(tempbuf, 16, &num);
      ^
   drivers/staging/emxx_udc/emxx_udc.c: In function 'nbu2ss_drv_probe':
   drivers/staging/emxx_udc/emxx_udc.c:3370:2: error: implicit declaration of function 'devm_request_and_ioremap' [-Werror=implicit-function-declaration]
     mmio_base = devm_request_and_ioremap(&pdev->dev, r);
     ^
   drivers/staging/emxx_udc/emxx_udc.c:3370:12: warning: assignment makes pointer from integer without a cast
     mmio_base = devm_request_and_ioremap(&pdev->dev, r);
               ^
   cc1: some warnings being treated as errors

vim +/strict_strtol +3287 drivers/staging/emxx_udc/emxx_udc.c

3d17e832e mmotm auto import 2014-06-26  3281  		long	num;
3d17e832e mmotm auto import 2014-06-26  3282  		int	res;
3d17e832e mmotm auto import 2014-06-26  3283  		char	tempbuf[2];
3d17e832e mmotm auto import 2014-06-26  3284  
3d17e832e mmotm auto import 2014-06-26  3285  		tempbuf[0] = name[2];
3d17e832e mmotm auto import 2014-06-26  3286  		tempbuf[1] = '\0';
3d17e832e mmotm auto import 2014-06-26 @3287  		res = strict_strtol(tempbuf, 16, &num);
3d17e832e mmotm auto import 2014-06-26  3288  
3d17e832e mmotm auto import 2014-06-26  3289  		if (num == 0)
3d17e832e mmotm auto import 2014-06-26  3290  			ep->ep.maxpacket = EP0_PACKETSIZE;

:::::: The code at line 3287 was first introduced by commit
:::::: 3d17e832e96cd00132dd72bede3f5435b5c9b540 linux-next

:::::: TO: mmotm auto import <mm-commits@vger.kernel.org>
:::::: CC: Johannes Weiner <hannes@cmpxchg.org>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
