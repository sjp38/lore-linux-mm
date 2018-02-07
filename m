Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 83A496B02BC
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 22:35:46 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id i11so1711801pgq.10
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 19:35:46 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id b3si358838pgc.496.2018.02.06.19.35.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Feb 2018 19:35:45 -0800 (PST)
Date: Wed, 7 Feb 2018 11:35:06 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 121/198] arch/h8300/include/asm/byteorder.h:5:0:
 warning: "__BIG_ENDIAN" redefined
Message-ID: <201802071102.MIeAReaO%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="/9DWx/yDrRhgMJTb"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--/9DWx/yDrRhgMJTb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   bf384e483e31f8e2fc27d5fdb5236b2e9d3fdc84
commit: 15105f5f068efaadc15936bc92da3f9d0a260ce2 [121/198] Kbuild: always define endianess in kconfig.h
config: h8300-h8300h-sim_defconfig (attached as .config)
compiler: h8300-linux-gcc (GCC) 7.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 15105f5f068efaadc15936bc92da3f9d0a260ce2
        # save the attached .config to linux build tree
        make.cross ARCH=h8300 

All warnings (new ones prefixed by >>):

   In file included from include/asm-generic/bitops/le.h:6:0,
                    from arch/h8300/include/asm/bitops.h:177,
                    from include/linux/bitops.h:38,
                    from include/linux/log2.h:16,
                    from include/asm-generic/getorder.h:8,
                    from include/asm-generic/page.h:99,
                    from arch/h8300/include/asm/page.h:5,
                    from arch/h8300/include/asm/string.h:8,
                    from include/linux/string.h:20,
                    from include/linux/uuid.h:20,
                    from include/linux/mod_devicetable.h:13,
                    from scripts/mod/devicetable-offsets.c:3:
>> arch/h8300/include/asm/byteorder.h:5:0: warning: "__BIG_ENDIAN" redefined
    #define __BIG_ENDIAN __ORDER_BIG_ENDIAN__
    
   In file included from <command-line>:0:0:
   include/linux/kconfig.h:8:0: note: this is the location of the previous definition
    #define __BIG_ENDIAN 4321
    
--
   In file included from include/asm-generic/bitops/le.h:6:0,
                    from arch/h8300/include/asm/bitops.h:177,
                    from include/linux/bitops.h:38,
                    from include/linux/kernel.h:11,
                    from include/linux/list.h:9,
                    from include/linux/wait.h:7,
                    from include/linux/wait_bit.h:8,
                    from include/linux/fs.h:6,
                    from include/linux/dax.h:5,
                    from mm/filemap.c:14:
>> arch/h8300/include/asm/byteorder.h:5:0: warning: "__BIG_ENDIAN" redefined
    #define __BIG_ENDIAN __ORDER_BIG_ENDIAN__
    
   In file included from <command-line>:0:0:
   include/linux/kconfig.h:8:0: note: this is the location of the previous definition
    #define __BIG_ENDIAN 4321
    
   mm/filemap.c: In function 'clear_bit_unlock_is_negative_byte':
   mm/filemap.c:1180:30: warning: passing argument 2 of 'test_bit' discards 'volatile' qualifier from pointer target type [-Wdiscarded-qualifiers]
     return test_bit(PG_waiters, mem);
                                 ^~~
   In file included from include/linux/bitops.h:38:0,
                    from include/linux/kernel.h:11,
                    from include/linux/list.h:9,
                    from include/linux/wait.h:7,
                    from include/linux/wait_bit.h:8,
                    from include/linux/fs.h:6,
                    from include/linux/dax.h:5,
                    from mm/filemap.c:14:
   arch/h8300/include/asm/bitops.h:69:19: note: expected 'const long unsigned int *' but argument is of type 'volatile void *'
    static inline int test_bit(int nr, const unsigned long *addr)
                      ^~~~~~~~
--
   In file included from include/asm-generic/bitops/le.h:6:0,
                    from arch/h8300/include/asm/bitops.h:177,
                    from include/linux/bitops.h:38,
                    from include/linux/kernel.h:11,
                    from include/asm-generic/bug.h:18,
                    from arch/h8300/include/asm/bug.h:8,
                    from include/linux/bug.h:5,
                    from include/linux/page-flags.h:10,
                    from kernel/bounds.c:10:
>> arch/h8300/include/asm/byteorder.h:5:0: warning: "__BIG_ENDIAN" redefined
    #define __BIG_ENDIAN __ORDER_BIG_ENDIAN__
    
   In file included from <command-line>:0:0:
   include/linux/kconfig.h:8:0: note: this is the location of the previous definition
    #define __BIG_ENDIAN 4321
    
   In file included from include/asm-generic/bitops/le.h:6:0,
                    from arch/h8300/include/asm/bitops.h:177,
                    from include/linux/bitops.h:38,
                    from include/linux/kernel.h:11,
                    from include/asm-generic/bug.h:18,
                    from arch/h8300/include/asm/bug.h:8,
                    from include/linux/bug.h:5,
                    from include/linux/thread_info.h:12,
                    from include/asm-generic/current.h:5,
                    from ./arch/h8300/include/generated/asm/current.h:1,
                    from include/linux/sched.h:12,
                    from arch/h8300/kernel/asm-offsets.c:13:
>> arch/h8300/include/asm/byteorder.h:5:0: warning: "__BIG_ENDIAN" redefined
    #define __BIG_ENDIAN __ORDER_BIG_ENDIAN__
    
   In file included from <command-line>:0:0:
   include/linux/kconfig.h:8:0: note: this is the location of the previous definition
    #define __BIG_ENDIAN 4321
    

vim +/__BIG_ENDIAN +5 arch/h8300/include/asm/byteorder.h

d2a5f499 Yoshinori Sato 2015-05-11  4  
d2a5f499 Yoshinori Sato 2015-05-11 @5  #define __BIG_ENDIAN __ORDER_BIG_ENDIAN__
d2a5f499 Yoshinori Sato 2015-05-11  6  #include <linux/byteorder/big_endian.h>
d2a5f499 Yoshinori Sato 2015-05-11  7  

:::::: The code at line 5 was first introduced by commit
:::::: d2a5f4999f6c211adf30d9788349e13988d6f2a7 h8300: Assembly headers

:::::: TO: Yoshinori Sato <ysato@users.sourceforge.jp>
:::::: CC: Yoshinori Sato <ysato@users.sourceforge.jp>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--/9DWx/yDrRhgMJTb
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
HhaUPgAA

--/9DWx/yDrRhgMJTb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
