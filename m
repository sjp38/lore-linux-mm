Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8C2139000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 14:05:12 -0400 (EDT)
Received: by yia25 with SMTP id 25so8816445yia.14
        for <linux-mm@kvack.org>; Wed, 28 Sep 2011 11:05:10 -0700 (PDT)
Date: Thu, 29 Sep 2011 03:05:03 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] vmscan: add barrier to prevent evictable page in
 unevictable list
Message-ID: <20110928180503.GC1696@barrios-desktop>
References: <1317174330-2677-1-git-send-email-minchan.kim@gmail.com>
 <CAF1ivSaf8ER9yDWohudy-huiq5QHS8vE04R+4+nPTQihZ2MAmQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAF1ivSaf8ER9yDWohudy-huiq5QHS8vE04R+4+nPTQihZ2MAmQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Ming <mlin@ss.pku.edu.cn>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>

On Wed, Sep 28, 2011 at 11:04:05PM +0800, Lin Ming wrote:
> On Wed, Sep 28, 2011 at 9:45 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> > When racing between putback_lru_page and shmem_unlock happens,
> 
> s/shmem_unlock/shmem_lock/

I did it intentionally for represent shmem_lock with user = 1, lock = 0.
If you think it makes others confusing, I will change in next version.
Thanks.

> 
> > progrom execution order is as follows, but clear_bit in processor #1
> > could be reordered right before spin_unlock of processor #1.
> > Then, the page would be stranded on the unevictable list.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
