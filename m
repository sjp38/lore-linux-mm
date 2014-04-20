Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 80BDA6B0035
	for <linux-mm@kvack.org>; Sat, 19 Apr 2014 22:26:43 -0400 (EDT)
Received: by mail-ob0-f180.google.com with SMTP id wm4so3099809obc.39
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 19:26:43 -0700 (PDT)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id kk10si26077560obb.14.2014.04.19.19.26.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 19 Apr 2014 19:26:42 -0700 (PDT)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 0/6] mm: audit find_vma() callers
Date: Sat, 19 Apr 2014 19:26:25 -0700
Message-Id: <1397960791-16320-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: zeus@gnu.org, aswin@hp.com, davidlohr@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Ensure find_vma() callers do so with the mmap_sem held. 

I'm sure there are a few more places left to fix, but 
this is a pretty good start. Following the call chain,
some users become all tangled up, but I believe these
fixes are correct. Furthermore, the bulk of the callers
of find_vma are in a lot of functions where it is well
known that the mmap_sem is taken way before, such as
get_unmapped_area() family.

Please note that none of the patches are tested.

Thanks!

  blackfin/ptrace: call find_vma with the mmap_sem held
  m68k: call find_vma with the mmap_sem held in sys_cacheflush()
  mips: call find_vma with the mmap_sem held
  arc: call find_vma with the mmap_sem held
  drivers/misc/sgi-gru/grufault.c: call find_vma with the mmap_sem held
  drm/exynos: call find_vma with the mmap_sem held

 arch/arc/kernel/troubleshoot.c          |  7 ++++---
 arch/blackfin/kernel/ptrace.c           |  8 ++++++--
 arch/m68k/kernel/sys_m68k.c             | 18 ++++++++++++------
 arch/mips/kernel/traps.c                |  2 ++
 arch/mips/mm/c-octeon.c                 |  2 ++
 drivers/gpu/drm/exynos/exynos_drm_g2d.c |  6 ++++++
 drivers/misc/sgi-gru/grufault.c         | 13 +++++++++----
 7 files changed, 41 insertions(+), 15 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
