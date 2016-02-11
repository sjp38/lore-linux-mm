Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id A72C96B0009
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 23:05:13 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id e127so22807684pfe.3
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 20:05:13 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id i89si9580700pfj.228.2016.02.10.20.05.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Feb 2016 20:05:12 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id w128so1335825pfb.2
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 20:05:12 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH v2 0/5] follow-up "Optimize CONFIG_DEBUG_PAGEALLOC"
Date: Thu, 11 Feb 2016 13:04:56 +0900
Message-Id: <1455163501-9341-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Takashi Iwai <tiwai@suse.com>, Chris Metcalf <cmetcalf@ezchip.com>, Christoph Lameter <cl@linux.com>, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

v2) Changes
o fix powerpc build failure (basic build test done)
o export symbol for module build
o change comment and clean up code

As CONFIG_DEBUG_PAGEALLOC can be enabled/disabled via kernel
parameters we can optimize some cases by checking the enablement
state.

This is follow-up work for Christian's Optimize CONFIG_DEBUG_PAGEALLOC.

https://lkml.org/lkml/2016/1/27/194

I can't test patches for sound, power and tile,
so please review them, maintainers. :)

Remaining work is to make sparc to be aware of this but it looks
not easy for me so I skip that in this series.

It would be the best that these paches are routed through Andrew's tree,
because there is a dependency to MM.

Andrew, there is mis-spelled word (compliled -> compiled) in commit
description so I re-send all. Except powerpc one, others are basically
same with the patches on your tree.

Thanks.

Joonsoo Kim (5):
  mm/vmalloc: query dynamic DEBUG_PAGEALLOC setting
  mm/slub: query dynamic DEBUG_PAGEALLOC setting
  sound: query dynamic DEBUG_PAGEALLOC setting
  powerpc: query dynamic DEBUG_PAGEALLOC setting
  tile: query dynamic DEBUG_PAGEALLOC setting

 arch/powerpc/kernel/traps.c     |  5 ++---
 arch/powerpc/mm/hash_utils_64.c | 36 ++++++++++++++++++++----------------
 arch/powerpc/mm/init_32.c       |  8 ++++----
 arch/tile/mm/init.c             | 11 +++++++----
 mm/page_alloc.c                 |  1 +
 mm/slub.c                       |  7 +++----
 mm/vmalloc.c                    | 25 ++++++++++++-------------
 sound/drivers/pcsp/pcsp.c       |  9 +++++----
 8 files changed, 54 insertions(+), 48 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
