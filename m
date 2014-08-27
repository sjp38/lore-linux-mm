Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 482A36B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 06:17:35 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id v10so24372062pde.11
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 03:17:32 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id sp10si8588861pab.94.2014.08.27.03.16.45
        for <linux-mm@kvack.org>;
        Wed, 27 Aug 2014 03:16:45 -0700 (PDT)
Date: Wed, 27 Aug 2014 18:11:52 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 2106/2422] :undefined reference to
 `get_vm_area_caller'
Message-ID: <53fdaee8.YnauEMRHQ64SRmci%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   d05446ae2128064a4bb8f74c84f6901ffb5c94bc
commit: fa44abcad042144651fa9cd0f698c7c40a59d60f [2106/2422] common: dma-mapping: introduce common remapping functions
config: make ARCH=arm allnoconfig

All error/warnings:

   drivers/built-in.o: In function `dma_common_pages_remap':
>> :(.text+0x9f8c): undefined reference to `get_vm_area_caller'
>> :(.text+0x9fa0): undefined reference to `map_vm_area'
   drivers/built-in.o: In function `dma_common_free_remap':
>> :(.text+0xa08c): undefined reference to `find_vm_area'

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
