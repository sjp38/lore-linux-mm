Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BF89E6B005A
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 21:30:30 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n821US1d022644
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 2 Sep 2009 10:30:28 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C41BA45DE57
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 10:30:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A5CFC45DE4E
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 10:30:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 897851DB803A
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 10:30:27 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 412F01DB803C
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 10:30:27 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH mmotm] vmscan move pgdeactivate modification to shrink_active_list fix2
In-Reply-To: <Pine.LNX.4.64.0909020154060.31130@sister.anvils>
References: <Pine.LNX.4.64.0908282034240.19475@sister.anvils> <Pine.LNX.4.64.0909020154060.31130@sister.anvils>
Message-Id: <20090902102048.1A98.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  2 Sep 2009 10:30:26 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> A second fix to the ill-starred
> vmscan-move-pgdeactivate-modification-to-shrink_active_list.patch
> which, once corrected to update the right counters by the first fix,
> builds up absurdly large Active counts in /proc/meminfo.
> 
> nr_rotated is not the number of pages added back to the active list
> (maybe it once was, maybe it should be again: but if so that's not
> any business for a code rearrangement patch).  shrink_active_list()
> needs to keep a separate nr_reactivated count of those.
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> ---
> Or... revert the offending patch and its first fix.

Yes, The original patch author should be layoff :(

Andrew, can you please drop the patch?
I need to clean my brain and the patch need proper additional test.

I plan to resubmit it at next -rc2 or -rc3.


I'm sorry.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
