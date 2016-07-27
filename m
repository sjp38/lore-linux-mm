Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC0C6B0253
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 16:57:22 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 63so15210951pfx.0
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 13:57:22 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id v5si8086928paz.176.2016.07.27.13.57.20
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 13:57:21 -0700 (PDT)
Date: Thu, 28 Jul 2016 04:56:34 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: undefined reference to `printk'
Message-ID: <201607280432.HiEyyQWS%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="k1lZvvs/B4yU6o8G"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

FYI, the error/warning still remains.

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   08fd8c17686c6b09fa410a26d516548dd80ff147
commit: 5d2acfc7b974bbd3858b4dd3f2cdc6362dd8843a kconfig: make allnoconfig disable options behind EMBEDDED and EXPERT
date:   2 years, 4 months ago
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

--k1lZvvs/B4yU6o8G
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
u0S92PY/EhfFEJ8sAAA=

--k1lZvvs/B4yU6o8G--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
