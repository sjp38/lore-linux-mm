Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id B0CC16B0035
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 22:39:32 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id rr13so2557590pbb.36
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 19:39:32 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id cz1si7832334pbc.239.2014.06.19.19.39.31
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 19:39:31 -0700 (PDT)
Date: Fri, 20 Jun 2014 10:30:30 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 188/230] fs/jffs2/compr_zlib.c:98: warning: format
 '%d' expects type 'int', but argument 2 has type 'uLong'
Message-ID: <53a39cc6.yuRVo8kti3If2LnE%fengguang.wu@intel.com>
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
config: make ARCH=avr32 atngw100_defconfig

All warnings:

   fs/jffs2/compr_zlib.c: In function 'jffs2_zlib_compress':
   fs/jffs2/compr_zlib.c:97: warning: comparison of distinct pointer types lacks a cast
>> fs/jffs2/compr_zlib.c:98: warning: format '%d' expects type 'int', but argument 2 has type 'uLong'
>> fs/jffs2/compr_zlib.c:98: warning: format '%d' expects type 'int', but argument 3 has type 'uLong'
>> fs/jffs2/compr_zlib.c:101: warning: format '%d' expects type 'int', but argument 2 has type 'uLong'
>> fs/jffs2/compr_zlib.c:101: warning: format '%d' expects type 'int', but argument 3 has type 'uLong'

vim +98 fs/jffs2/compr_zlib.c

182ec4ee Thomas Gleixner 2005-11-07   91  
^1da177e Linus Torvalds  2005-04-16   92  	def_strm.next_out = cpage_out;
^1da177e Linus Torvalds  2005-04-16   93  	def_strm.total_out = 0;
^1da177e Linus Torvalds  2005-04-16   94  
^1da177e Linus Torvalds  2005-04-16   95  	while (def_strm.total_out < *dstlen - STREAM_END_SPACE && def_strm.total_in < *sourcelen) {
^1da177e Linus Torvalds  2005-04-16   96  		def_strm.avail_out = *dstlen - (def_strm.total_out + STREAM_END_SPACE);
^1da177e Linus Torvalds  2005-04-16  @97  		def_strm.avail_in = min((unsigned)(*sourcelen-def_strm.total_in), def_strm.avail_out);
9c261b33 Joe Perches     2012-02-15  @98  		jffs2_dbg(1, "calling deflate with avail_in %d, avail_out %d\n",
9c261b33 Joe Perches     2012-02-15   99  			  def_strm.avail_in, def_strm.avail_out);
^1da177e Linus Torvalds  2005-04-16  100  		ret = zlib_deflate(&def_strm, Z_PARTIAL_FLUSH);
9c261b33 Joe Perches     2012-02-15 @101  		jffs2_dbg(1, "deflate returned with avail_in %d, avail_out %d, total_in %ld, total_out %ld\n",
9c261b33 Joe Perches     2012-02-15  102  			  def_strm.avail_in, def_strm.avail_out,
9c261b33 Joe Perches     2012-02-15  103  			  def_strm.total_in, def_strm.total_out);
^1da177e Linus Torvalds  2005-04-16  104  		if (ret != Z_OK) {

:::::: The code at line 98 was first introduced by commit
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
