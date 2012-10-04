Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 964BC6B00F7
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 06:24:14 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so428226pad.14
        for <linux-mm@kvack.org>; Thu, 04 Oct 2012 03:24:13 -0700 (PDT)
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 1/3] vmevent: Remove unused code
Date: Thu,  4 Oct 2012 03:21:16 -0700
Message-Id: <1349346078-24874-1-git-send-email-anton.vorontsov@linaro.org>
In-Reply-To: <20121004102013.GA23284@lizard>
References: <20121004102013.GA23284@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org

struct vmevent_watch_event and a few definitions are not used anywhere, so
let's remove them.

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 mm/vmevent.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/mm/vmevent.c b/mm/vmevent.c
index a7f1042..39ef786 100644
--- a/mm/vmevent.c
+++ b/mm/vmevent.c
@@ -11,16 +11,6 @@
 #include <linux/swap.h>
 #undef nr_swap_pages /* This is defined to a constant for SWAP=n case */
 
-#define VMEVENT_MAX_FREE_THRESHOD	100
-
-#define VMEVENT_MAX_EATTR_ATTRS	64
-
-struct vmevent_watch_event {
-	u64				nr_avail_pages;
-	u64				nr_free_pages;
-	u64				nr_swap_pages;
-};
-
 struct vmevent_watch {
 	struct vmevent_config		config;
 
-- 
1.7.12.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
