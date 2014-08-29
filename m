Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 30FD66B0035
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 19:36:41 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id r10so1424864pdi.15
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 16:36:40 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id hn8si2166071pac.212.2014.08.29.16.36.39
        for <linux-mm@kvack.org>;
        Fri, 29 Aug 2014 16:36:40 -0700 (PDT)
Date: Sat, 30 Aug 2014 07:36:27 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 80/287] drivers/base/memory.c:384:22: warning:
 unused variable 'zone_prev'
Message-ID: <54010e7b.VVb7MGzPloRFEoMb%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   8f1fc64dc9b39fedb7390e086001ce5ec327e80d
commit: 0bba74d83e98573d20b6039aad5f7fdf08a7618a [80/287] memory-hotplug: fix not enough check of valid zones
config: make ARCH=x86_64 allmodconfig

All warnings:

   drivers/base/memory.c: In function 'show_zones_online_to':
>> drivers/base/memory.c:384:22: warning: unused variable 'zone_prev' [-Wunused-variable]
     struct zone *zone, *zone_prev;
                         ^

vim +/zone_prev +384 drivers/base/memory.c

3947be19 Dave Hansen   2005-10-29  368   */
10fbcf4c Kay Sievers   2011-12-21  369  static ssize_t show_phys_device(struct device *dev,
10fbcf4c Kay Sievers   2011-12-21  370  				struct device_attribute *attr, char *buf)
3947be19 Dave Hansen   2005-10-29  371  {
7315f0cc Gu Zheng      2013-08-28  372  	struct memory_block *mem = to_memory_block(dev);
3947be19 Dave Hansen   2005-10-29  373  	return sprintf(buf, "%d\n", mem->phys_device);
3947be19 Dave Hansen   2005-10-29  374  }
3947be19 Dave Hansen   2005-10-29  375  
2a71168c Andrew Morton 2014-08-29  376  #ifdef CONFIG_MEMORY_HOTREMOVE
473972f2 Zhang Zhen    2014-08-29  377  static ssize_t show_zones_online_to(struct device *dev,
473972f2 Zhang Zhen    2014-08-29  378  				struct device_attribute *attr, char *buf)
473972f2 Zhang Zhen    2014-08-29  379  {
473972f2 Zhang Zhen    2014-08-29  380  	struct memory_block *mem = to_memory_block(dev);
473972f2 Zhang Zhen    2014-08-29  381  	unsigned long start_pfn, end_pfn;
473972f2 Zhang Zhen    2014-08-29  382  	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
473972f2 Zhang Zhen    2014-08-29  383  	struct page *first_page;
473972f2 Zhang Zhen    2014-08-29 @384  	struct zone *zone, *zone_prev;
473972f2 Zhang Zhen    2014-08-29  385  
473972f2 Zhang Zhen    2014-08-29  386  	start_pfn = section_nr_to_pfn(mem->start_section_nr);
473972f2 Zhang Zhen    2014-08-29  387  	end_pfn = start_pfn + nr_pages;
473972f2 Zhang Zhen    2014-08-29  388  	first_page = pfn_to_page(start_pfn);
473972f2 Zhang Zhen    2014-08-29  389  
473972f2 Zhang Zhen    2014-08-29  390  	/* The block contains more than one zone can not be offlined. */
473972f2 Zhang Zhen    2014-08-29  391  	if (!test_pages_in_a_zone(start_pfn, end_pfn))
473972f2 Zhang Zhen    2014-08-29  392  		return sprintf(buf, "none\n");

:::::: The code at line 384 was first introduced by commit
:::::: 473972f2929d9640156f9e000a204a8ece7ecd61 memory-hotplug: add sysfs valid_zones attribute

:::::: TO: Zhang Zhen <zhenzhang.zhang@huawei.com>
:::::: CC: Johannes Weiner <hannes@cmpxchg.org>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
