Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 26F016B0035
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 01:52:47 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id rd3so2719315pab.31
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 22:52:46 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id sr7si8441885pab.202.2014.06.19.22.52.45
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 22:52:46 -0700 (PDT)
Date: Fri, 20 Jun 2014 13:52:10 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [mmotm:master 141/230] include/linux/kernel.h:744:28: note: in
 expansion of macro 'min'
Message-ID: <20140620055210.GA26552@localhost>
References: <53a3c359.yUYVC7fzjYpZLyLq%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53a3c359.yUYVC7fzjYpZLyLq%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Hagen Paul Pfeifer <hagen@jauu.net>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   df25ba7db0775d87018e2cd92f26b9b087093840
commit: 99c369839f847d2cc4b8e759a9c57c925592efa2 [141/230] include/linux/kernel.h: rewrite min3, max3 and clamp using min and max
config: make ARCH=x86_64 allmodconfig

All warnings:

   drivers/net/ethernet/intel/i40e/i40e_debugfs.c:1901:25: sparse: incompatible types in comparison expression (different type sizes)
   In file included from arch/x86/include/asm/percpu.h:44:0,
                    from arch/x86/include/asm/preempt.h:5,
                    from include/linux/preempt.h:18,
                    from include/linux/spinlock.h:50,
                    from include/linux/wait.h:8,
                    from include/linux/fs.h:6,
                    from drivers/net/ethernet/intel/i40e/i40e_debugfs.c:29:
   drivers/net/ethernet/intel/i40e/i40e_debugfs.c: In function 'i40e_dbg_command_write':
   include/linux/kernel.h:713:17: warning: comparison of distinct pointer types lacks a cast [enabled by default]
     (void) (&_min1 == &_min2);  \
                    ^
>> include/linux/kernel.h:744:28: note: in expansion of macro 'min'
    #define clamp(val, lo, hi) min(max(val, lo), hi)
                               ^
>> drivers/net/ethernet/intel/i40e/i40e_debugfs.c:1901:11: note: in expansion of macro 'clamp'
      bytes = clamp(bytes, (u16)1024, (u16)I40E_MAX_AQ_BUF_SIZE);
              ^
--
   drivers/net/wireless/rtlwifi/rtl8723ae/dm.c:269:21: sparse: incompatible types in comparison expression (different type sizes)
   In file included from include/linux/sched.h:17:0,
                    from drivers/net/wireless/rtlwifi/rtl8723ae/../wifi.h:35,
                    from drivers/net/wireless/rtlwifi/rtl8723ae/dm.c:31:
   drivers/net/wireless/rtlwifi/rtl8723ae/dm.c: In function 'rtl92c_dm_ctrl_initgain_by_fa':
   include/linux/kernel.h:713:17: warning: comparison of distinct pointer types lacks a cast [enabled by default]
     (void) (&_min1 == &_min2);  \
                    ^
>> include/linux/kernel.h:744:28: note: in expansion of macro 'min'
    #define clamp(val, lo, hi) min(max(val, lo), hi)
                               ^
>> drivers/net/wireless/rtlwifi/rtl8723ae/dm.c:269:14: note: in expansion of macro 'clamp'
     value_igi = clamp(value_igi, (u8)DM_DIG_FA_LOWER, (u8)DM_DIG_FA_UPPER);
                 ^
--
   drivers/staging/iio/impedance-analyzer/ad5933.c:241:17: sparse: incorrect type in assignment (different base types)
   drivers/staging/iio/impedance-analyzer/ad5933.c:241:17:    expected unsigned int [unsigned] [usertype] d32
   drivers/staging/iio/impedance-analyzer/ad5933.c:241:17:    got restricted __be32 [usertype] <noident>
   drivers/staging/iio/impedance-analyzer/ad5933.c:263:13: sparse: incorrect type in assignment (different base types)
   drivers/staging/iio/impedance-analyzer/ad5933.c:263:13:    expected unsigned short [unsigned] dat
   drivers/staging/iio/impedance-analyzer/ad5933.c:263:13:    got restricted __be16 [usertype] <noident>
   drivers/staging/iio/impedance-analyzer/ad5933.c:271:13: sparse: incorrect type in assignment (different base types)
   drivers/staging/iio/impedance-analyzer/ad5933.c:271:13:    expected unsigned short [unsigned] [addressable] dat
   drivers/staging/iio/impedance-analyzer/ad5933.c:271:13:    got restricted __be16 [usertype] <noident>
   drivers/staging/iio/impedance-analyzer/ad5933.c:310:19: sparse: cast to restricted __be32
   drivers/staging/iio/impedance-analyzer/ad5933.c:310:19: sparse: cast to restricted __be32
   drivers/staging/iio/impedance-analyzer/ad5933.c:310:19: sparse: cast to restricted __be32
   drivers/staging/iio/impedance-analyzer/ad5933.c:310:19: sparse: cast to restricted __be32
   drivers/staging/iio/impedance-analyzer/ad5933.c:310:19: sparse: cast to restricted __be32
   drivers/staging/iio/impedance-analyzer/ad5933.c:310:19: sparse: cast to restricted __be32
   drivers/staging/iio/impedance-analyzer/ad5933.c:437:23: sparse: incompatible types in comparison expression (different type sizes)
   drivers/staging/iio/impedance-analyzer/ad5933.c:451:23: sparse: incompatible types in comparison expression (different type sizes)
   In file included from include/linux/interrupt.h:5:0,
                    from drivers/staging/iio/impedance-analyzer/ad5933.c:9:
   drivers/staging/iio/impedance-analyzer/ad5933.c: In function 'ad5933_store':
   include/linux/kernel.h:713:17: warning: comparison of distinct pointer types lacks a cast [enabled by default]
     (void) (&_min1 == &_min2);  \
                    ^
>> include/linux/kernel.h:744:28: note: in expansion of macro 'min'
    #define clamp(val, lo, hi) min(max(val, lo), hi)
                               ^
>> drivers/staging/iio/impedance-analyzer/ad5933.c:437:9: note: in expansion of macro 'clamp'
      val = clamp(val, (u16)0, (u16)0x7FF);
            ^
   include/linux/kernel.h:713:17: warning: comparison of distinct pointer types lacks a cast [enabled by default]
     (void) (&_min1 == &_min2);  \
                    ^
>> include/linux/kernel.h:744:28: note: in expansion of macro 'min'
    #define clamp(val, lo, hi) min(max(val, lo), hi)
                               ^
>> drivers/staging/iio/impedance-analyzer/ad5933.c:451:9: note: in expansion of macro 'clamp'
      val = clamp(val, (u16)0, (u16)511);
            ^

sparse warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/intel/i40e/i40e_debugfs.c:1901:25: sparse: incompatible types in comparison expression (different type sizes)
   In file included from arch/x86/include/asm/percpu.h:44:0,
                    from arch/x86/include/asm/preempt.h:5,
                    from include/linux/preempt.h:18,
                    from include/linux/spinlock.h:50,
                    from include/linux/wait.h:8,
                    from include/linux/fs.h:6,
                    from drivers/net/ethernet/intel/i40e/i40e_debugfs.c:29:
   drivers/net/ethernet/intel/i40e/i40e_debugfs.c: In function 'i40e_dbg_command_write':
   include/linux/kernel.h:713:17: warning: comparison of distinct pointer types lacks a cast [enabled by default]
     (void) (&_min1 == &_min2);  \
                    ^
   include/linux/kernel.h:744:28: note: in expansion of macro 'min'
    #define clamp(val, lo, hi) min(max(val, lo), hi)
                               ^
   drivers/net/ethernet/intel/i40e/i40e_debugfs.c:1901:11: note: in expansion of macro 'clamp'
      bytes = clamp(bytes, (u16)1024, (u16)I40E_MAX_AQ_BUF_SIZE);
              ^
--
>> drivers/net/wireless/rtlwifi/rtl8723ae/dm.c:269:21: sparse: incompatible types in comparison expression (different type sizes)
   In file included from include/linux/sched.h:17:0,
                    from drivers/net/wireless/rtlwifi/rtl8723ae/../wifi.h:35,
                    from drivers/net/wireless/rtlwifi/rtl8723ae/dm.c:31:
   drivers/net/wireless/rtlwifi/rtl8723ae/dm.c: In function 'rtl92c_dm_ctrl_initgain_by_fa':
   include/linux/kernel.h:713:17: warning: comparison of distinct pointer types lacks a cast [enabled by default]
     (void) (&_min1 == &_min2);  \
                    ^
   include/linux/kernel.h:744:28: note: in expansion of macro 'min'
    #define clamp(val, lo, hi) min(max(val, lo), hi)
                               ^
   drivers/net/wireless/rtlwifi/rtl8723ae/dm.c:269:14: note: in expansion of macro 'clamp'
     value_igi = clamp(value_igi, (u8)DM_DIG_FA_LOWER, (u8)DM_DIG_FA_UPPER);
                 ^
--
   drivers/staging/iio/impedance-analyzer/ad5933.c:241:17: sparse: incorrect type in assignment (different base types)
   drivers/staging/iio/impedance-analyzer/ad5933.c:241:17:    expected unsigned int [unsigned] [usertype] d32
   drivers/staging/iio/impedance-analyzer/ad5933.c:241:17:    got restricted __be32 [usertype] <noident>
   drivers/staging/iio/impedance-analyzer/ad5933.c:263:13: sparse: incorrect type in assignment (different base types)
   drivers/staging/iio/impedance-analyzer/ad5933.c:263:13:    expected unsigned short [unsigned] dat
   drivers/staging/iio/impedance-analyzer/ad5933.c:263:13:    got restricted __be16 [usertype] <noident>
   drivers/staging/iio/impedance-analyzer/ad5933.c:271:13: sparse: incorrect type in assignment (different base types)
   drivers/staging/iio/impedance-analyzer/ad5933.c:271:13:    expected unsigned short [unsigned] [addressable] dat
   drivers/staging/iio/impedance-analyzer/ad5933.c:271:13:    got restricted __be16 [usertype] <noident>
   drivers/staging/iio/impedance-analyzer/ad5933.c:310:19: sparse: cast to restricted __be32
   drivers/staging/iio/impedance-analyzer/ad5933.c:310:19: sparse: cast to restricted __be32
   drivers/staging/iio/impedance-analyzer/ad5933.c:310:19: sparse: cast to restricted __be32
   drivers/staging/iio/impedance-analyzer/ad5933.c:310:19: sparse: cast to restricted __be32
   drivers/staging/iio/impedance-analyzer/ad5933.c:310:19: sparse: cast to restricted __be32
   drivers/staging/iio/impedance-analyzer/ad5933.c:310:19: sparse: cast to restricted __be32
>> drivers/staging/iio/impedance-analyzer/ad5933.c:437:23: sparse: incompatible types in comparison expression (different type sizes)
>> drivers/staging/iio/impedance-analyzer/ad5933.c:451:23: sparse: incompatible types in comparison expression (different type sizes)
   In file included from include/linux/interrupt.h:5:0,
                    from drivers/staging/iio/impedance-analyzer/ad5933.c:9:
   drivers/staging/iio/impedance-analyzer/ad5933.c: In function 'ad5933_store':
   include/linux/kernel.h:713:17: warning: comparison of distinct pointer types lacks a cast [enabled by default]
     (void) (&_min1 == &_min2);  \
                    ^
   include/linux/kernel.h:744:28: note: in expansion of macro 'min'
    #define clamp(val, lo, hi) min(max(val, lo), hi)
                               ^
   drivers/staging/iio/impedance-analyzer/ad5933.c:437:9: note: in expansion of macro 'clamp'
      val = clamp(val, (u16)0, (u16)0x7FF);
            ^
   include/linux/kernel.h:713:17: warning: comparison of distinct pointer types lacks a cast [enabled by default]
     (void) (&_min1 == &_min2);  \
                    ^
   include/linux/kernel.h:744:28: note: in expansion of macro 'min'
    #define clamp(val, lo, hi) min(max(val, lo), hi)
                               ^
   drivers/staging/iio/impedance-analyzer/ad5933.c:451:9: note: in expansion of macro 'clamp'
      val = clamp(val, (u16)0, (u16)511);
            ^

vim +/min +744 include/linux/kernel.h

^1da177e Linus Torvalds     2005-04-16  707   * strict type-checking.. See the
^1da177e Linus Torvalds     2005-04-16  708   * "unnecessary" pointer comparison.
^1da177e Linus Torvalds     2005-04-16  709   */
bdf4bbaa Harvey Harrison    2008-04-30  710  #define min(x, y) ({				\
bdf4bbaa Harvey Harrison    2008-04-30  711  	typeof(x) _min1 = (x);			\
bdf4bbaa Harvey Harrison    2008-04-30  712  	typeof(y) _min2 = (y);			\
bdf4bbaa Harvey Harrison    2008-04-30 @713  	(void) (&_min1 == &_min2);		\
bdf4bbaa Harvey Harrison    2008-04-30  714  	_min1 < _min2 ? _min1 : _min2; })
bdf4bbaa Harvey Harrison    2008-04-30  715  
bdf4bbaa Harvey Harrison    2008-04-30  716  #define max(x, y) ({				\
bdf4bbaa Harvey Harrison    2008-04-30  717  	typeof(x) _max1 = (x);			\
bdf4bbaa Harvey Harrison    2008-04-30  718  	typeof(y) _max2 = (y);			\
bdf4bbaa Harvey Harrison    2008-04-30  719  	(void) (&_max1 == &_max2);		\
bdf4bbaa Harvey Harrison    2008-04-30  720  	_max1 > _max2 ? _max1 : _max2; })
bdf4bbaa Harvey Harrison    2008-04-30  721  
99c36983 Michal Nazarewicz  2014-06-20  722  #define min3(x, y, z) min(min(x, y), z)
99c36983 Michal Nazarewicz  2014-06-20  723  #define max3(x, y, z) max(max(x, y), z)
f27c85c5 Hagen Paul Pfeifer 2010-10-26  724  
bdf4bbaa Harvey Harrison    2008-04-30  725  /**
c8bf1336 Martin K. Petersen 2010-09-10  726   * min_not_zero - return the minimum that is _not_ zero, unless both are zero
c8bf1336 Martin K. Petersen 2010-09-10  727   * @x: value1
c8bf1336 Martin K. Petersen 2010-09-10  728   * @y: value2
c8bf1336 Martin K. Petersen 2010-09-10  729   */
c8bf1336 Martin K. Petersen 2010-09-10  730  #define min_not_zero(x, y) ({			\
c8bf1336 Martin K. Petersen 2010-09-10  731  	typeof(x) __x = (x);			\
c8bf1336 Martin K. Petersen 2010-09-10  732  	typeof(y) __y = (y);			\
c8bf1336 Martin K. Petersen 2010-09-10  733  	__x == 0 ? __y : ((__y == 0) ? __x : min(__x, __y)); })
c8bf1336 Martin K. Petersen 2010-09-10  734  
c8bf1336 Martin K. Petersen 2010-09-10  735  /**
bdf4bbaa Harvey Harrison    2008-04-30  736   * clamp - return a value clamped to a given range with strict typechecking
bdf4bbaa Harvey Harrison    2008-04-30  737   * @val: current value
99c36983 Michal Nazarewicz  2014-06-20  738   * @lo: lowest allowable value
99c36983 Michal Nazarewicz  2014-06-20  739   * @hi: highest allowable value
bdf4bbaa Harvey Harrison    2008-04-30  740   *
bdf4bbaa Harvey Harrison    2008-04-30  741   * This macro does strict typechecking of min/max to make sure they are of the
bdf4bbaa Harvey Harrison    2008-04-30  742   * same type as val.  See the unnecessary pointer comparisons.
bdf4bbaa Harvey Harrison    2008-04-30  743   */
99c36983 Michal Nazarewicz  2014-06-20 @744  #define clamp(val, lo, hi) min(max(val, lo), hi)
^1da177e Linus Torvalds     2005-04-16  745  
^1da177e Linus Torvalds     2005-04-16  746  /*
^1da177e Linus Torvalds     2005-04-16  747   * ..and if you can't take the strict

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
