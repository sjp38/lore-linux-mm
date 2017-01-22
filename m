Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 101776B0253
	for <linux-mm@kvack.org>; Sat, 21 Jan 2017 22:48:03 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 194so153786256pgd.7
        for <linux-mm@kvack.org>; Sat, 21 Jan 2017 19:48:03 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id y73si11494065pfb.71.2017.01.21.19.48.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Jan 2017 19:48:02 -0800 (PST)
Date: Sun, 22 Jan 2017 11:47:34 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: core.c:undefined reference to `fpu_save'
Message-ID: <201701221129.FocKuMxi%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="GvXjxJ+pjyke8COw"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>


--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Andrew,

It's probably a bug fix that unveils the link errors.

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   4c9eff7af69c61749b9eb09141f18f35edbf2210
commit: c60f169202c7643991a8b4bfeea60e06843d5b5a arch/mn10300/kernel/fpu-nofpu.c: needs asm/elf.h
date:   10 months ago
config: mn10300-allnoconfig (attached as .config)
compiler: am33_2.0-linux-gcc (GCC) 6.2.0
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout c60f169202c7643991a8b4bfeea60e06843d5b5a
        # save the attached .config to linux build tree
        make.cross ARCH=mn10300 

All errors (new ones prefixed by >>):

   kernel/built-in.o: In function `.L410':
>> core.c:(.sched.text+0x28a): undefined reference to `fpu_save'

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--GvXjxJ+pjyke8COw
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--GvXjxJ+pjyke8COw--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
