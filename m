Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1DA0E6B007E
	for <linux-mm@kvack.org>; Sun, 17 Apr 2016 09:58:27 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id dx6so157877750pad.0
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 06:58:27 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 76si15614575pfb.3.2016.04.17.06.58.26
        for <linux-mm@kvack.org>;
        Sun, 17 Apr 2016 06:58:26 -0700 (PDT)
Date: Sun, 17 Apr 2016 21:57:16 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: undefined reference to `early_panic'
Message-ID: <201604172112.qhLpXYRh%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="0OAP2g/MAC+5xKAE"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dan,

It's probably a bug fix that unveils the link errors.

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   b9f5dba225aede4518ab0a7374c2dc38c7c049ce
commit: 888cdbc2c9a76a0e450f533b1957cdbfe7d483d5 hugetlb: fix compile error on tile
date:   3 months ago
config: tile-allnoconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 888cdbc2c9a76a0e450f533b1957cdbfe7d483d5
        # save the attached .config to linux build tree
        make.cross ARCH=tile 

All errors (new ones prefixed by >>):

   arch/tile/built-in.o: In function `setup_arch':
>> (.init.text+0x15d8): undefined reference to `early_panic'
   arch/tile/built-in.o: In function `setup_arch':
   (.init.text+0x1610): undefined reference to `early_panic'
   arch/tile/built-in.o: In function `setup_arch':
   (.init.text+0x1800): undefined reference to `early_panic'
   arch/tile/built-in.o: In function `setup_arch':
   (.init.text+0x1828): undefined reference to `early_panic'
   arch/tile/built-in.o: In function `setup_arch':
   (.init.text+0x1bd8): undefined reference to `early_panic'
   arch/tile/built-in.o:(.init.text+0x1c18): more undefined references to `early_panic' follow

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--0OAP2g/MAC+5xKAE
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
mePiBtvGmaT9NT4pVCyTj4PGoP8H/zSV5SI2AAA=

--0OAP2g/MAC+5xKAE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
