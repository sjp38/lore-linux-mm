Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 78A716B0253
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 11:31:26 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p85so18911895lfg.3
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 08:31:26 -0700 (PDT)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id c3si13634259wjv.231.2016.07.28.08.31.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 08:31:24 -0700 (PDT)
Received: by mail-wm0-x22d.google.com with SMTP id q128so256742385wma.1
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 08:31:24 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v8 0/3] mm, kasan: stackdepot and quarantine for SLUB
Date: Thu, 28 Jul 2016 17:31:16 +0200
Message-Id: <1469719879-11761-1-git-send-email-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dvyukov@google.com, kcc@google.com, aryabinin@virtuozzo.com, adech.fo@gmail.com, cl@linux.com, akpm@linux-foundation.org, rostedt@goodmis.org, js1304@gmail.com, iamjoonsoo.kim@lge.com, kuthonuzo.luruo@hpe.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch set enables stackdepot and quarantine for SLUB allocator and
fixes a problem with incorrect calculating the offset of the nearest
object in the presence of SLUB red zones.

Alexander Potapenko (3):
  mm, kasan: account for object redzone in SLUB's nearest_obj()
  mm, kasan: align free_meta_offset on sizeof(void*)
  mm, kasan: switch SLUB to stackdepot, enable memory quarantine for
    SLUB
---
v8: - added "mm, kasan: align free_meta_offset on sizeof(void*)"
    - incorporated fixes by Andrey Ryabinin
---

 include/linux/kasan.h    |  2 ++
 include/linux/slab_def.h |  3 ++-
 include/linux/slub_def.h | 14 ++++++++---
 lib/Kconfig.kasan        |  4 +--
 mm/kasan/Makefile        |  3 +--
 mm/kasan/kasan.c         | 63 ++++++++++++++++++++++++------------------------
 mm/kasan/kasan.h         |  3 +--
 mm/kasan/report.c        |  8 +++---
 mm/slab.h                |  2 ++
 mm/slub.c                | 59 ++++++++++++++++++++++++++++++++++-----------
 10 files changed, 100 insertions(+), 61 deletions(-)

-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
