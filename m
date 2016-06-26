Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id F1EA26B0005
	for <linux-mm@kvack.org>; Sat, 25 Jun 2016 21:21:22 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id b13so273280919pat.3
        for <linux-mm@kvack.org>; Sat, 25 Jun 2016 18:21:22 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id vz6si4181955pab.106.2016.06.25.18.21.21
        for <linux-mm@kvack.org>;
        Sat, 25 Jun 2016 18:21:21 -0700 (PDT)
Date: Sun, 26 Jun 2016 09:19:50 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: undefined reference to `printk'
Message-ID: <201606260947.7y4PB5Dc%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="tThc/1wpZn/ma/RB"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--tThc/1wpZn/ma/RB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

FYI, the error/warning still remains.

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   da2f6aba4a21f8da3331e5251a117c52764da579
commit: 5d2acfc7b974bbd3858b4dd3f2cdc6362dd8843a kconfig: make allnoconfig disable options behind EMBEDDED and EXPERT
date:   2 years, 3 months ago
config: m32r-allnoconfig (attached as .config)
compiler: m32r-linux-gcc (GCC) 4.9.0
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 5d2acfc7b974bbd3858b4dd3f2cdc6362dd8843a
        # save the attached .config to linux build tree
        make.cross ARCH=m32r 

All errors (new ones prefixed by >>):

   arch/m32r/kernel/built-in.o: In function `default_eit_handler':
>> (.text+0x3f8): undefined reference to `printk'
   arch/m32r/kernel/built-in.o: In function `default_eit_handler':
   (.text+0x3f8): relocation truncated to fit: R_M32R_26_PCREL_RELA against undefined symbol `printk'

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--tThc/1wpZn/ma/RB
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
JD3YJerFtv8BdtxskZQsAAA=

--tThc/1wpZn/ma/RB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
