Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BBC106B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 21:12:15 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u202so27314921pgb.9
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 18:12:15 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id c7si479905pgn.352.2017.03.29.18.12.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 18:12:14 -0700 (PDT)
Date: Thu, 30 Mar 2017 09:11:56 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master 5963/5971] futex.c:undefined reference to
 `__arch_atomic_add_unless'
Message-ID: <201703300952.VVHcc8hB%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="EeQfGwPcQSOJBaQU"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, Andi Kleen <ak@linux.intel.com>


--EeQfGwPcQSOJBaQU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Andrew,

It's probably a bug fix that unveils the link errors.

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   8f8ab14f4414e1be0e7c23036017e3e3130ba7cd
commit: 2ef5da008877ad2222e9a8964d39cf50fd2236d7 [5963/5971] x86-atomic-move-__atomic_add_unless-out-of-line-fix
config: um-alldefconfig (attached as .config)
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        git checkout 2ef5da008877ad2222e9a8964d39cf50fd2236d7
        # save the attached .config to linux build tree
        make ARCH=um 

All errors (new ones prefixed by >>):

   kernel/built-in.o: In function `get_task_cred':
   (.text+0x23d34): undefined reference to `__arch_atomic_add_unless'
   kernel/built-in.o: In function `atomic_dec_and_mutex_lock':
   (.text+0x2f166): undefined reference to `__arch_atomic_add_unless'
   kernel/built-in.o: In function `get_pi_state':
>> futex.c:(.text+0x4b1c1): undefined reference to `__arch_atomic_add_unless'
   kernel/built-in.o: In function `get_futex_key':
   futex.c:(.text+0x4ba2a): undefined reference to `__arch_atomic_add_unless'
   mm/built-in.o: In function `oom_reaper':
>> oom_kill.c:(.text+0x4b36): undefined reference to `__arch_atomic_add_unless'
   mm/built-in.o:(.text+0x10e01): more undefined references to `__arch_atomic_add_unless' follow
   collect2: error: ld returned 1 exit status

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--EeQfGwPcQSOJBaQU
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
AM+LwW/5OQAA

--EeQfGwPcQSOJBaQU--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
