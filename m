Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 03C2B6B0036
	for <linux-mm@kvack.org>; Sun, 17 Aug 2014 02:13:28 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id fp1so5525462pdb.5
        for <linux-mm@kvack.org>; Sat, 16 Aug 2014 23:13:28 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id r12si15859848pdl.41.2014.08.16.23.13.27
        for <linux-mm@kvack.org>;
        Sat, 16 Aug 2014 23:13:28 -0700 (PDT)
Date: Sun, 17 Aug 2014 14:13:09 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 12213/12458] drivers/base/memory.c:404: undefined
 reference to `.test_pages_in_a_zone'
Message-ID: <53f047f5.C5kYulglgZIQzqlN%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   7bef919141fc53b780070a0aec3ddd893eeece8f
commit: 42715491368cfb19c59b9dc9d7c3dda857c82291 [12213/12458] memory-hotplug: add sysfs zones_online_to attribute
config: make ARCH=powerpc ps3_defconfig

All error/warnings:

   drivers/built-in.o: In function `show_zones_online_to':
>> drivers/base/memory.c:404: undefined reference to `.test_pages_in_a_zone'

vim +404 drivers/base/memory.c

   398	
   399		start_pfn = section_nr_to_pfn(mem->start_section_nr);
   400		end_pfn = start_pfn + nr_pages;
   401		first_page = pfn_to_page(start_pfn);
   402	
   403		/*The block contains more than one zone can not be offlined.*/
 > 404		if (!test_pages_in_a_zone(start_pfn, end_pfn))
   405			return sprintf(buf, "none\n");
   406	
   407		zone = page_zone(first_page);

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
