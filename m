Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D7C31900137
	for <linux-mm@kvack.org>; Sun, 31 Jul 2011 12:31:31 -0400 (EDT)
Received: by pzk33 with SMTP id 33so10397359pzk.36
        for <linux-mm@kvack.org>; Sun, 31 Jul 2011 09:31:29 -0700 (PDT)
Date: Mon, 1 Aug 2011 01:31:21 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v4 08/10] ilru: reduce zone->lru_lock
Message-ID: <20110731163121.GB2864@barrios-desktop>
References: <cover.1309787991.git.minchan.kim@gmail.com>
 <100bcc5d254e5e88f91356876b1d2ce463c2309e.1309787991.git.minchan.kim@gmail.com>
 <20110727131405.0b663296.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110727131405.0b663296.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, Jul 27, 2011 at 01:14:05PM -0700, Andrew Morton wrote:
> On Mon,  4 Jul 2011 23:04:41 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
> 
> > inorder_lru increases zone->lru_lock overhead(pointed out by Mel)
> > as it doesn't support pagevec.
> > This patch introduces ilru_add_pvecs and APIs.
> 
> aww geeze, this patch goes and deletes most of the code I just reviewed!
> 
> Can we fold them please?

Of course!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
