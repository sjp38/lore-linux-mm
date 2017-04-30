Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1C6436B0038
	for <linux-mm@kvack.org>; Sun, 30 Apr 2017 07:32:01 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s62so1567588pgc.2
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 04:32:01 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id i61si11132783plb.196.2017.04.30.04.32.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Apr 2017 04:32:00 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id v1so12199764pgv.3
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 04:32:00 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 0/3] try to save some memory for kmem_cache in some cases
Date: Sun, 30 Apr 2017 19:31:49 +0800
Message-Id: <20170430113152.6590-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

kmem_cache is a frequently used data in kernel. During the code reading, I
found maybe we could save some space in some cases.

1. On 64bit arch, type int will occupy a word if it doesn't sit well.
2. cpu_slab->partial is just used when CONFIG_SLUB_CPU_PARTIAL is set
3. cpu_partial is just used when CONFIG_SLUB_CPU_PARTIAL is set, while just
save some space on 32bit arch.

Wei Yang (3):
  mm/slub: pack red_left_pad with another int to save a word
  mm/slub: wrap cpu_slab->partial in CONFIG_SLUB_CPU_PARTIAL
  mm/slub: wrap kmem_cache->cpu_partial in config
    CONFIG_SLUB_CPU_PARTIAL

 include/linux/slub_def.h |  6 +++-
 mm/slub.c                | 88 ++++++++++++++++++++++++++++++++----------------
 2 files changed, 64 insertions(+), 30 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
