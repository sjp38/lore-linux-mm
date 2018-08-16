Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 814766B04FC
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 19:16:31 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id u13-v6so2728826pfm.8
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 16:16:31 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id l30-v6si635989plg.12.2018.08.16.16.16.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Aug 2018 16:16:29 -0700 (PDT)
Date: Fri, 17 Aug 2018 07:15:42 +0800
From: kbuild test robot <lkp@intel.com>
Subject: [rgushchin:vmap_stack.2 372/400]
 /usr/lib/gcc/x86_64-linux-gnu/7/include/stdarg.h:40:1: error: expected '=',
 ',', ';', 'asm' or '__attribute__' before 'typedef'
Message-ID: <201808170737.auD7ZTu3%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="RnlQjJ0d97Da+TV1"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Roman Gushchin <guro@fb.com>, Linux Memory Management List <linux-mm@kvack.org>, Manfred Spraul <manfred@colorfullife.com>, Johannes Weiner <hannes@cmpxchg.org>


--RnlQjJ0d97Da+TV1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://github.com/rgushchin/linux.git vmap_stack.2
head:   b61822b6662d7f8ad726217bb05c1acc417c1a6e
commit: 2e06a5b89f867e96144d8a9fea1b9d9644b87a8b [372/400] linux-next-git-rejects
config: i386-tinyconfig (attached as .config)
compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
reproduce:
        git checkout 2e06a5b89f867e96144d8a9fea1b9d9644b87a8b
        # save the attached .config to linux build tree
        make ARCH=i386 

All errors (new ones prefixed by >>):

   In file included from include/linux/kernel.h:6:0,
                    from kernel/printk/printk.c:19:
>> /usr/lib/gcc/x86_64-linux-gnu/7/include/stdarg.h:40:1: error: expected '=', ',', ';', 'asm' or '__attribute__' before 'typedef'
    typedef __builtin_va_list __gnuc_va_list;
    ^~~~~~~
   In file included from include/linux/kernel.h:6:0,
                    from kernel/printk/printk.c:19:
>> /usr/lib/gcc/x86_64-linux-gnu/7/include/stdarg.h:99:9: error: unknown type name '__gnuc_va_list'
    typedef __gnuc_va_list va_list;
            ^~~~~~~~~~~~~~

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--RnlQjJ0d97Da+TV1
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
dIQgEALSf7/CpL+cWgAA

--RnlQjJ0d97Da+TV1--
