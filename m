Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4805E6B0253
	for <linux-mm@kvack.org>; Sat, 23 Dec 2017 07:59:49 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j26so21487837pff.8
        for <linux-mm@kvack.org>; Sat, 23 Dec 2017 04:59:49 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id w24si18054625plq.159.2017.12.23.04.59.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Dec 2017 04:59:48 -0800 (PST)
Date: Sat, 23 Dec 2017 20:59:43 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 157/234] mm/kasan/kasan.c:781:1: sparse: symbol
 '__asan_set_shadow_00' was not declared. Should it be static?
Message-ID: <201712232039.vNkPEjbE%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Greg Hackmann <ghackmann@google.com>, Paul Lawrence <paullawrence@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   a4f20e3ed193cd4b2f742ce37f88112c7441146f
commit: 1749be8333b77defc7cd0888acfaa0b87d2f53b9 [157/234] kasan: add functions for unpoisoning stack variables
reproduce:
        # apt-get install sparse
        git checkout 1749be8333b77defc7cd0888acfaa0b87d2f53b9
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)


Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
