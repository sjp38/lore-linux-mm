Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3F86E6B004D
	for <linux-mm@kvack.org>; Sun,  9 Aug 2009 05:37:15 -0400 (EDT)
From: =?utf-8?q?Uwe=20Kleine-K=C3=B6nig?= <u.kleine-koenig@pengutronix.de>
Subject: [PATCH RT 7/6] include linux/interrupt.h in mm/bounce.c
Date: Sun,  9 Aug 2009 11:36:38 +0200
Message-Id: <1249810600-21946-1-git-send-email-u.kleine-koenig@pengutronix.de>
In-Reply-To: <20090807203939.GA19374@pengutronix.de>
References: <20090807203939.GA19374@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, rt-users <linux-rt-users@vger.kernel.org>, Jens Axboe <jens.axboe@oracle.com>, Ingo Molnar <mingo@elte.hu>, Li Zefan <lizf@cn.fujitsu.com>, linux-mm@kvack.org, linux-arm-kernel@lists.arm.linux.org.uk
List-ID: <linux-mm.kvack.org>

This fixes a a build failure for 2.6.31-rc4-rt1 (ARCH=arm,
mv78xx0_defconfig and others):

mm/bounce.c: In function 'bounce_copy_vec':
mm/bounce.c:52: error: implicit declaration of function 'local_irq_save_nort'
mm/bounce.c:56: error: implicit declaration of function 'local_irq_restore_nort'

Signed-off-by: Uwe Kleine-KA?nig <u.kleine-koenig@pengutronix.de>
Cc: Jens Axboe <jens.axboe@oracle.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Li Zefan <lizf@cn.fujitsu.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-arm-kernel@lists.arm.linux.org.uk
---
 mm/bounce.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/bounce.c b/mm/bounce.c
index 2fd099c..4a91eed 100644
--- a/mm/bounce.c
+++ b/mm/bounce.c
@@ -13,6 +13,7 @@
 #include <linux/init.h>
 #include <linux/hash.h>
 #include <linux/highmem.h>
+#include <linux/interrupt.h>
 #include <asm/tlbflush.h>
 
 #include <trace/events/block.h>
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
