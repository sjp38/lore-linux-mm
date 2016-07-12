Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 47FF76B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 14:12:57 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o80so18871128wme.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 11:12:57 -0700 (PDT)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id 20si22118330wmi.94.2016.07.12.11.12.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 11:12:56 -0700 (PDT)
Received: by mail-wm0-x231.google.com with SMTP id r190so5097466wmr.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 11:12:56 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v7 0/2] mm, kasan: stackdepot and quarantine for SLUB
Date: Tue, 12 Jul 2016 20:12:43 +0200
Message-Id: <1468347165-41906-1-git-send-email-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, aryabinin@virtuozzo.com, kuthonuzo.luruo@hpe.com
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch set enables stackdepot and quarantine for SLUB allocator and
fixes a problem with incorrect calculating the offset of the nearest
object in the presence of SLUB red zones.

Alexander Potapenko (2):
  mm, kasan: account for object redzone in SLUB's nearest_obj()
  mm, kasan: switch SLUB to stackdepot, enable memory quarantine for
    SLUB

 include/linux/kasan.h    |  2 ++
 include/linux/slab_def.h |  3 ++-
 include/linux/slub_def.h | 14 ++++++++---
 lib/Kconfig.kasan        |  4 +--
 mm/kasan/Makefile        |  3 +--
 mm/kasan/kasan.c         | 64 +++++++++++++++++++++++++++---------------------
 mm/kasan/kasan.h         |  3 +--
 mm/kasan/report.c        |  8 +++---
 mm/slab.h                |  2 ++
 mm/slub.c                | 59 +++++++++++++++++++++++++++++++++-----------
 10 files changed, 104 insertions(+), 58 deletions(-)

-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
