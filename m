Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 745606B005D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 06:41:23 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5BAgZBD009871
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 11 Jun 2009 19:42:40 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 96C7C45DD7D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 19:42:34 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7035B45DD7B
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 19:42:34 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A3BD1DB8040
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 19:42:34 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E4DEF1DB8037
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 19:42:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH for mmotm 0/5] introduce swap-backed-file-mapped count and fix vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch
In-Reply-To: <20090611103837.GB7302@csn.ul.ie>
References: <20090611192114.6D4A.A69D9226@jp.fujitsu.com> <20090611103837.GB7302@csn.ul.ie>
Message-Id: <20090611194141.6D5C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 11 Jun 2009 19:42:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Thu, Jun 11, 2009 at 07:25:09PM +0900, KOSAKI Motohiro wrote:
> > Recently, Wu Fengguang pointed out vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch
> > has underflow problem.
> > 
> 
> Can you drop this aspect of the patchset please? I'm doing a final test
> on the scan-avoidance heuristic that incorporates this patch and the
> underflow fix. Ram (the tester of the malloc()-stall) confirms the patch
> fixes his problem.

OK.
insted, I'll join to review your patch :)



> > This patch series introduce new vmstat of swap-backed-file-mapped and fix above
> > patch by it.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
