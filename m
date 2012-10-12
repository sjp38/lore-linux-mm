Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id D5D2A6B0044
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 06:22:23 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so2997951pad.14
        for <linux-mm@kvack.org>; Fri, 12 Oct 2012 03:22:23 -0700 (PDT)
Date: Fri, 12 Oct 2012 03:19:32 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH] mm: vmevent: Report number of used swap pages, not total
 amount of swap
Message-ID: <20121012101932.GA30179@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

I think the actual intent was to report the number of used swap pages, not
just total swap size.

This patch fixes the issue.

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 mm/vmevent.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmevent.c b/mm/vmevent.c
index 1c2e72e..a059bed 100644
--- a/mm/vmevent.c
+++ b/mm/vmevent.c
@@ -46,7 +46,7 @@ static u64 vmevent_attr_swap_pages(struct vmevent_watch *watch,
 
 	si_swapinfo(&si);
 
-	return si.totalswap;
+	return si.totalswap - si.freeswap;
 #else
 	return 0;
 #endif
-- 
1.7.12.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
