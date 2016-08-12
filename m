Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2A7706B0253
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 21:21:13 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ez1so19183045pab.1
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 18:21:13 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id sz2si5918723pac.129.2016.08.11.18.21.12
        for <linux-mm@kvack.org>;
        Thu, 11 Aug 2016 18:21:12 -0700 (PDT)
Date: Fri, 12 Aug 2016 09:19:52 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 70/106] arch/x86/kernel/process.c:511:9: error:
 implicit declaration of function 'randomize_page'
Message-ID: <201608120949.AtRXkB4G%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="a8Wt8u1KmwUX3Y2C"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Cooper <jason@lakedaemon.net>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--a8Wt8u1KmwUX3Y2C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   304bec1b1d331282b76d92a1487902ce1f158337
commit: 216e0dbb5aab2e588b1f9de3b434015aa1c412f7 [70/106] x86: use simpler API for random address requests
config: i386-tinyconfig (attached as .config)
compiler: gcc-6 (Debian 6.1.1-9) 6.1.1 20160705
reproduce:
        git checkout 216e0dbb5aab2e588b1f9de3b434015aa1c412f7
        # save the attached .config to linux build tree
        make ARCH=i386 

Note: the mmotm/master HEAD 304bec1b1d331282b76d92a1487902ce1f158337 builds fine.
      It only hurts bisectibility.

All errors (new ones prefixed by >>):

   arch/x86/kernel/process.c: In function 'arch_randomize_brk':
>> arch/x86/kernel/process.c:511:9: error: implicit declaration of function 'randomize_page' [-Werror=implicit-function-declaration]
     return randomize_page(mm->brk, 0x02000000);
            ^~~~~~~~~~~~~~
   cc1: some warnings being treated as errors

vim +/randomize_page +511 arch/x86/kernel/process.c

   505			sp -= get_random_int() % 8192;
   506		return sp & ~0xf;
   507	}
   508	
   509	unsigned long arch_randomize_brk(struct mm_struct *mm)
   510	{
 > 511		return randomize_page(mm->brk, 0x02000000);
   512	}
   513	
   514	/*

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--a8Wt8u1KmwUX3Y2C
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
AA==

--a8Wt8u1KmwUX3Y2C--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
