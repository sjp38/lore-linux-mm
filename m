Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id EF7DE6B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 06:07:29 -0400 (EDT)
Received: by pabxg6 with SMTP id xg6so24202412pab.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 03:07:29 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id o6si3002447pap.60.2015.03.25.03.07.28
        for <linux-mm@kvack.org>;
        Wed, 25 Mar 2015 03:07:29 -0700 (PDT)
Date: Wed, 25 Mar 2015 18:07:08 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 6751/6952] drivers/hwmon/ina2xx.c:162:20: sparse:
 incorrect type in initializer (different modifiers)
Message-ID: <201503251807.4D1zfPoV%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartosz Golaszewski <bgolaszewski@baylibre.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   b2dfdab2f61ed5eb57317136d6efbb973f79210e
commit: ef8e16b2c026a285a306ffb307810eecfc02f93c [6751/6952] hwmon: (ina2xx) replace ina226_avg_bits() with find_closest()
reproduce:
  # apt-get install sparse
  git checkout ef8e16b2c026a285a306ffb307810eecfc02f93c
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> drivers/hwmon/ina2xx.c:162:20: sparse: incorrect type in initializer (different modifiers)
   drivers/hwmon/ina2xx.c:162:20:    expected int *__fc_a
   drivers/hwmon/ina2xx.c:162:20:    got int static const [toplevel] *<noident>

vim +162 drivers/hwmon/ina2xx.c

   146	{
   147		int avg = ina226_avg_tab[INA226_READ_AVG(config)];
   148	
   149		/*
   150		 * Multiply the total conversion time by the number of averages.
   151		 * Return the result in milliseconds.
   152		 */
   153		return DIV_ROUND_CLOSEST(avg * INA226_TOTAL_CONV_TIME_DEFAULT, 1000);
   154	}
   155	
   156	static u16 ina226_interval_to_reg(int interval, u16 config)
   157	{
   158		int avg, avg_bits;
   159	
   160		avg = DIV_ROUND_CLOSEST(interval * 1000,
   161					INA226_TOTAL_CONV_TIME_DEFAULT);
 > 162		avg_bits = find_closest(avg, ina226_avg_tab,
   163					ARRAY_SIZE(ina226_avg_tab));
   164	
   165		return (config & ~INA226_AVG_RD_MASK) | INA226_SHIFT_AVG(avg_bits);
   166	}
   167	
   168	static void ina226_set_update_interval(struct ina2xx_data *data)
   169	{
   170		int ms;

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
