Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9CFEF6B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 23:53:51 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id r8-v6so3604273pgq.2
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 20:53:51 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id z30-v6si54456427pfg.266.2018.06.07.20.53.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 20:53:49 -0700 (PDT)
Date: Fri, 8 Jun 2018 11:53:36 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 4/9] x86/mm: Change _PAGE_DIRTY to _PAGE_DIRTY_HW
Message-ID: <201806081114.7XHL4Gop%fengguang.wu@intel.com>
References: <20180607143705.3531-5-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="XsQoSWH+UP9D9v3l"
Content-Disposition: inline
In-Reply-To: <20180607143705.3531-5-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>


--XsQoSWH+UP9D9v3l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Yu-cheng,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on asm-generic/master]
[also build test ERROR on v4.17 next-20180607]
[cannot apply to tip/x86/core mmotm/master]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Yu-cheng-Yu/Control-Flow-Enforcement-Part-2/20180608-111152
base:   https://git.kernel.org/pub/scm/linux/kernel/git/arnd/asm-generic.git master
config: i386-tinyconfig (attached as .config)
compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

Note: the linux-review/Yu-cheng-Yu/Control-Flow-Enforcement-Part-2/20180608-111152 HEAD 71d9d315a5e241d9b500540a452d0bec292e1dbb builds fine.
      It only hurts bisectibility.

All errors (new ones prefixed by >>):

   In file included from include/linux/memremap.h:8:0,
                    from include/linux/mm.h:27,
                    from include/linux/memcontrol.h:29,
                    from include/linux/swap.h:9,
                    from include/linux/suspend.h:5,
                    from arch/x86/kernel/asm-offsets.c:13:
   arch/x86/include/asm/pgtable.h: In function 'pte_dirty':
>> arch/x86/include/asm/pgtable.h:121:26: error: '_PAGE_DIRTY' undeclared (first use in this function); did you mean '_PAGE_DIRTY_HW'?
     return pte_flags(pte) & _PAGE_DIRTY;
                             ^~~~~~~~~~~
                             _PAGE_DIRTY_HW
   arch/x86/include/asm/pgtable.h:121:26: note: each undeclared identifier is reported only once for each function it appears in
   arch/x86/include/asm/pgtable.h: In function 'pmd_dirty':
   arch/x86/include/asm/pgtable.h:145:26: error: '_PAGE_DIRTY' undeclared (first use in this function); did you mean '_PAGE_DIRTY_HW'?
     return pmd_flags(pmd) & _PAGE_DIRTY;
                             ^~~~~~~~~~~
                             _PAGE_DIRTY_HW
   arch/x86/include/asm/pgtable.h: In function 'pud_dirty':
   arch/x86/include/asm/pgtable.h:155:26: error: '_PAGE_DIRTY' undeclared (first use in this function); did you mean '_PAGE_DIRTY_HW'?
     return pud_flags(pud) & _PAGE_DIRTY;
                             ^~~~~~~~~~~
                             _PAGE_DIRTY_HW
   arch/x86/include/asm/pgtable.h: In function 'pte_mkclean':
   arch/x86/include/asm/pgtable.h:286:30: error: '_PAGE_DIRTY' undeclared (first use in this function); did you mean '_PAGE_DIRTY_HW'?
     return pte_clear_flags(pte, _PAGE_DIRTY);
                                 ^~~~~~~~~~~
                                 _PAGE_DIRTY_HW
   arch/x86/include/asm/pgtable.h: In function 'pmd_mkclean':
   arch/x86/include/asm/pgtable.h:370:30: error: '_PAGE_DIRTY' undeclared (first use in this function); did you mean '_PAGE_DIRTY_HW'?
     return pmd_clear_flags(pmd, _PAGE_DIRTY);
                                 ^~~~~~~~~~~
                                 _PAGE_DIRTY_HW
   arch/x86/include/asm/pgtable.h: In function 'pud_mkclean':
   arch/x86/include/asm/pgtable.h:429:30: error: '_PAGE_DIRTY' undeclared (first use in this function); did you mean '_PAGE_DIRTY_HW'?
     return pud_clear_flags(pud, _PAGE_DIRTY);
                                 ^~~~~~~~~~~
                                 _PAGE_DIRTY_HW
   make[2]: *** [arch/x86/kernel/asm-offsets.s] Error 1
   make[2]: Target '__build' not remade because of errors.
   make[1]: *** [prepare0] Error 2
   make[1]: Target 'prepare' not remade because of errors.
   make: *** [sub-make] Error 2

vim +121 arch/x86/include/asm/pgtable.h

54321d947 arch/x86/include/asm/pgtable.h Jeremy Fitzhardinge 2009-02-11  114  
8405b122a include/asm-x86/pgtable.h      Jeremy Fitzhardinge 2008-01-30  115  /*
4614139c6 include/asm-x86/pgtable.h      Jeremy Fitzhardinge 2008-01-30  116   * The following only work if pte_present() is true.
4614139c6 include/asm-x86/pgtable.h      Jeremy Fitzhardinge 2008-01-30  117   * Undefined behaviour if not..
4614139c6 include/asm-x86/pgtable.h      Jeremy Fitzhardinge 2008-01-30  118   */
3cbaeafeb include/asm-x86/pgtable.h      Joe Perches         2008-03-23  119  static inline int pte_dirty(pte_t pte)
3cbaeafeb include/asm-x86/pgtable.h      Joe Perches         2008-03-23  120  {
a15af1c9e include/asm-x86/pgtable.h      Jeremy Fitzhardinge 2008-05-26 @121  	return pte_flags(pte) & _PAGE_DIRTY;
3cbaeafeb include/asm-x86/pgtable.h      Joe Perches         2008-03-23  122  }
3cbaeafeb include/asm-x86/pgtable.h      Joe Perches         2008-03-23  123  

:::::: The code at line 121 was first introduced by commit
:::::: a15af1c9ea2750a9ff01e51615c45950bad8221b x86/paravirt: add pte_flags to just get pte flags

:::::: TO: Jeremy Fitzhardinge <jeremy@goop.org>
:::::: CC: Thomas Gleixner <tglx@linutronix.de>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--XsQoSWH+UP9D9v3l
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--XsQoSWH+UP9D9v3l--
