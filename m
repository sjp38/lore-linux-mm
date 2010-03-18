Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BEF6E6B0142
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 05:08:01 -0400 (EDT)
Received: by gwj21 with SMTP id 21so12607gwj.14
        for <linux-mm@kvack.org>; Thu, 18 Mar 2010 02:07:58 -0700 (PDT)
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH 07/12] slab: convert cpu notifier to return encapsulate errno value
Date: Thu, 18 Mar 2010 18:05:19 +0900
Message-Id: <1268903124-10237-7-git-send-email-akinobu.mita@gmail.com>
In-Reply-To: <1268903124-10237-1-git-send-email-akinobu.mita@gmail.com>
References: <1268903124-10237-1-git-send-email-akinobu.mita@gmail.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

By the previous modification, the cpu notifier can return encapsulate
errno value. This converts the cpu notifiers for slab.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Matt Mackall <mpm@selenic.com>
Cc: linux-mm@kvack.org
---
 mm/slab.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index a9f325b..d57309e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1324,7 +1324,7 @@ static int __cpuinit cpuup_callback(struct notifier_block *nfb,
 		mutex_unlock(&cache_chain_mutex);
 		break;
 	}
-	return err ? NOTIFY_BAD : NOTIFY_OK;
+	return notifier_from_errno(err);
 }
 
 static struct notifier_block __cpuinitdata cpucache_notifier = {
-- 
1.6.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
