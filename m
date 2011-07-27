Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 80F866B0169
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 16:14:19 -0400 (EDT)
Date: Wed, 27 Jul 2011 13:14:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 08/10] ilru: reduce zone->lru_lock
Message-Id: <20110727131405.0b663296.akpm@linux-foundation.org>
In-Reply-To: <100bcc5d254e5e88f91356876b1d2ce463c2309e.1309787991.git.minchan.kim@gmail.com>
References: <cover.1309787991.git.minchan.kim@gmail.com>
	<100bcc5d254e5e88f91356876b1d2ce463c2309e.1309787991.git.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>

On Mon,  4 Jul 2011 23:04:41 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> inorder_lru increases zone->lru_lock overhead(pointed out by Mel)
> as it doesn't support pagevec.
> This patch introduces ilru_add_pvecs and APIs.

aww geeze, this patch goes and deletes most of the code I just reviewed!

Can we fold them please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
