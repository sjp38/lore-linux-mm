Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 477CA6B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 06:16:26 -0400 (EDT)
Received: by pabxg6 with SMTP id xg6so24422283pab.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 03:16:26 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id fp1si3058354pbb.20.2015.03.25.03.16.25
        for <linux-mm@kvack.org>;
        Wed, 25 Mar 2015 03:16:25 -0700 (PDT)
Date: Wed, 25 Mar 2015 18:15:45 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 6752/6952] drivers/hwmon/lm85.c:194:16: sparse:
 incorrect type in initializer (different modifiers)
Message-ID: <201503251844.PFDwmGXL%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartosz Golaszewski <bgolaszewski@baylibre.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   b2dfdab2f61ed5eb57317136d6efbb973f79210e
commit: 07502c794be12a1d42445169f70585f215d10f8c [6752/6952] hwmon: (lm85) use find_closest() in x_TO_REG() functions
reproduce:
  # apt-get install sparse
  git checkout 07502c794be12a1d42445169f70585f215d10f8c
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> drivers/hwmon/lm85.c:194:16: sparse: incorrect type in initializer (different modifiers)
   drivers/hwmon/lm85.c:194:16:    expected int *__fc_a
   drivers/hwmon/lm85.c:194:16:    got int static const [toplevel] *<noident>
>> drivers/hwmon/lm85.c:210:16: sparse: incorrect type in initializer (different modifiers)
   drivers/hwmon/lm85.c:210:16:    expected int *__fc_a
   drivers/hwmon/lm85.c:210:16:    got int const *map

vim +194 drivers/hwmon/lm85.c

   188		2000, 2500, 3300, 4000, 5000, 6600, 8000, 10000,
   189		13300, 16000, 20000, 26600, 32000, 40000, 53300, 80000
   190	};
   191	
   192	static int RANGE_TO_REG(long range)
   193	{
 > 194		return find_closest(range, lm85_range_map, ARRAY_SIZE(lm85_range_map));
   195	}
   196	#define RANGE_FROM_REG(val)	lm85_range_map[(val) & 0x0f]
   197	
   198	/* These are the PWM frequency encodings */
   199	static const int lm85_freq_map[8] = { /* 1 Hz */
   200		10, 15, 23, 30, 38, 47, 61, 94
   201	};
   202	static const int adm1027_freq_map[8] = { /* 1 Hz */
   203		11, 15, 22, 29, 35, 44, 59, 88
   204	};
   205	#define FREQ_MAP_LEN	8
   206	
   207	static int FREQ_TO_REG(const int *map,
   208			       unsigned int map_size, unsigned long freq)
   209	{
 > 210		return find_closest(freq, map, map_size);
   211	}
   212	
   213	static int FREQ_FROM_REG(const int *map, u8 reg)

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
