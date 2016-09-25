Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2F5C428024B
	for <linux-mm@kvack.org>; Sat, 24 Sep 2016 23:41:20 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c84so308021541pfj.2
        for <linux-mm@kvack.org>; Sat, 24 Sep 2016 20:41:20 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 190si16445853pfg.255.2016.09.24.20.41.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 24 Sep 2016 20:41:19 -0700 (PDT)
Date: Sun, 25 Sep 2016 11:40:42 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: undefined reference to `printk'
Message-ID: <201609251139.vxagmOPP%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="HlL+5n6rz5pIUxbD"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Joe,

It's probably a bug fix that unveils the link errors.

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   9c0e28a7be656d737fb18998e2dcb0b8ce595643
commit: cb984d101b30eb7478d32df56a0023e4603cba7f compiler-gcc: integrate the various compiler-gcc[345].h files
date:   1 year, 3 months ago
config: m32r-allnoconfig (attached as .config)
compiler: m32r-linux-gcc (GCC) 6.2.0
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout cb984d101b30eb7478d32df56a0023e4603cba7f
        # save the attached .config to linux build tree
        make.cross ARCH=m32r 

All errors (new ones prefixed by >>):

   arch/m32r/kernel/built-in.o: In function `default_eit_handler':
>> (.text+0x3fc): undefined reference to `printk'
   arch/m32r/kernel/built-in.o: In function `default_eit_handler':
   (.text+0x3fc): relocation truncated to fit: R_M32R_26_PCREL_RELA against undefined symbol `printk'

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--HlL+5n6rz5pIUxbD
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
GwSO29HD2gpf7hDei2//A0/NZ13/LwAA

--HlL+5n6rz5pIUxbD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
