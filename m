Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 665616B0003
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 11:37:01 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id d10-v6so7602877pll.22
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 08:37:01 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id n7-v6si1802390plp.363.2018.07.20.08.37.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 08:37:00 -0700 (PDT)
Date: Fri, 20 Jul 2018 23:35:56 +0800
From: kbuild test robot <lkp@intel.com>
Subject: [mmotm:master 329/329] ERROR: "__phys_to_dma"
 [drivers/mtd/nand/raw/qcom_nandc.ko] undefined!
Message-ID: <201807202348.LhYolBCy%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>

Hi Andrew,

First bad commit (maybe != root cause):

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   fa5441daae8ad99af4e198bcd4d57cffdd582961
commit: fa5441daae8ad99af4e198bcd4d57cffdd582961 [329/329] linux-next-git-rejects
config: i386-allmodconfig
compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
reproduce:
        git checkout fa5441daae8ad99af4e198bcd4d57cffdd582961
        make ARCH=i386  allmodconfig
        make ARCH=i386 

All errors (new ones prefixed by >>):

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
