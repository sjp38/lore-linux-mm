Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0251C6B0038
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 17:02:43 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 79so281835064pgf.2
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 14:02:42 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id u10si3101984plu.58.2017.03.22.14.02.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Mar 2017 14:02:41 -0700 (PDT)
Date: Thu, 23 Mar 2017 05:02:07 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master 4332/4339] fork.c:undefined reference to
 `__arch_atomic_add_unless'
Message-ID: <201703230503.EVDd8pHF%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="/04w6evG8XlLl3ft"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, Andi Kleen <ak@linux.intel.com>


--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Andrew,

It's probably a bug fix that unveils the link errors.

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   f921b263d9602fb7873710c2df70671f2ffcf658
commit: 0585aae2b6b48d94a903a1e4d51751204a46ea61 [4332/4339] x86-atomic-move-__atomic_add_unless-out-of-line-fix
config: um-allnoconfig (attached as .config)
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        git checkout 0585aae2b6b48d94a903a1e4d51751204a46ea61
        # save the attached .config to linux build tree
        make ARCH=um 

All errors (new ones prefixed by >>):

   kernel/built-in.o: In function `copy_process.isra.10.part.11':
>> fork.c:(.text+0xf59): undefined reference to `__arch_atomic_add_unless'
   kernel/built-in.o: In function `get_mm_exe_file':
>> (.text+0x1818): undefined reference to `__arch_atomic_add_unless'
   kernel/built-in.o: In function `get_task_exe_file':
   (.text+0x1878): undefined reference to `__arch_atomic_add_unless'
   kernel/built-in.o: In function `get_task_cred':
   (.text+0x18383): undefined reference to `__arch_atomic_add_unless'
   kernel/built-in.o: In function `prepare_kernel_cred':
   (.text+0x186cd): undefined reference to `__arch_atomic_add_unless'
   kernel/built-in.o:(.text+0x2137d): more undefined references to `__arch_atomic_add_unless' follow
   collect2: error: ld returned 1 exit status

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--/04w6evG8XlLl3ft
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--/04w6evG8XlLl3ft--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
