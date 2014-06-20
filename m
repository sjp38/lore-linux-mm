Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9AE926B0036
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 22:27:47 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id hz1so2557873pad.10
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 19:27:47 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id bh2si7816167pbb.204.2014.06.19.19.27.46
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 19:27:46 -0700 (PDT)
Date: Fri, 20 Jun 2014 10:27:00 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 188/230] include/linux/dynamic_debug.h:64:16:
 warning: format '%d' expects argument of type 'int', but argument 3 has
 type 'uLong'
Message-ID: <53a39bf4.C5p/iBVbxXO4gRR1%fengguang.wu@intel.com>
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
config: make ARCH=ia64 allmodconfig

All warnings:

   In file included from fs/jffs2/compr_zlib.c:19:0:
   fs/jffs2/compr_zlib.c: In function 'jffs2_zlib_compress':
   include/linux/kernel.h:713:17: warning: comparison of distinct pointer types lacks a cast
     (void) (&_min1 == &_min2);  \
                    ^
   fs/jffs2/compr_zlib.c:97:23: note: in expansion of macro 'min'
      def_strm.avail_in = min((unsigned)(*sourcelen-def_strm.total_in), def_strm.avail_out);
                          ^
   In file included from include/linux/printk.h:257:0,
                    from include/linux/kernel.h:13,
                    from fs/jffs2/compr_zlib.c:19:
>> include/linux/dynamic_debug.h:64:16: warning: format '%d' expects argument of type 'int', but argument 3 has type 'uLong' [-Wformat=]
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
>> include/linux/dynamic_debug.h:64:16: warning: format '%d' expects argument of type 'int', but argument 4 has type 'uLong' [-Wformat=]
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
>> include/linux/dynamic_debug.h:64:16: warning: format '%d' expects argument of type 'int', but argument 3 has type 'uLong' [-Wformat=]
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
>> include/linux/dynamic_debug.h:64:16: warning: format '%d' expects argument of type 'int', but argument 4 has type 'uLong' [-Wformat=]
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
--
   In file included from include/linux/printk.h:257:0,
                    from include/linux/kernel.h:13,
                    from include/asm-generic/bug.h:13,
                    from arch/ia64/include/asm/bug.h:12,
                    from include/linux/bug.h:4,
                    from include/linux/thread_info.h:11,
                    from include/asm-generic/preempt.h:4,
                    from arch/ia64/include/generated/asm/preempt.h:1,
                    from include/linux/preempt.h:18,
                    from include/linux/spinlock.h:50,
                    from include/linux/seqlock.h:35,
                    from include/linux/time.h:5,
                    from include/linux/stat.h:18,
                    from include/linux/module.h:10,
                    from crypto/zlib.c:26:
   crypto/zlib.c: In function 'zlib_compress_update':
>> include/linux/dynamic_debug.h:64:16: warning: format '%u' expects argument of type 'unsigned int', but argument 4 has type 'uLong' [-Wformat=]
     static struct _ddebug  __aligned(8)   \
                   ^
   include/linux/dynamic_debug.h:76:2: note: in expansion of macro 'DEFINE_DYNAMIC_DEBUG_METADATA'
     DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);  \
     ^
   include/linux/printk.h:263:2: note: in expansion of macro 'dynamic_pr_debug'
     dynamic_pr_debug(fmt, ##__VA_ARGS__)
     ^
   crypto/zlib.c:171:2: note: in expansion of macro 'pr_debug'
     pr_debug("avail_in %u, avail_out %u (consumed %u, produced %u)\n",
     ^
>> include/linux/dynamic_debug.h:64:16: warning: format '%u' expects argument of type 'unsigned int', but argument 5 has type 'uLong' [-Wformat=]
     static struct _ddebug  __aligned(8)   \
                   ^
   include/linux/dynamic_debug.h:76:2: note: in expansion of macro 'DEFINE_DYNAMIC_DEBUG_METADATA'
     DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);  \
     ^
   include/linux/printk.h:263:2: note: in expansion of macro 'dynamic_pr_debug'
     dynamic_pr_debug(fmt, ##__VA_ARGS__)
     ^
   crypto/zlib.c:171:2: note: in expansion of macro 'pr_debug'
     pr_debug("avail_in %u, avail_out %u (consumed %u, produced %u)\n",
     ^
>> include/linux/dynamic_debug.h:64:16: warning: format '%u' expects argument of type 'unsigned int', but argument 6 has type 'uLong' [-Wformat=]
     static struct _ddebug  __aligned(8)   \
                   ^
   include/linux/dynamic_debug.h:76:2: note: in expansion of macro 'DEFINE_DYNAMIC_DEBUG_METADATA'
     DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);  \
     ^
   include/linux/printk.h:263:2: note: in expansion of macro 'dynamic_pr_debug'
     dynamic_pr_debug(fmt, ##__VA_ARGS__)
     ^
   crypto/zlib.c:171:2: note: in expansion of macro 'pr_debug'
     pr_debug("avail_in %u, avail_out %u (consumed %u, produced %u)\n",
     ^
   crypto/zlib.c: In function 'zlib_compress_final':
>> include/linux/dynamic_debug.h:64:16: warning: format '%u' expects argument of type 'unsigned int', but argument 4 has type 'uLong' [-Wformat=]
     static struct _ddebug  __aligned(8)   \
                   ^
   include/linux/dynamic_debug.h:76:2: note: in expansion of macro 'DEFINE_DYNAMIC_DEBUG_METADATA'
     DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);  \
     ^
   include/linux/printk.h:263:2: note: in expansion of macro 'dynamic_pr_debug'
     dynamic_pr_debug(fmt, ##__VA_ARGS__)
     ^
   crypto/zlib.c:201:2: note: in expansion of macro 'pr_debug'
     pr_debug("avail_in %u, avail_out %u (consumed %u, produced %u)\n",
     ^
>> include/linux/dynamic_debug.h:64:16: warning: format '%u' expects argument of type 'unsigned int', but argument 5 has type 'uLong' [-Wformat=]
     static struct _ddebug  __aligned(8)   \
                   ^
   include/linux/dynamic_debug.h:76:2: note: in expansion of macro 'DEFINE_DYNAMIC_DEBUG_METADATA'
     DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);  \
     ^
   include/linux/printk.h:263:2: note: in expansion of macro 'dynamic_pr_debug'
     dynamic_pr_debug(fmt, ##__VA_ARGS__)
     ^
   crypto/zlib.c:201:2: note: in expansion of macro 'pr_debug'
     pr_debug("avail_in %u, avail_out %u (consumed %u, produced %u)\n",
     ^
>> include/linux/dynamic_debug.h:64:16: warning: format '%u' expects argument of type 'unsigned int', but argument 6 has type 'uLong' [-Wformat=]
     static struct _ddebug  __aligned(8)   \
                   ^
   include/linux/dynamic_debug.h:76:2: note: in expansion of macro 'DEFINE_DYNAMIC_DEBUG_METADATA'
     DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);  \
     ^
   include/linux/printk.h:263:2: note: in expansion of macro 'dynamic_pr_debug'
     dynamic_pr_debug(fmt, ##__VA_ARGS__)
     ^
   crypto/zlib.c:201:2: note: in expansion of macro 'pr_debug'
     pr_debug("avail_in %u, avail_out %u (consumed %u, produced %u)\n",
     ^
   crypto/zlib.c: In function 'zlib_decompress_update':
>> include/linux/dynamic_debug.h:64:16: warning: format '%u' expects argument of type 'unsigned int', but argument 4 has type 'uLong' [-Wformat=]
     static struct _ddebug  __aligned(8)   \
                   ^
   include/linux/dynamic_debug.h:76:2: note: in expansion of macro 'DEFINE_DYNAMIC_DEBUG_METADATA'
     DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);  \
     ^
   include/linux/printk.h:263:2: note: in expansion of macro 'dynamic_pr_debug'
     dynamic_pr_debug(fmt, ##__VA_ARGS__)
     ^
   crypto/zlib.c:286:2: note: in expansion of macro 'pr_debug'
     pr_debug("avail_in %u, avail_out %u (consumed %u, produced %u)\n",
     ^
>> include/linux/dynamic_debug.h:64:16: warning: format '%u' expects argument of type 'unsigned int', but argument 5 has type 'uLong' [-Wformat=]
     static struct _ddebug  __aligned(8)   \
                   ^
   include/linux/dynamic_debug.h:76:2: note: in expansion of macro 'DEFINE_DYNAMIC_DEBUG_METADATA'
     DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);  \
     ^
   include/linux/printk.h:263:2: note: in expansion of macro 'dynamic_pr_debug'
     dynamic_pr_debug(fmt, ##__VA_ARGS__)
     ^
   crypto/zlib.c:286:2: note: in expansion of macro 'pr_debug'
     pr_debug("avail_in %u, avail_out %u (consumed %u, produced %u)\n",
     ^
>> include/linux/dynamic_debug.h:64:16: warning: format '%u' expects argument of type 'unsigned int', but argument 6 has type 'uLong' [-Wformat=]
     static struct _ddebug  __aligned(8)   \
                   ^
   include/linux/dynamic_debug.h:76:2: note: in expansion of macro 'DEFINE_DYNAMIC_DEBUG_METADATA'
     DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);  \
     ^
   include/linux/printk.h:263:2: note: in expansion of macro 'dynamic_pr_debug'
     dynamic_pr_debug(fmt, ##__VA_ARGS__)
     ^
   crypto/zlib.c:286:2: note: in expansion of macro 'pr_debug'
     pr_debug("avail_in %u, avail_out %u (consumed %u, produced %u)\n",
     ^
   crypto/zlib.c: In function 'zlib_decompress_final':
>> include/linux/dynamic_debug.h:64:16: warning: format '%u' expects argument of type 'unsigned int', but argument 4 has type 'uLong' [-Wformat=]
     static struct _ddebug  __aligned(8)   \
                   ^
   include/linux/dynamic_debug.h:76:2: note: in expansion of macro 'DEFINE_DYNAMIC_DEBUG_METADATA'
     DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);  \
     ^
   include/linux/printk.h:263:2: note: in expansion of macro 'dynamic_pr_debug'
     dynamic_pr_debug(fmt, ##__VA_ARGS__)
     ^
   crypto/zlib.c:334:2: note: in expansion of macro 'pr_debug'
     pr_debug("avail_in %u, avail_out %u (consumed %u, produced %u)\n",
     ^
>> include/linux/dynamic_debug.h:64:16: warning: format '%u' expects argument of type 'unsigned int', but argument 5 has type 'uLong' [-Wformat=]
     static struct _ddebug  __aligned(8)   \
                   ^
   include/linux/dynamic_debug.h:76:2: note: in expansion of macro 'DEFINE_DYNAMIC_DEBUG_METADATA'
     DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);  \
     ^
   include/linux/printk.h:263:2: note: in expansion of macro 'dynamic_pr_debug'
     dynamic_pr_debug(fmt, ##__VA_ARGS__)
     ^
   crypto/zlib.c:334:2: note: in expansion of macro 'pr_debug'
     pr_debug("avail_in %u, avail_out %u (consumed %u, produced %u)\n",
     ^
>> include/linux/dynamic_debug.h:64:16: warning: format '%u' expects argument of type 'unsigned int', but argument 6 has type 'uLong' [-Wformat=]
     static struct _ddebug  __aligned(8)   \
                   ^
   include/linux/dynamic_debug.h:76:2: note: in expansion of macro 'DEFINE_DYNAMIC_DEBUG_METADATA'
     DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);  \
     ^
   include/linux/printk.h:263:2: note: in expansion of macro 'dynamic_pr_debug'
     dynamic_pr_debug(fmt, ##__VA_ARGS__)
     ^
   crypto/zlib.c:334:2: note: in expansion of macro 'pr_debug'
     pr_debug("avail_in %u, avail_out %u (consumed %u, produced %u)\n",
     ^

vim +64 include/linux/dynamic_debug.h

b9075fa9 Joe Perches 2011-10-31  58  extern __printf(3, 4)
b9075fa9 Joe Perches 2011-10-31  59  int __dynamic_netdev_dbg(struct _ddebug *descriptor,
b9075fa9 Joe Perches 2011-10-31  60  			 const struct net_device *dev,
b9075fa9 Joe Perches 2011-10-31  61  			 const char *fmt, ...);
ffa10cb4 Jason Baron 2011-08-11  62  
07613b0b Jason Baron 2011-10-04  63  #define DEFINE_DYNAMIC_DEBUG_METADATA(name, fmt)		\
c0d2af63 Joe Perches 2012-10-18 @64  	static struct _ddebug  __aligned(8)			\
07613b0b Jason Baron 2011-10-04  65  	__attribute__((section("__verbose"))) name = {		\
07613b0b Jason Baron 2011-10-04  66  		.modname = KBUILD_MODNAME,			\
07613b0b Jason Baron 2011-10-04  67  		.function = __func__,				\
07613b0b Jason Baron 2011-10-04  68  		.filename = __FILE__,				\
07613b0b Jason Baron 2011-10-04  69  		.format = (fmt),				\
07613b0b Jason Baron 2011-10-04  70  		.lineno = __LINE__,				\
07613b0b Jason Baron 2011-10-04  71  		.flags =  _DPRINTK_FLAGS_DEFAULT,		\
07613b0b Jason Baron 2011-10-04  72  	}
07613b0b Jason Baron 2011-10-04  73  
07613b0b Jason Baron 2011-10-04  74  #define dynamic_pr_debug(fmt, ...)				\
07613b0b Jason Baron 2011-10-04  75  do {								\
07613b0b Jason Baron 2011-10-04 @76  	DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);		\
87e6f968 Jim Cromie  2011-12-19  77  	if (unlikely(descriptor.flags & _DPRINTK_FLAGS_PRINT))	\
07613b0b Jason Baron 2011-10-04  78  		__dynamic_pr_debug(&descriptor, pr_fmt(fmt),	\
07613b0b Jason Baron 2011-10-04  79  				   ##__VA_ARGS__);		\

:::::: The code at line 64 was first introduced by commit
:::::: c0d2af637863940b1a4fb208224ca7acb905c39f dynamic_debug: Remove unnecessary __used

:::::: TO: Joe Perches <joe@perches.com>
:::::: CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
