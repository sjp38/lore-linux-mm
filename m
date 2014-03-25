Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1316B003B
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 15:35:14 -0400 (EDT)
Received: by mail-ig0-f173.google.com with SMTP id t19so11520990igi.0
        for <linux-mm@kvack.org>; Tue, 25 Mar 2014 12:35:14 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0251.hostedemail.com. [216.40.44.251])
        by mx.google.com with ESMTP id bs7si20557235icc.127.2014.03.25.12.35.13
        for <linux-mm@kvack.org>;
        Tue, 25 Mar 2014 12:35:13 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/5] Convert last few uses of __FUNCTION__ to __func__
Date: Tue, 25 Mar 2014 12:35:02 -0700
Message-Id: <cover.1395775901.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org, drbd-user@lists.linbit.com, xen-devel@lists.xenproject.org, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org

Outside of staging, there aren't any more uses of __FUNCTION__ now...

Joe Perches (5):
  powerpc: Convert last uses of __FUNCTION__ to __func__
  x86: Convert last uses of __FUNCTION__ to __func__
  block: Convert last uses of __FUNCTION__ to __func__
  i915: Convert last uses of __FUNCTION__ to __func__
  slab: Convert last uses of __FUNCTION__ to __func__

 arch/powerpc/platforms/pseries/nvram.c       | 11 +++++------
 arch/x86/kernel/hpet.c                       |  2 +-
 arch/x86/kernel/rtc.c                        |  4 ++--
 arch/x86/platform/intel-mid/intel_mid_vrtc.c |  2 +-
 drivers/block/drbd/drbd_int.h                |  8 ++++----
 drivers/block/xen-blkfront.c                 |  4 ++--
 drivers/gpu/drm/i915/dvo_ns2501.c            | 15 ++++++---------
 mm/slab.h                                    |  2 +-
 8 files changed, 22 insertions(+), 26 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
