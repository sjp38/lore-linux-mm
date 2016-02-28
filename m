Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 803236B0009
	for <linux-mm@kvack.org>; Sun, 28 Feb 2016 18:33:39 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id bj10so11606259pad.2
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 15:33:39 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id rd7si22507591pab.90.2016.02.28.15.33.38
        for <linux-mm@kvack.org>;
        Sun, 28 Feb 2016 15:33:38 -0800 (PST)
Date: Mon, 29 Feb 2016 07:33:04 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: include/linux/bug.h:93:12: error: dereferencing pointer to
 incomplete type
Message-ID: <201602290757.VADI7RS5%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="vkogqOf2sHV7VnPd"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--vkogqOf2sHV7VnPd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Josh,

FYI, the error/warning still remains.

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   fc77dbd34c5c99bce46d40a2491937c3bcbd10af
commit: 5d2acfc7b974bbd3858b4dd3f2cdc6362dd8843a kconfig: make allnoconfig disable options behind EMBEDDED and EXPERT
date:   1 year, 11 months ago
config: mn10300-allnoconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 5d2acfc7b974bbd3858b4dd3f2cdc6362dd8843a
        # save the attached .config to linux build tree
        make.cross ARCH=mn10300 

All errors (new ones prefixed by >>):

   In file included from include/linux/page-flags.h:9:0,
                    from kernel/bounds.c:9:
   include/linux/bug.h:91:47: warning: 'struct bug_entry' declared inside parameter list
    static inline int is_warning_bug(const struct bug_entry *bug)
                                                  ^
   include/linux/bug.h:91:47: warning: its scope is only this definition or declaration, which is probably not what you want
   include/linux/bug.h: In function 'is_warning_bug':
>> include/linux/bug.h:93:12: error: dereferencing pointer to incomplete type
     return bug->flags & BUGFLAG_WARNING;
               ^
   make[2]: *** [kernel/bounds.s] Error 1
   make[2]: Target '__build' not remade because of errors.
   make[1]: *** [prepare0] Error 2
   make[1]: Target 'prepare' not remade because of errors.
   make: *** [sub-make] Error 2

vim +93 include/linux/bug.h

35edd910 Paul Gortmaker      2011-11-16  85  
35edd910 Paul Gortmaker      2011-11-16  86  #endif	/* __CHECKER__ */
35edd910 Paul Gortmaker      2011-11-16  87  
7664c5a1 Jeremy Fitzhardinge 2006-12-08  88  #ifdef CONFIG_GENERIC_BUG
7664c5a1 Jeremy Fitzhardinge 2006-12-08  89  #include <asm-generic/bug.h>
7664c5a1 Jeremy Fitzhardinge 2006-12-08  90  
7664c5a1 Jeremy Fitzhardinge 2006-12-08 @91  static inline int is_warning_bug(const struct bug_entry *bug)
7664c5a1 Jeremy Fitzhardinge 2006-12-08  92  {
7664c5a1 Jeremy Fitzhardinge 2006-12-08 @93  	return bug->flags & BUGFLAG_WARNING;
7664c5a1 Jeremy Fitzhardinge 2006-12-08  94  }
7664c5a1 Jeremy Fitzhardinge 2006-12-08  95  
7664c5a1 Jeremy Fitzhardinge 2006-12-08  96  const struct bug_entry *find_bug(unsigned long bugaddr);

:::::: The code at line 93 was first introduced by commit
:::::: 7664c5a1da4711bb6383117f51b94c8dc8f3f1cd [PATCH] Generic BUG implementation

:::::: TO: Jeremy Fitzhardinge <jeremy@goop.org>
:::::: CC: Linus Torvalds <torvalds@woody.osdl.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--vkogqOf2sHV7VnPd
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
yv8D9S29XVszAAA=

--vkogqOf2sHV7VnPd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
