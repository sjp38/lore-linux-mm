Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id B1BB06B0036
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 11:17:44 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kp14so3253138pab.5
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 08:17:44 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id pu6si5054138pac.184.2014.04.25.08.17.43
        for <linux-mm@kvack.org>;
        Fri, 25 Apr 2014 08:17:43 -0700 (PDT)
Date: Fri, 25 Apr 2014 23:17:25 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [mmotm:master 81/302] drivers/iommu/intel-iommu.c:3214:3: error:
 implicit declaration of function 'dma_alloc_from_contiguous'
Message-ID: <20140425151725.GH31117@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   25153c2ef8124ecd930de79236e7fe25ad2507cb
commit: f57578494f69571fa12bae97cc67884c3522e7c6 [81/302] intel-iommu: integrate DMA CMA
config: make ARCH=ia64 allmodconfig

All error/warnings:

   drivers/iommu/intel-iommu.c: In function 'intel_alloc_coherent':
>> drivers/iommu/intel-iommu.c:3214:3: error: implicit declaration of function 'dma_alloc_from_contiguous' [-Werror=implicit-function-declaration]
>> drivers/iommu/intel-iommu.c:3214:8: warning: assignment makes pointer from integer without a cast [enabled by default]
>> drivers/iommu/intel-iommu.c:3217:4: error: implicit declaration of function 'dma_release_from_contiguous' [-Werror=implicit-function-declaration]
   cc1: some warnings being treated as errors

vim +/dma_alloc_from_contiguous +3214 drivers/iommu/intel-iommu.c

e8bb910d drivers/pci/intel-iommu.c   Alex Williamson       2009-11-04  3208  			flags |= GFP_DMA32;
e8bb910d drivers/pci/intel-iommu.c   Alex Williamson       2009-11-04  3209  	}
ba395927 drivers/pci/intel-iommu.c   Keshavamurthy, Anil S 2007-10-21  3210  
f5757849 drivers/iommu/intel-iommu.c Akinobu Mita          2014-04-24  3211  	if (flags & __GFP_WAIT) {
f5757849 drivers/iommu/intel-iommu.c Akinobu Mita          2014-04-24  3212  		unsigned int count = size >> PAGE_SHIFT;
f5757849 drivers/iommu/intel-iommu.c Akinobu Mita          2014-04-24  3213  
f5757849 drivers/iommu/intel-iommu.c Akinobu Mita          2014-04-24 @3214  		page = dma_alloc_from_contiguous(dev, count, order);
f5757849 drivers/iommu/intel-iommu.c Akinobu Mita          2014-04-24  3215  		if (page && iommu_no_mapping(dev) &&
f5757849 drivers/iommu/intel-iommu.c Akinobu Mita          2014-04-24  3216  		    page_to_phys(page) + size > dev->coherent_dma_mask) {
f5757849 drivers/iommu/intel-iommu.c Akinobu Mita          2014-04-24 @3217  			dma_release_from_contiguous(dev, page, count);
f5757849 drivers/iommu/intel-iommu.c Akinobu Mita          2014-04-24  3218  			page = NULL;
f5757849 drivers/iommu/intel-iommu.c Akinobu Mita          2014-04-24  3219  		}
f5757849 drivers/iommu/intel-iommu.c Akinobu Mita          2014-04-24  3220  	}

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
