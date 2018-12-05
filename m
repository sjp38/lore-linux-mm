Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9BF3C6B738A
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 04:12:23 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id e89so16251326pfb.17
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 01:12:23 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id i1si17021185pgs.417.2018.12.05.01.12.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 01:12:21 -0800 (PST)
Date: Wed, 5 Dec 2018 17:12:06 +0800
From: kbuild test robot <lkp@intel.com>
Subject: [mmotm:master 128/293] kernel/sysctl.o:undefined reference to
 `fragment_stall_order_sysctl_handler'
Message-ID: <201812051704.QejGRMmV%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="lrZ03NoBR/3+SXJZ"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   7072a0ce81c613d27563eed5425727d1d8791f58
commit: e3e68607541c60671eb3499a2c064d2f71626da4 [128/293] mm: stall movable allocations until kswapd progresses during serious external fragmentation event
config: c6x-evmc6678_defconfig (attached as .config)
compiler: c6x-elf-gcc (GCC) 8.1.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout e3e68607541c60671eb3499a2c064d2f71626da4
        # save the attached .config to linux build tree
        GCC_VERSION=8.1.0 make.cross ARCH=c6x 

All errors (new ones prefixed by >>):

>> kernel/sysctl.o:(.fardata+0x5b4): undefined reference to `fragment_stall_order_sysctl_handler'

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--lrZ03NoBR/3+SXJZ
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--lrZ03NoBR/3+SXJZ--
