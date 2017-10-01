Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 01AD76B0069
	for <linux-mm@kvack.org>; Sat, 30 Sep 2017 20:38:51 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p5so5864838pgn.7
        for <linux-mm@kvack.org>; Sat, 30 Sep 2017 17:38:50 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id x18si959293pge.118.2017.09.30.17.38.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Sep 2017 17:38:49 -0700 (PDT)
Date: Sun, 1 Oct 2017 08:38:21 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCHv2] mm: Account pud page tables
Message-ID: <201710010821.WCKzxMq3%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="UugvWAfsgieZRqgk"
Content-Disposition: inline
In-Reply-To: <20170925073913.22628-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>


--UugvWAfsgieZRqgk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Kirill,

[auto build test ERROR on linus/master]
[also build test ERROR on v4.14-rc2]
[cannot apply to next-20170929]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Kirill-A-Shutemov/mm-Account-pud-page-tables/20170926-031536
config: microblaze-nommu_defconfig (attached as .config)
compiler: microblaze-linux-gcc (GCC) 6.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=microblaze 

All errors (new ones prefixed by >>):

   In file included from arch/microblaze/include/uapi/asm/byteorder.h:7:0,
                    from include/asm-generic/bitops/le.h:5,
                    from include/asm-generic/bitops.h:34,
                    from ./arch/microblaze/include/generated/asm/bitops.h:1,
                    from include/linux/bitops.h:37,
                    from include/linux/kernel.h:10,
                    from include/asm-generic/bug.h:15,
                    from ./arch/microblaze/include/generated/asm/bug.h:1,
                    from include/linux/bug.h:4,
                    from include/linux/page-flags.h:9,
                    from kernel/bounds.c:9:
   include/linux/byteorder/big_endian.h:7:2: warning: #warning inconsistent configuration, needs CONFIG_CPU_BIG_ENDIAN [-Wcpp]
    #warning inconsistent configuration, needs CONFIG_CPU_BIG_ENDIAN
     ^~~~~~~
   In file included from arch/microblaze/include/uapi/asm/byteorder.h:7:0,
                    from include/asm-generic/bitops/le.h:5,
                    from include/asm-generic/bitops.h:34,
                    from ./arch/microblaze/include/generated/asm/bitops.h:1,
                    from include/linux/bitops.h:37,
                    from include/linux/kernel.h:10,
                    from include/linux/list.h:8,
                    from include/linux/rculist.h:9,
                    from include/linux/pid.h:4,
                    from include/linux/sched.h:13,
                    from arch/microblaze/kernel/asm-offsets.c:13:
   include/linux/byteorder/big_endian.h:7:2: warning: #warning inconsistent configuration, needs CONFIG_CPU_BIG_ENDIAN [-Wcpp]
    #warning inconsistent configuration, needs CONFIG_CPU_BIG_ENDIAN
     ^~~~~~~
   In file included from arch/microblaze/include/asm/io.h:17:0,
                    from include/linux/io.h:25,
                    from include/linux/irq.h:24,
                    from include/asm-generic/hardirq.h:12,
                    from ./arch/microblaze/include/generated/asm/hardirq.h:1,
                    from include/linux/hardirq.h:8,
                    from include/linux/interrupt.h:12,
                    from include/linux/kernel_stat.h:8,
                    from arch/microblaze/kernel/asm-offsets.c:14:
   include/linux/mm.h: In function 'mm_nr_puds_init':
>> include/linux/mm.h:1622:21: error: 'struct mm_struct' has no member named 'nr_puds'; did you mean 'nr_ptes'?
     atomic_long_set(&mm->nr_puds, 0);
                        ^~
   include/linux/mm.h: In function 'mm_nr_puds':
>> include/linux/mm.h:1627:29: error: 'const struct mm_struct' has no member named 'nr_puds'; did you mean 'nr_ptes'?
     return atomic_long_read(&mm->nr_puds);
                                ^~
   include/linux/mm.h: In function 'mm_inc_nr_puds':
   include/linux/mm.h:1632:21: error: 'struct mm_struct' has no member named 'nr_puds'; did you mean 'nr_ptes'?
     atomic_long_inc(&mm->nr_puds);
                        ^~
   include/linux/mm.h: In function 'mm_dec_nr_puds':
   include/linux/mm.h:1637:21: error: 'struct mm_struct' has no member named 'nr_puds'; did you mean 'nr_ptes'?
     atomic_long_dec(&mm->nr_puds);
                        ^~
   make[2]: *** [arch/microblaze/kernel/asm-offsets.s] Error 1
   make[2]: Target '__build' not remade because of errors.
   make[1]: *** [prepare0] Error 2
   make[1]: Target 'prepare' not remade because of errors.
   make: *** [sub-make] Error 2

vim +1622 include/linux/mm.h

  1619	
  1620	static inline void mm_nr_puds_init(struct mm_struct *mm)
  1621	{
> 1622		atomic_long_set(&mm->nr_puds, 0);
  1623	}
  1624	
  1625	static inline unsigned long mm_nr_puds(const struct mm_struct *mm)
  1626	{
> 1627		return atomic_long_read(&mm->nr_puds);
  1628	}
  1629	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--UugvWAfsgieZRqgk
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
F4pJn3+RQUnjeff6M05/TJT+AV+rM+otzQAA

--UugvWAfsgieZRqgk--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
