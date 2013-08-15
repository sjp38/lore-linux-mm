Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 5AB456B0032
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 06:02:54 -0400 (EDT)
Received: by mail-oa0-f43.google.com with SMTP id i10so574493oag.2
        for <linux-mm@kvack.org>; Thu, 15 Aug 2013 03:02:53 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 15 Aug 2013 18:02:53 +0800
Message-ID: <CAJd=RBBF2h_tRpbTV6OkxQOfkvKt=ebn_PbE8+r7JxAuaFZxFQ@mail.gmail.com>
Subject: kswapd skips compaction if reclaim order drops to zero?
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

If the allocation order is not high, direct compaction does nothing.
Can we skip compaction here if order drops to zero?

--- a/mm/vmscan.c Thu Aug 15 17:47:26 2013
+++ b/mm/vmscan.c Thu Aug 15 17:48:58 2013
@@ -3034,7 +3034,7 @@ static unsigned long balance_pgdat(pg_da
  * Compact if necessary and kswapd is reclaiming at least the
  * high watermark number of pages as requsted
  */
- if (pgdat_needs_compaction && sc.nr_reclaimed > nr_attempted)
+ if (pgdat_needs_compaction && sc.nr_reclaimed > nr_attempted && order)
  compact_pgdat(pgdat, order);

  /*
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
