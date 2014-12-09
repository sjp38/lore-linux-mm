Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9BD996B0070
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 14:39:40 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id w10so1164127pde.39
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 11:39:40 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id yl1si3133539pbb.243.2014.12.09.11.39.37
        for <linux-mm@kvack.org>;
        Tue, 09 Dec 2014 11:39:38 -0800 (PST)
Date: Wed, 10 Dec 2014 03:38:17 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [tj-misc:review-wq-dump 1/15] lib/bitmap.c:574:6: sparse: symbol
 'bitmap_print_list' was not declared. Should it be static?
Message-ID: <201412100354.d6xN5OCa%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Sudeep Holla <sudeep.holla@arm.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git review-wq-dump
head:   c48dd4e1a0d7225c97d7294958dd8ba6be82fde9
commit: 069dcda94642807dc31bf52895bd409512531249 [1/15] bitmap: restructure bitmap_sn[list]printf()
reproduce:
  # apt-get install sparse
  git checkout 069dcda94642807dc31bf52895bd409512531249
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> lib/bitmap.c:574:6: sparse: symbol 'bitmap_print_list' was not declared. Should it be static?
   lib/bitmap.c:1250:30: sparse: incorrect type in assignment (different base types)
   lib/bitmap.c:1250:30:    expected unsigned long [unsigned] [long] <noident>
   lib/bitmap.c:1250:30:    got restricted __le64 [usertype] <noident>
   lib/bitmap.c:1252:30: sparse: incorrect type in assignment (different base types)
   lib/bitmap.c:1252:30:    expected unsigned long [unsigned] [long] <noident>
   lib/bitmap.c:1252:30:    got restricted __le32 [usertype] <noident>

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
