Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id DE4BB6B0036
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 03:38:56 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id up15so2825190pbc.34
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 00:38:56 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id eh8si8755927pac.153.2014.06.20.00.38.55
        for <linux-mm@kvack.org>;
        Fri, 20 Jun 2014 00:38:55 -0700 (PDT)
Date: Fri, 20 Jun 2014 15:38:30 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 188/230] fs/jffs2/debug.h:69:3: note: in expansion
 of macro 'pr_debug'
Message-ID: <53a3e4f6.LlTrbyV58fY2TrZa%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   df25ba7db0775d87018e2cd92f26b9b087093840
commit: 0b3f61ac78013e35939696ddd63b9b871d11bf72 [188/230] initramfs: support initramfs that is more than 2G
config: make ARCH=x86_64 allmodconfig

All warnings:

   fs/jffs2/compr_zlib.c:97:37: sparse: incompatible types in comparison expression (different type sizes)
   In file included from fs/jffs2/compr_zlib.c:19:0:
   fs/jffs2/compr_zlib.c: In function 'jffs2_zlib_compress':
   include/linux/kernel.h:713:17: warning: comparison of distinct pointer types lacks a cast [enabled by default]
     (void) (&_min1 == &_min2);  \
                    ^
   fs/jffs2/compr_zlib.c:97:23: note: in expansion of macro 'min'
      def_strm.avail_in = min((unsigned)(*sourcelen-def_strm.total_in), def_strm.avail_out);
                          ^
   In file included from include/linux/printk.h:257:0,
                    from include/linux/kernel.h:13,
                    from fs/jffs2/compr_zlib.c:19:
   include/linux/dynamic_debug.h:64:16: warning: format '%d' expects argument of type 'int', but argument 3 has type 'uLong' [-Wformat=]
     static struct _ddebug  __aligned(8)   \
                   ^
   include/linux/dynamic_debug.h:76:2: note: in expansion of macro 'DEFINE_DYNAMIC_DEBUG_METADATA'
     DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);  \
     ^
   include/linux/printk.h:263:2: note: in expansion of macro 'dynamic_pr_debug'
     dynamic_pr_debug(fmt, ##__VA_ARGS__)
     ^
>> fs/jffs2/debug.h:69:3: note: in expansion of macro 'pr_debug'
      pr_debug(fmt, ##__VA_ARGS__); \
      ^
>> fs/jffs2/compr_zlib.c:98:3: note: in expansion of macro 'jffs2_dbg'
      jffs2_dbg(1, "calling deflate with avail_in %d, avail_out %d\n",
      ^
   include/linux/dynamic_debug.h:64:16: warning: format '%d' expects argument of type 'int', but argument 4 has type 'uLong' [-Wformat=]
     static struct _ddebug  __aligned(8)   \
                   ^
   include/linux/dynamic_debug.h:76:2: note: in expansion of macro 'DEFINE_DYNAMIC_DEBUG_METADATA'
     DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);  \
     ^
   include/linux/printk.h:263:2: note: in expansion of macro 'dynamic_pr_debug'
     dynamic_pr_debug(fmt, ##__VA_ARGS__)
     ^
>> fs/jffs2/debug.h:69:3: note: in expansion of macro 'pr_debug'
      pr_debug(fmt, ##__VA_ARGS__); \
      ^
>> fs/jffs2/compr_zlib.c:98:3: note: in expansion of macro 'jffs2_dbg'
      jffs2_dbg(1, "calling deflate with avail_in %d, avail_out %d\n",
      ^
   include/linux/dynamic_debug.h:64:16: warning: format '%d' expects argument of type 'int', but argument 3 has type 'uLong' [-Wformat=]
     static struct _ddebug  __aligned(8)   \
                   ^
   include/linux/dynamic_debug.h:76:2: note: in expansion of macro 'DEFINE_DYNAMIC_DEBUG_METADATA'
     DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);  \
     ^
   include/linux/printk.h:263:2: note: in expansion of macro 'dynamic_pr_debug'
     dynamic_pr_debug(fmt, ##__VA_ARGS__)
     ^
>> fs/jffs2/debug.h:69:3: note: in expansion of macro 'pr_debug'
      pr_debug(fmt, ##__VA_ARGS__); \
      ^
>> fs/jffs2/compr_zlib.c:101:3: note: in expansion of macro 'jffs2_dbg'
      jffs2_dbg(1, "deflate returned with avail_in %d, avail_out %d, total_in %ld, total_out %ld\n",
      ^
   include/linux/dynamic_debug.h:64:16: warning: format '%d' expects argument of type 'int', but argument 4 has type 'uLong' [-Wformat=]
     static struct _ddebug  __aligned(8)   \
                   ^
   include/linux/dynamic_debug.h:76:2: note: in expansion of macro 'DEFINE_DYNAMIC_DEBUG_METADATA'
     DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);  \
     ^
   include/linux/printk.h:263:2: note: in expansion of macro 'dynamic_pr_debug'
     dynamic_pr_debug(fmt, ##__VA_ARGS__)
     ^
>> fs/jffs2/debug.h:69:3: note: in expansion of macro 'pr_debug'
      pr_debug(fmt, ##__VA_ARGS__); \
      ^
>> fs/jffs2/compr_zlib.c:101:3: note: in expansion of macro 'jffs2_dbg'
      jffs2_dbg(1, "deflate returned with avail_in %d, avail_out %d, total_in %ld, total_out %ld\n",
      ^

sparse warnings: (new ones prefixed by >>)

>> fs/jffs2/compr_zlib.c:97:37: sparse: incompatible types in comparison expression (different type sizes)
   In file included from fs/jffs2/compr_zlib.c:19:0:
   fs/jffs2/compr_zlib.c: In function 'jffs2_zlib_compress':
   include/linux/kernel.h:713:17: warning: comparison of distinct pointer types lacks a cast [enabled by default]
     (void) (&_min1 == &_min2);  \
                    ^
   fs/jffs2/compr_zlib.c:97:23: note: in expansion of macro 'min'
      def_strm.avail_in = min((unsigned)(*sourcelen-def_strm.total_in), def_strm.avail_out);
                          ^
   In file included from include/linux/printk.h:257:0,
                    from include/linux/kernel.h:13,
                    from fs/jffs2/compr_zlib.c:19:
   include/linux/dynamic_debug.h:64:16: warning: format '%d' expects argument of type 'int', but argument 3 has type 'uLong' [-Wformat=]
     static struct _ddebug  __aligned(8)   \
                   ^
   include/linux/dynamic_debug.h:76:2: note: in expansion of macro 'DEFINE_DYNAMIC_DEBUG_METADATA'
     DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);  \
     ^
   include/linux/printk.h:263:2: note: in expansion of macro 'dynamic_pr_debug'
     dynamic_pr_debug(fmt, ##__VA_ARGS__)
     ^
   fs/jffs2/debug.h:69:3: note: in expansion of macro 'pr_debug'
      pr_debug(fmt, ##__VA_ARGS__); \
      ^
   fs/jffs2/compr_zlib.c:98:3: note: in expansion of macro 'jffs2_dbg'
      jffs2_dbg(1, "calling deflate with avail_in %d, avail_out %d\n",
      ^
   include/linux/dynamic_debug.h:64:16: warning: format '%d' expects argument of type 'int', but argument 4 has type 'uLong' [-Wformat=]
     static struct _ddebug  __aligned(8)   \
                   ^
   include/linux/dynamic_debug.h:76:2: note: in expansion of macro 'DEFINE_DYNAMIC_DEBUG_METADATA'
     DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);  \
     ^
   include/linux/printk.h:263:2: note: in expansion of macro 'dynamic_pr_debug'
     dynamic_pr_debug(fmt, ##__VA_ARGS__)
     ^
   fs/jffs2/debug.h:69:3: note: in expansion of macro 'pr_debug'
      pr_debug(fmt, ##__VA_ARGS__); \
      ^
   fs/jffs2/compr_zlib.c:98:3: note: in expansion of macro 'jffs2_dbg'
      jffs2_dbg(1, "calling deflate with avail_in %d, avail_out %d\n",
      ^
   include/linux/dynamic_debug.h:64:16: warning: format '%d' expects argument of type 'int', but argument 3 has type 'uLong' [-Wformat=]
     static struct _ddebug  __aligned(8)   \
                   ^
   include/linux/dynamic_debug.h:76:2: note: in expansion of macro 'DEFINE_DYNAMIC_DEBUG_METADATA'
     DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);  \
     ^
   include/linux/printk.h:263:2: note: in expansion of macro 'dynamic_pr_debug'
     dynamic_pr_debug(fmt, ##__VA_ARGS__)
     ^
   fs/jffs2/debug.h:69:3: note: in expansion of macro 'pr_debug'
      pr_debug(fmt, ##__VA_ARGS__); \
      ^
   fs/jffs2/compr_zlib.c:101:3: note: in expansion of macro 'jffs2_dbg'
      jffs2_dbg(1, "deflate returned with avail_in %d, avail_out %d, total_in %ld, total_out %ld\n",
      ^
   include/linux/dynamic_debug.h:64:16: warning: format '%d' expects argument of type 'int', but argument 4 has type 'uLong' [-Wformat=]
     static struct _ddebug  __aligned(8)   \
                   ^
   include/linux/dynamic_debug.h:76:2: note: in expansion of macro 'DEFINE_DYNAMIC_DEBUG_METADATA'
     DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);  \
     ^
   include/linux/printk.h:263:2: note: in expansion of macro 'dynamic_pr_debug'
     dynamic_pr_debug(fmt, ##__VA_ARGS__)
     ^
   fs/jffs2/debug.h:69:3: note: in expansion of macro 'pr_debug'
      pr_debug(fmt, ##__VA_ARGS__); \
      ^
   fs/jffs2/compr_zlib.c:101:3: note: in expansion of macro 'jffs2_dbg'
      jffs2_dbg(1, "deflate returned with avail_in %d, avail_out %d, total_in %ld, total_out %ld\n",
      ^

vim +/pr_debug +69 fs/jffs2/debug.h

e0c8e42f Artem B. Bityutskiy 2005-07-24  53  #if CONFIG_JFFS2_FS_DEBUG > 0
9c261b33 Joe Perches         2012-02-15  54  #define DEBUG
730554d9 Artem B. Bityutskiy 2005-07-17  55  #define D1(x) x
730554d9 Artem B. Bityutskiy 2005-07-17  56  #else
730554d9 Artem B. Bityutskiy 2005-07-17  57  #define D1(x)
730554d9 Artem B. Bityutskiy 2005-07-17  58  #endif
730554d9 Artem B. Bityutskiy 2005-07-17  59  
730554d9 Artem B. Bityutskiy 2005-07-17  60  #if CONFIG_JFFS2_FS_DEBUG > 1
730554d9 Artem B. Bityutskiy 2005-07-17  61  #define D2(x) x
730554d9 Artem B. Bityutskiy 2005-07-17  62  #else
730554d9 Artem B. Bityutskiy 2005-07-17  63  #define D2(x)
730554d9 Artem B. Bityutskiy 2005-07-17  64  #endif
730554d9 Artem B. Bityutskiy 2005-07-17  65  
9c261b33 Joe Perches         2012-02-15  66  #define jffs2_dbg(level, fmt, ...)		\
9c261b33 Joe Perches         2012-02-15  67  do {						\
9c261b33 Joe Perches         2012-02-15  68  	if (CONFIG_JFFS2_FS_DEBUG >= level)	\
9c261b33 Joe Perches         2012-02-15 @69  		pr_debug(fmt, ##__VA_ARGS__);	\
9c261b33 Joe Perches         2012-02-15  70  } while (0)
9c261b33 Joe Perches         2012-02-15  71  
e0c8e42f Artem B. Bityutskiy 2005-07-24  72  /* The prefixes of JFFS2 messages */
9bbf29e4 Joe Perches         2012-02-15  73  #define JFFS2_DBG		KERN_DEBUG
81e39cf0 Artem B. Bityutskiy 2005-09-14  74  #define JFFS2_DBG_PREFIX	"[JFFS2 DBG]"
81e39cf0 Artem B. Bityutskiy 2005-09-14  75  #define JFFS2_DBG_MSG_PREFIX	JFFS2_DBG JFFS2_DBG_PREFIX
730554d9 Artem B. Bityutskiy 2005-07-17  76  
e0c8e42f Artem B. Bityutskiy 2005-07-24  77  /* JFFS2 message macros */

:::::: The code at line 69 was first introduced by commit
:::::: 9c261b33a9c417ccaf07f41796be278d09d02d49 jffs2: Convert most D1/D2 macros to jffs2_dbg

:::::: TO: Joe Perches <joe@perches.com>
:::::: CC: David Woodhouse <David.Woodhouse@intel.com>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
