Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A7A4A6B025F
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 18:49:31 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 76so883503pfr.3
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 15:49:31 -0700 (PDT)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTPS id a6si2553231pff.606.2017.10.25.15.49.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Oct 2017 15:49:30 -0700 (PDT)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH 0/2 -mmotm] oom: show single slab cache in oom whose size > 10% of total system memory
Date: Thu, 26 Oct 2017 06:48:58 +0800
Message-Id: <1508971740-118317-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org
Cc: Yang Shi <yang.s@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


Per the suggestion from David [1], this implementation dumps single slab cache if its size is over 10% of total system memory. In current implementation, the ration is fixed as 10%.

To get the size of total system memory patch #1 extract the common code from show_mem() so that the code can be used by checking the ratio.

The patchset is based on the mmotm tree.

[1] https://marc.info/?l=linux-mm&m=150819933626604&w=2

Yang Shi (2):
      mm: extract common code for calculating total memory size
      mm: oom: dump single excessive slab cache when oom

 include/linux/mm.h | 25 +++++++++++++++++++++++++
 lib/show_mem.c     | 20 +-------------------
 mm/oom_kill.c      | 22 +---------------------
 mm/slab.h          |  4 ++--
 mm/slab_common.c   | 21 ++++++++++++++++-----
 5 files changed, 45 insertions(+), 47 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
