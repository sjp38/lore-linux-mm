Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 93F566B02C4
	for <linux-mm@kvack.org>; Tue,  2 May 2017 10:45:39 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b17so85154871pfd.1
        for <linux-mm@kvack.org>; Tue, 02 May 2017 07:45:39 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id l10si4105922plk.133.2017.05.02.07.45.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 07:45:38 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id t7so22774920pgt.1
        for <linux-mm@kvack.org>; Tue, 02 May 2017 07:45:38 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH V2 0/3] try to save some memory for kmem_cache in some cases
Date: Tue,  2 May 2017 22:45:30 +0800
Message-Id: <20170502144533.10729-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

kmem_cache is a frequently used data in kernel. During the code reading, I
found maybe we could save some space in some cases.

1. On 64bit arch, type int will occupy a word if it doesn't sit well.
2. cpu_slab->partial is just used when CONFIG_SLUB_CPU_PARTIAL is set
3. cpu_partial is just used when CONFIG_SLUB_CPU_PARTIAL is set, while just
save some space on 32bit arch.

v2:
   define some macro to make the code more elegant

Wei Yang (3):
  mm/slub: pack red_left_pad with another int to save a word
  mm/slub: wrap cpu_slab->partial in CONFIG_SLUB_CPU_PARTIAL
  mm/slub: wrap kmem_cache->cpu_partial in config
    CONFIG_SLUB_CPU_PARTIAL

 include/linux/slub_def.h | 34 ++++++++++++++++++-
 mm/slub.c                | 85 ++++++++++++++++++++++++++----------------------
 2 files changed, 80 insertions(+), 39 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
