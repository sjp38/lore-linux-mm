Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1FDA86B0005
	for <linux-mm@kvack.org>; Sun,  5 Jun 2016 00:45:19 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g64so176664191pfb.2
        for <linux-mm@kvack.org>; Sat, 04 Jun 2016 21:45:19 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id e128si19026278pfe.226.2016.06.04.21.45.18
        for <linux-mm@kvack.org>;
        Sat, 04 Jun 2016 21:45:18 -0700 (PDT)
Date: Sun, 5 Jun 2016 12:33:29 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: undefined reference to `early_panic'
Message-ID: <201606051227.HWQZ0zJJ%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="AhhlLboLdkugWU4S"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--AhhlLboLdkugWU4S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

It's probably a bug fix that unveils the link errors.

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   049ec1b5a76d34a6980cccdb7c0baeb4eed7a993
commit: 888cdbc2c9a76a0e450f533b1957cdbfe7d483d5 hugetlb: fix compile error on tile
date:   5 months ago
config: tile-allnoconfig (attached as .config)
compiler: tilegx-linux-gcc (GCC) 4.6.2
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

--AhhlLboLdkugWU4S
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--AhhlLboLdkugWU4S--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
