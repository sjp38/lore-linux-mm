Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6696D6B01B7
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 02:59:11 -0400 (EDT)
Received: by fxm15 with SMTP id 15so2491112fxm.14
        for <linux-mm@kvack.org>; Mon, 21 Jun 2010 23:59:09 -0700 (PDT)
From: Sankar P <sankar.curiosity@gmail.com>
Subject: [PATCH] mm: kmemleak: Change kmemleak default buffer size
Date: Tue, 22 Jun 2010 12:28:29 +0530
Message-Id: <1277189909-16376-1-git-send-email-sankar.curiosity@gmail.com>
In-Reply-To: <AANLkTimb7rP0rS0OU8nan5uNEhHx_kEYL99ImZ3c8o0D@mail.gmail.com>
References: <AANLkTimb7rP0rS0OU8nan5uNEhHx_kEYL99ImZ3c8o0D@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: lethal@linux-sh.org, linux-sh@vger.kernel.org, lrodriguez@atheros.com, penberg@cs.helsinki.fi, catalin.marinas@arm.com, rnagarajan@novell.com, teheo@novell.com, linux-mm@kvack.org, Sankar P <sankar.curiosity@gmail.com>
List-ID: <linux-mm.kvack.org>

If we try to find the memory leaks in kernel that is
compiled with 'make defconfig', the default buffer size
seem to be inadequate. Change the buffer size from
400 to 1000, which is sufficient in most cases.

Signed-off-by: Sankar P <sankar.curiosity@gmail.com>
---
 arch/sh/configs/sh7785lcr_32bit_defconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/sh/configs/sh7785lcr_32bit_defconfig b/arch/sh/configs/sh7785lcr_32bit_defconfig
index 71f39c7..b02e5ae 100644
--- a/arch/sh/configs/sh7785lcr_32bit_defconfig
+++ b/arch/sh/configs/sh7785lcr_32bit_defconfig
@@ -1710,7 +1710,7 @@ CONFIG_SCHEDSTATS=y
 # CONFIG_DEBUG_OBJECTS is not set
 # CONFIG_DEBUG_SLAB is not set
 CONFIG_DEBUG_KMEMLEAK=y
-CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE=400
+CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE=1000
 # CONFIG_DEBUG_KMEMLEAK_TEST is not set
 CONFIG_DEBUG_PREEMPT=y
 # CONFIG_DEBUG_RT_MUTEXES is not set
-- 
1.6.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
