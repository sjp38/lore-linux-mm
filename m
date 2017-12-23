Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id C99866B0038
	for <linux-mm@kvack.org>; Sat, 23 Dec 2017 07:50:46 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id d4so15070546plr.8
        for <linux-mm@kvack.org>; Sat, 23 Dec 2017 04:50:46 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 91si12509237pla.15.2017.12.23.04.50.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Dec 2017 04:50:45 -0800 (PST)
Date: Sat, 23 Dec 2017 20:49:46 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 156/234] lib/test_kasan.c:478:27: sparse: Variable
 length array is used.
Message-ID: <201712232003.uOAMlAaO%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Lawrence <paullawrence@google.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Greg Hackmann <ghackmann@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   a4f20e3ed193cd4b2f742ce37f88112c7441146f
commit: e329261f769afff2744bfeaad6cb7e8c03048e27 [156/234] kasan: add tests for alloca poisoning
reproduce:
        # apt-get install sparse
        git checkout e329261f769afff2744bfeaad6cb7e8c03048e27
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)


vim +478 lib/test_kasan.c

   474	
   475	static noinline void __init kasan_alloca_oob_left(void)
   476	{
   477		volatile int i = 10;
 > 478		char alloca_array[i];
   479		char *p = alloca_array - 1;
   480	
   481		pr_info("out-of-bounds to left on alloca\n");
   482		*(volatile char *)p;
   483	}
   484	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
