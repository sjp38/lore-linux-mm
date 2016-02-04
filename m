Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 461DC4403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 00:57:28 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id w123so33238013pfb.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 21:57:28 -0800 (PST)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id pz7si14270322pab.216.2016.02.03.21.57.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 21:57:27 -0800 (PST)
Received: by mail-pf0-x22d.google.com with SMTP id o185so33075248pfb.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 21:57:27 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 0/5] follow-up "Optimize CONFIG_DEBUG_PAGEALLOC"
Date: Thu,  4 Feb 2016 14:56:21 +0900
Message-Id: <1454565386-10489-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Takashi Iwai <tiwai@suse.com>, Chris Metcalf <cmetcalf@ezchip.com>, Christoph Lameter <cl@linux.com>, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

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

Thanks.

Joonsoo Kim (5):
  mm/vmalloc: query dynamic DEBUG_PAGEALLOC setting
  mm/slub: query dynamic DEBUG_PAGEALLOC setting
  sound: query dynamic DEBUG_PAGEALLOC setting
  powerpc: query dynamic DEBUG_PAGEALLOC setting
  tile: query dynamic DEBUG_PAGEALLOC setting

 arch/powerpc/kernel/traps.c     |  5 ++---
 arch/powerpc/mm/hash_utils_64.c | 40 ++++++++++++++++++++--------------------
 arch/powerpc/mm/init_32.c       |  8 ++++----
 arch/tile/mm/init.c             | 11 +++++++----
 mm/slub.c                       | 11 ++++++-----
 mm/vmalloc.c                    |  8 ++++----
 sound/drivers/pcsp/pcsp.c       |  9 +++++----
 7 files changed, 48 insertions(+), 44 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
