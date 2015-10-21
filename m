Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id AA25782F65
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 10:19:35 -0400 (EDT)
Received: by iofz202 with SMTP id z202so58645013iof.2
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 07:19:35 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id m5si5474390igx.76.2015.10.21.07.19.34
        for <linux-mm@kvack.org>;
        Wed, 21 Oct 2015 07:19:34 -0700 (PDT)
Date: Wed, 21 Oct 2015 22:13:00 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-review:Tetsuo-Handa/mm-vmscan-Use-accurate-values-for-zone_reclaimable-checks/20151021-203036
 9489/9695] arch/arm/include/asm/glue-cache.h:133:20: error: storage class
 specified for parameter 'nop_flush_icache_all'
Message-ID: <201510212256.8vtL5uBm%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="sm4nu43k4a2Rpi4c"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--sm4nu43k4a2Rpi4c
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Minchan,

[auto build test ERROR on v4.3-rc6-108-gce1fad2 -- if it's inappropriate base, please suggest rules for selecting the more suitable base]

url:    https://github.com/0day-ci/linux/commits/Tetsuo-Handa/mm-vmscan-Use-accurate-values-for-zone_reclaimable-checks/20151021-203036
config: arm-allnoconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=arm 

All error/warnings (new ones prefixed by >>):

   In file included from init/main.c:50:0:
   include/linux/rmap.h:274:1: error: expected declaration specifiers or '...' before '{' token
    {
    ^
   In file included from include/linux/highmem.h:8:0,
                    from include/linux/pagemap.h:10,
                    from include/linux/mempolicy.h:14,
                    from init/main.c:51:
   include/linux/uaccess.h:88:13: error: storage class specified for parameter '__probe_kernel_read'
    extern long __probe_kernel_read(void *dst, const void *src, size_t size);
                ^
   include/linux/uaccess.h:99:21: error: storage class specified for parameter 'probe_kernel_write'
    extern long notrace probe_kernel_write(void *dst, const void *src, size_t size);
                        ^
   include/linux/uaccess.h:99:21: error: 'no_instrument_function' attribute applies only to functions
   include/linux/uaccess.h:100:21: error: storage class specified for parameter '__probe_kernel_write'
    extern long notrace __probe_kernel_write(void *dst, const void *src, size_t size);
                        ^
   include/linux/uaccess.h:100:21: error: 'no_instrument_function' attribute applies only to functions
   include/linux/uaccess.h:102:13: error: storage class specified for parameter 'strncpy_from_unsafe'
    extern long strncpy_from_unsafe(char *dst, const void *unsafe_addr, long count);
                ^
   In file included from arch/arm/include/asm/cacheflush.h:15:0,
                    from include/linux/highmem.h:11,
                    from include/linux/pagemap.h:10,
                    from include/linux/mempolicy.h:14,
                    from init/main.c:51:
>> arch/arm/include/asm/glue-cache.h:133:20: error: storage class specified for parameter 'nop_flush_icache_all'
    static inline void nop_flush_icache_all(void) { }
                       ^
>> arch/arm/include/asm/glue-cache.h:133:20: warning: parameter 'nop_flush_icache_all' declared 'inline'
>> arch/arm/include/asm/glue-cache.h:133:1: warning: 'always_inline' attribute ignored [-Wattributes]
    static inline void nop_flush_icache_all(void) { }
    ^
>> arch/arm/include/asm/glue-cache.h:133:20: error: 'no_instrument_function' attribute applies only to functions
    static inline void nop_flush_icache_all(void) { }
                       ^
>> arch/arm/include/asm/glue-cache.h:133:47: error: expected ';', ',' or ')' before '{' token
    static inline void nop_flush_icache_all(void) { }
                                                  ^

vim +/nop_flush_icache_all +133 arch/arm/include/asm/glue-cache.h

a67e1ce1 Russell King    2012-09-02  117  # endif
753790e7 Russell King    2011-02-06  118  #endif
753790e7 Russell King    2011-02-06  119  
55bdd694 Catalin Marinas 2010-05-21  120  #if defined(CONFIG_CPU_V7M)
55bdd694 Catalin Marinas 2010-05-21  121  # ifdef _CACHE
55bdd694 Catalin Marinas 2010-05-21  122  #  define MULTI_CACHE 1
55bdd694 Catalin Marinas 2010-05-21  123  # else
55bdd694 Catalin Marinas 2010-05-21  124  #  define _CACHE nop
55bdd694 Catalin Marinas 2010-05-21  125  # endif
55bdd694 Catalin Marinas 2010-05-21  126  #endif
55bdd694 Catalin Marinas 2010-05-21  127  
753790e7 Russell King    2011-02-06  128  #if !defined(_CACHE) && !defined(MULTI_CACHE)
25985edc Lucas De Marchi 2011-03-30  129  #error Unknown cache maintenance model
753790e7 Russell King    2011-02-06  130  #endif
753790e7 Russell King    2011-02-06  131  
55bdd694 Catalin Marinas 2010-05-21  132  #ifndef __ASSEMBLER__
76ae0382 Behan Webster   2013-09-03 @133  static inline void nop_flush_icache_all(void) { }
76ae0382 Behan Webster   2013-09-03  134  static inline void nop_flush_kern_cache_all(void) { }
76ae0382 Behan Webster   2013-09-03  135  static inline void nop_flush_kern_cache_louis(void) { }
76ae0382 Behan Webster   2013-09-03  136  static inline void nop_flush_user_cache_all(void) { }
76ae0382 Behan Webster   2013-09-03  137  static inline void nop_flush_user_cache_range(unsigned long a,
55bdd694 Catalin Marinas 2010-05-21  138  		unsigned long b, unsigned int c) { }
55bdd694 Catalin Marinas 2010-05-21  139  
76ae0382 Behan Webster   2013-09-03  140  static inline void nop_coherent_kern_range(unsigned long a, unsigned long b) { }
76ae0382 Behan Webster   2013-09-03  141  static inline int nop_coherent_user_range(unsigned long a,

:::::: The code at line 133 was first introduced by commit
:::::: 76ae03828756bac2c1fa2c7eff7485e5f815dbdb ARM: LLVMLinux: Change "extern inline" to "static inline" in glue-cache.h

:::::: TO: Behan Webster <behanw@converseincode.com>
:::::: CC: Behan Webster <behanw@converseincode.com>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--sm4nu43k4a2Rpi4c
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--sm4nu43k4a2Rpi4c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
