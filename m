Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AD1026B0069
	for <linux-mm@kvack.org>; Sat,  1 Oct 2016 19:18:49 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 7so152064758pfa.2
        for <linux-mm@kvack.org>; Sat, 01 Oct 2016 16:18:49 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id t10si6020411pfj.287.2016.10.01.16.18.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 01 Oct 2016 16:18:48 -0700 (PDT)
Date: Sun, 2 Oct 2016 07:18:43 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: cris-linux-objcopy: error: the input file
 'arch/cris/boot/rescue/rescue.o' has no sections
Message-ID: <201610020736.QBrCDzTe%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="ZGiS0Q5IWpPtfppv"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Joe,

First bad commit (maybe != root cause):

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   f51fdffad5b7709d0ade40736b58a2da2707fa15
commit: cb984d101b30eb7478d32df56a0023e4603cba7f compiler-gcc: integrate the various compiler-gcc[345].h files
date:   1 year, 3 months ago
config: cris-alldefconfig (attached as .config)
compiler: cris-linux-gcc (GCC) 6.2.0
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout cb984d101b30eb7478d32df56a0023e4603cba7f
        # save the attached .config to linux build tree
        make.cross ARCH=cris 

All errors (new ones prefixed by >>):

>> cris-linux-objcopy: error: the input file 'arch/cris/boot/rescue/rescue.o' has no sections

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--ZGiS0Q5IWpPtfppv
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--ZGiS0Q5IWpPtfppv--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
