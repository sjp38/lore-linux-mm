Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAQ2Ov6x017510
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 26 Nov 2008 11:24:58 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9FBE145DD7F
	for <linux-mm@kvack.org>; Wed, 26 Nov 2008 11:24:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A56045DD78
	for <linux-mm@kvack.org>; Wed, 26 Nov 2008 11:24:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 51D9F1DB8041
	for <linux-mm@kvack.org>; Wed, 26 Nov 2008 11:24:54 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A8F7B1DB8038
	for <linux-mm@kvack.org>; Wed, 26 Nov 2008 11:24:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: bail out of page reclaim after swap_cluster_max pages
In-Reply-To: <20081124145057.4211bd46@bree.surriel.com>
References: <20081124145057.4211bd46@bree.surriel.com>
Message-Id: <20081126112329.3CB2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 26 Nov 2008 11:24:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> +		/*
> +		 * On large memory systems, scan >> priority can become
> +		 * really large. This is fine for the starting priority;
> +		 * we want to put equal scanning pressure on each zone.
> +		 * However, if the VM has a harder time of freeing pages,
> +		 * with multiple processes reclaiming pages, the total
> +		 * freeing target can get unreasonably large.
> +		 */
> +		if (sc->nr_reclaimed > sc->swap_cluster_max &&
> +			sc->priority < DEF_PRIORITY && !current_is_kswapd())
> +			break;

typo.
this patch can't compile.

---
 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1469,7 +1469,7 @@ static void shrink_zone(int priority, st
 		 * freeing target can get unreasonably large.
 		 */
 		if (sc->nr_reclaimed > sc->swap_cluster_max &&
-		    sc->priority < DEF_PRIORITY && !current_is_kswapd())
+		    priority < DEF_PRIORITY && !current_is_kswapd())
 			break;
 	}
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
