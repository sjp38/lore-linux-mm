Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0846B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 21:40:36 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2F5DE3EE0BD
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:40:34 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D81B45DF50
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:40:34 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E63CA45DF4A
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:40:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D33BDE18002
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:40:33 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B839E08003
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:40:33 +0900 (JST)
Message-ID: <4DDB0C89.9020803@jp.fujitsu.com>
Date: Tue, 24 May 2011 10:40:25 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: + vmscan-change-shrinker-api-by-passing-shrink_control-struct-fix-3.patch
 added to -mm tree
References: <201105201859.p4KIxGrK024683@imap1.linux-foundation.org>
In-Reply-To: <201105201859.p4KIxGrK024683@imap1.linux-foundation.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, dave@linux.vnet.ibm.com, hannes@cmpxchg.org, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, minchan.kim@gmail.com, riel@redhat.com, xemul@openvz.org, yinghan@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2011/05/21 3:59), akpm@linux-foundation.org wrote:
> The patch titled
>       vmscan: fix up new shrinker API
> has been added to the -mm tree.  Its filename is
>       vmscan-change-shrinker-api-by-passing-shrink_control-struct-fix-3.patch
> 
> Before you just go and hit "reply", please:
>     a) Consider who else should be cc'ed
>     b) Prefer to cc a suitable mailing list as well
>     c) Ideally: find the original patch on the mailing list and do a
>        reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> See http://userweb.kernel.org/~akpm/stuff/added-to-mm.txt to find
> out what to do about this
> 
> The current -mm tree may be found at http://userweb.kernel.org/~akpm/mmotm/
> 
> ------------------------------------------------------
> Subject: vmscan: fix up new shrinker API
> From: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> 
> Current new shrinker API submission has some easy mistake. Fix it up.
> 
> - remove nr_scanned field from shrink_control.
>     we don't have to expose vmscan internal to shrinkers.
> - rename nr_slab_to_reclaim to nr_to_scan.
>     to_reclaim is very wrong name. shrinker API allow shrinker
>     don't reclaim an slab object if they were recently accessed.
> - typo: least-recently-us
> 
> This patch also make do_shrinker_shrink() helper function. It
> increase code readability a bit.

Oops. I'm sorry. This patch forgot one correction. please apply
following incremental patch.




---
 net/sunrpc/auth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 287dd25..cd6e4aa 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -330,7 +330,7 @@ rpcauth_cache_shrinker(struct shrinker *shrink, struct shrink_control *sc)
 {
 	LIST_HEAD(free);
 	int res;
-	int nr_to_scan = sc->nr_slab_to_reclaim;
+	int nr_to_scan = sc->nr_to_scan;
 	gfp_t gfp_mask = sc->gfp_mask;

 	if ((gfp_mask & GFP_KERNEL) != GFP_KERNEL)
-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
