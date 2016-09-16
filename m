Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6DB5D6B0069
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 17:41:10 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 21so123647131pfy.3
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 14:41:10 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id bi6si12237401pad.256.2016.09.16.14.41.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Sep 2016 14:41:09 -0700 (PDT)
Date: Sat, 17 Sep 2016 05:40:19 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: mm/slub.o:undefined reference to `_GLOBAL_OFFSET_TABLE_'
Message-ID: <201609170517.uQDe12br%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="x+6KMIRAuhnl3hBn"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Alexander Duyck <alexander.h.duyck@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   024c7e3756d8a42fc41fe8a9488488b9b09d1dcc
commit: d0ecd894e3d5f768a84403b34019c4a7daa05882 slub: optimize bulk slowpath free by detached freelist
date:   10 months ago
config: microblaze-allnoconfig (attached as .config)
compiler: microblaze-linux-gcc (GCC) 6.2.0
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout d0ecd894e3d5f768a84403b34019c4a7daa05882
        # save the attached .config to linux build tree
        make.cross ARCH=microblaze 

All errors (new ones prefixed by >>):

   mm/built-in.o: In function `__slab_free.isra.14':
>> mm/slub.o:(.text+0x28d1c): undefined reference to `_GLOBAL_OFFSET_TABLE_'
   scripts/link-vmlinux.sh: line 52: 18545 Segmentation fault      ${LD} ${LDFLAGS} ${LDFLAGS_vmlinux} -o ${2} -T ${lds} ${KBUILD_VMLINUX_INIT} --start-group ${KBUILD_VMLINUX_MAIN} --end-group ${1}

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--x+6KMIRAuhnl3hBn
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
R2EnOKm6ZdMt7tNmFP5qivBO6P1/I2llTDc7AAA=

--x+6KMIRAuhnl3hBn--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
