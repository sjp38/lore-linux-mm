Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 147A56B0005
	for <linux-mm@kvack.org>; Sat, 10 Mar 2018 08:28:42 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id e126so3047844pfh.4
        for <linux-mm@kvack.org>; Sat, 10 Mar 2018 05:28:42 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id w11-v6si1441431plz.214.2018.03.10.05.28.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Mar 2018 05:28:40 -0800 (PST)
Date: Sat, 10 Mar 2018 21:27:34 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: arch/h8300/include/asm/byteorder.h:5:0: warning: "__BIG_ENDIAN"
 redefined
Message-ID: <201803102118.2RzgEHI7%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="VbJkn9YxBvnuCH5J"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   cdb06e9d8f520c969676e7d6778cffe5894f079f
commit: 101110f6271ce956a049250c907bc960030577f8 Kbuild: always define endianess in kconfig.h
date:   2 weeks ago
config: h8300-h8300h-sim_defconfig (attached as .config)
compiler: h8300-linux-gcc (GCC) 7.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 101110f6271ce956a049250c907bc960030577f8
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

--VbJkn9YxBvnuCH5J
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
YB/1qBP7fyFPn+6zQAAA

--VbJkn9YxBvnuCH5J--
