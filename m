Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id A194A6B0092
	for <linux-mm@kvack.org>; Wed, 23 May 2012 03:29:49 -0400 (EDT)
Received: from euspt2 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M4G00E63SPR8N@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 23 May 2012 08:27:27 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M4G00FGVSTLCC@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 23 May 2012 08:29:45 +0100 (BST)
Date: Wed, 23 May 2012 09:27:58 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH 1/2] vmevent: don't leak unitialized data to userspace
Message-id: <201205230927.58802.b.zolnierkie@samsung.com>
MIME-version: 1.0
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7BIT
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, linux-mm@kvack.org

From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] vmevent: don't leak unitialized data to userspace

Remember to initialize all attrs[nr] fields in vmevent_setup_watch().

Cc: Anton Vorontsov <anton.vorontsov@linaro.org>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 mm/vmevent.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: b/mm/vmevent.c
===================================================================
--- a/mm/vmevent.c	2012-05-22 17:51:13.195231958 +0200
+++ b/mm/vmevent.c	2012-05-22 17:51:40.991231956 +0200
@@ -350,7 +350,10 @@
 
 		attrs = new;
 
-		attrs[nr++].type = attr->type;
+		attrs[nr].type = attr->type;
+		attrs[nr].value = 0;
+		attrs[nr].state = 0;
+		nr++;
 	}
 
 	watch->sample_attrs	= attrs;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
