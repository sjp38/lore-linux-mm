Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 167B06B025F
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 13:40:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h186so182531326pfg.2
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 10:40:27 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id 84si33047277pfk.97.2016.08.16.10.40.25
        for <linux-mm@kvack.org>;
        Tue, 16 Aug 2016 10:40:25 -0700 (PDT)
Date: Wed, 17 Aug 2016 01:39:16 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] mm: kmemleak: Avoid using __va() on addresses that don't
 have a lowmem mapping
Message-ID: <201608170148.fXJVygxN%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="oyUTqETQ0mS9luUI"
Content-Disposition: inline
In-Reply-To: <1471360856-16916-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vignesh R <vigneshr@ti.com>


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Catalin,

[auto build test ERROR on mmotm/master]
[also build test ERROR on v4.8-rc2 next-20160816]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Catalin-Marinas/mm-kmemleak-Avoid-using-__va-on-addresses-that-don-t-have-a-lowmem-mapping/20160816-232733
base:   git://git.cmpxchg.org/linux-mmotm.git master
config: frv-defconfig (attached as .config)
compiler: frv-linux-gcc (GCC) 4.9.0
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=frv 

All error/warnings (new ones prefixed by >>):

   In file included from include/linux/kmemleak.h:24:0,
                    from include/linux/slab.h:117,
                    from arch/frv/include/asm/pgtable.h:25,
                    from mm/init-mm.c:9:
   include/linux/mm.h: In function 'maybe_mkwrite':
   include/linux/mm.h:624:3: error: implicit declaration of function 'pte_mkwrite' [-Werror=implicit-function-declaration]
      pte = pte_mkwrite(pte);
      ^
   include/linux/mm.h:624:7: error: incompatible types when assigning to type 'pte_t' from type 'int'
      pte = pte_mkwrite(pte);
          ^
   In file included from include/linux/kmemleak.h:24:0,
                    from include/linux/slab.h:117,
                    from arch/frv/include/asm/pgtable.h:25,
                    from mm/init-mm.c:9:
   include/linux/mm.h: In function 'mm_nr_pmds_init':
>> include/linux/mm.h:1576:21: error: 'struct mm_struct' has no member named 'nr_pmds'
     atomic_long_set(&mm->nr_pmds, 0);
                        ^
   include/linux/mm.h: In function 'mm_nr_pmds':
   include/linux/mm.h:1581:29: error: 'struct mm_struct' has no member named 'nr_pmds'
     return atomic_long_read(&mm->nr_pmds);
                                ^
   include/linux/mm.h: In function 'mm_inc_nr_pmds':
   include/linux/mm.h:1586:21: error: 'struct mm_struct' has no member named 'nr_pmds'
     atomic_long_inc(&mm->nr_pmds);
                        ^
   include/linux/mm.h: In function 'mm_dec_nr_pmds':
   include/linux/mm.h:1591:21: error: 'struct mm_struct' has no member named 'nr_pmds'
     atomic_long_dec(&mm->nr_pmds);
                        ^
   include/linux/mm.h: In function 'pud_alloc':
>> include/linux/mm.h:1605:2: error: implicit declaration of function 'pgd_none' [-Werror=implicit-function-declaration]
     return (unlikely(pgd_none(*pgd)) && __pud_alloc(mm, pgd, address))?
     ^
>> include/linux/mm.h:1606:3: error: implicit declaration of function 'pud_offset' [-Werror=implicit-function-declaration]
      NULL: pud_offset(pgd, address);
      ^
>> include/linux/mm.h:1606:7: warning: pointer/integer type mismatch in conditional expression
      NULL: pud_offset(pgd, address);
          ^
   include/linux/mm.h: In function 'pmd_alloc':
>> include/linux/mm.h:1611:2: error: implicit declaration of function 'pud_none' [-Werror=implicit-function-declaration]
     return (unlikely(pud_none(*pud)) && __pmd_alloc(mm, pud, address))?
     ^
>> include/linux/mm.h:1612:3: error: implicit declaration of function 'pmd_offset' [-Werror=implicit-function-declaration]
      NULL: pmd_offset(pud, address);
      ^
   include/linux/mm.h:1612:7: warning: pointer/integer type mismatch in conditional expression
      NULL: pmd_offset(pud, address);
          ^
   include/linux/mm.h: In function 'pgtable_init':
   include/linux/mm.h:1690:2: error: implicit declaration of function 'pgtable_cache_init' [-Werror=implicit-function-declaration]
     pgtable_cache_init();
     ^
   In file included from mm/init-mm.c:9:0:
   arch/frv/include/asm/pgtable.h: At top level:
>> arch/frv/include/asm/pgtable.h:196:19: error: static declaration of 'pgd_none' follows non-static declaration
    static inline int pgd_none(pgd_t pgd)  { return 0; }
                      ^
   In file included from include/uapi/linux/stddef.h:1:0,
                    from include/linux/stddef.h:4,
                    from include/uapi/linux/posix_types.h:4,
                    from include/uapi/linux/types.h:13,
                    from include/linux/types.h:5,
                    from include/linux/mm_types.h:5,
                    from mm/init-mm.c:1:
   include/linux/mm.h:1605:19: note: previous implicit declaration of 'pgd_none' was here
     return (unlikely(pgd_none(*pgd)) && __pud_alloc(mm, pgd, address))?
                      ^
   include/linux/compiler.h:168:42: note: in definition of macro 'unlikely'
    # define unlikely(x) __builtin_expect(!!(x), 0)
                                             ^
   In file included from mm/init-mm.c:9:0:
>> arch/frv/include/asm/pgtable.h:212:22: error: conflicting types for 'pud_offset'
    static inline pud_t *pud_offset(pgd_t *pgd, unsigned long address)
                         ^
   In file included from include/linux/kmemleak.h:24:0,
                    from include/linux/slab.h:117,
                    from arch/frv/include/asm/pgtable.h:25,
                    from mm/init-mm.c:9:
   include/linux/mm.h:1606:9: note: previous implicit declaration of 'pud_offset' was here
      NULL: pud_offset(pgd, address);
            ^
   In file included from mm/init-mm.c:9:0:
>> arch/frv/include/asm/pgtable.h:233:19: error: static declaration of 'pud_none' follows non-static declaration
    static inline int pud_none(pud_t pud)  { return 0; }
                      ^
   In file included from include/uapi/linux/stddef.h:1:0,
                    from include/linux/stddef.h:4,
                    from include/uapi/linux/posix_types.h:4,
                    from include/uapi/linux/types.h:13,
                    from include/linux/types.h:5,
                    from include/linux/mm_types.h:5,
                    from mm/init-mm.c:1:
   include/linux/mm.h:1611:19: note: previous implicit declaration of 'pud_none' was here
     return (unlikely(pud_none(*pud)) && __pmd_alloc(mm, pud, address))?
                      ^
   include/linux/compiler.h:168:42: note: in definition of macro 'unlikely'
    # define unlikely(x) __builtin_expect(!!(x), 0)
                                             ^
   In file included from mm/init-mm.c:9:0:
>> arch/frv/include/asm/pgtable.h:262:22: error: conflicting types for 'pmd_offset'
    static inline pmd_t *pmd_offset(pud_t *dir, unsigned long address)
                         ^
   In file included from include/linux/kmemleak.h:24:0,
                    from include/linux/slab.h:117,
                    from arch/frv/include/asm/pgtable.h:25,
                    from mm/init-mm.c:9:
   include/linux/mm.h:1612:9: note: previous implicit declaration of 'pmd_offset' was here
      NULL: pmd_offset(pud, address);
            ^
   In file included from mm/init-mm.c:9:0:
>> arch/frv/include/asm/pgtable.h:385:21: error: conflicting types for 'pte_mkwrite'
    static inline pte_t pte_mkwrite(pte_t pte) { (pte).pte &= ~_PAGE_WP; return pte; }
                        ^
   In file included from include/linux/kmemleak.h:24:0,
                    from include/linux/slab.h:117,
                    from arch/frv/include/asm/pgtable.h:25,
                    from mm/init-mm.c:9:
   include/linux/mm.h:624:9: note: previous implicit declaration of 'pte_mkwrite' was here
      pte = pte_mkwrite(pte);
            ^
   In file included from mm/init-mm.c:9:0:
>> arch/frv/include/asm/pgtable.h:517:20: warning: conflicting types for 'pgtable_cache_init'
    extern void __init pgtable_cache_init(void);
                       ^
   In file included from include/linux/kmemleak.h:24:0,
                    from include/linux/slab.h:117,
                    from arch/frv/include/asm/pgtable.h:25,
                    from mm/init-mm.c:9:
   include/linux/mm.h:1690:2: note: previous implicit declaration of 'pgtable_cache_init' was here
     pgtable_cache_init();
     ^
   cc1: some warnings being treated as errors

vim +1576 include/linux/mm.h

dc6c9a35 Kirill A. Shutemov 2015-02-11  1570  
5f22df00 Nick Piggin        2007-05-06  1571  #else
1bb3630e Hugh Dickins       2005-10-29  1572  int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address);
dc6c9a35 Kirill A. Shutemov 2015-02-11  1573  
2d2f5119 Kirill A. Shutemov 2015-02-12  1574  static inline void mm_nr_pmds_init(struct mm_struct *mm)
2d2f5119 Kirill A. Shutemov 2015-02-12  1575  {
2d2f5119 Kirill A. Shutemov 2015-02-12 @1576  	atomic_long_set(&mm->nr_pmds, 0);
2d2f5119 Kirill A. Shutemov 2015-02-12  1577  }
2d2f5119 Kirill A. Shutemov 2015-02-12  1578  
dc6c9a35 Kirill A. Shutemov 2015-02-11  1579  static inline unsigned long mm_nr_pmds(struct mm_struct *mm)
dc6c9a35 Kirill A. Shutemov 2015-02-11  1580  {
dc6c9a35 Kirill A. Shutemov 2015-02-11  1581  	return atomic_long_read(&mm->nr_pmds);
dc6c9a35 Kirill A. Shutemov 2015-02-11  1582  }
dc6c9a35 Kirill A. Shutemov 2015-02-11  1583  
dc6c9a35 Kirill A. Shutemov 2015-02-11  1584  static inline void mm_inc_nr_pmds(struct mm_struct *mm)
dc6c9a35 Kirill A. Shutemov 2015-02-11  1585  {
dc6c9a35 Kirill A. Shutemov 2015-02-11 @1586  	atomic_long_inc(&mm->nr_pmds);
dc6c9a35 Kirill A. Shutemov 2015-02-11  1587  }
dc6c9a35 Kirill A. Shutemov 2015-02-11  1588  
dc6c9a35 Kirill A. Shutemov 2015-02-11  1589  static inline void mm_dec_nr_pmds(struct mm_struct *mm)
dc6c9a35 Kirill A. Shutemov 2015-02-11  1590  {
dc6c9a35 Kirill A. Shutemov 2015-02-11 @1591  	atomic_long_dec(&mm->nr_pmds);
dc6c9a35 Kirill A. Shutemov 2015-02-11  1592  }
5f22df00 Nick Piggin        2007-05-06  1593  #endif
5f22df00 Nick Piggin        2007-05-06  1594  
3ed3a4f0 Kirill A. Shutemov 2016-03-17  1595  int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address);
1bb3630e Hugh Dickins       2005-10-29  1596  int __pte_alloc_kernel(pmd_t *pmd, unsigned long address);
1bb3630e Hugh Dickins       2005-10-29  1597  
^1da177e Linus Torvalds     2005-04-16  1598  /*
^1da177e Linus Torvalds     2005-04-16  1599   * The following ifdef needed to get the 4level-fixup.h header to work.
^1da177e Linus Torvalds     2005-04-16  1600   * Remove it when 4level-fixup.h has been removed.
^1da177e Linus Torvalds     2005-04-16  1601   */
1bb3630e Hugh Dickins       2005-10-29  1602  #if defined(CONFIG_MMU) && !defined(__ARCH_HAS_4LEVEL_HACK)
^1da177e Linus Torvalds     2005-04-16  1603  static inline pud_t *pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
^1da177e Linus Torvalds     2005-04-16  1604  {
1bb3630e Hugh Dickins       2005-10-29 @1605  	return (unlikely(pgd_none(*pgd)) && __pud_alloc(mm, pgd, address))?
1bb3630e Hugh Dickins       2005-10-29 @1606  		NULL: pud_offset(pgd, address);
^1da177e Linus Torvalds     2005-04-16  1607  }
^1da177e Linus Torvalds     2005-04-16  1608  
^1da177e Linus Torvalds     2005-04-16  1609  static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
^1da177e Linus Torvalds     2005-04-16  1610  {
1bb3630e Hugh Dickins       2005-10-29 @1611  	return (unlikely(pud_none(*pud)) && __pmd_alloc(mm, pud, address))?
1bb3630e Hugh Dickins       2005-10-29 @1612  		NULL: pmd_offset(pud, address);
^1da177e Linus Torvalds     2005-04-16  1613  }
1bb3630e Hugh Dickins       2005-10-29  1614  #endif /* CONFIG_MMU && !__ARCH_HAS_4LEVEL_HACK */
1bb3630e Hugh Dickins       2005-10-29  1615  

:::::: The code at line 1576 was first introduced by commit
:::::: 2d2f5119b8bb057595e18f5b2f07aa097ea1b233 mm: do not use mm->nr_pmds on !MMU configurations

:::::: TO: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
:::::: CC: Linus Torvalds <torvalds@linux-foundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--oyUTqETQ0mS9luUI
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
O47I3udW789kkBAmujA6/wfj4TYWYX8AAA==

--oyUTqETQ0mS9luUI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
