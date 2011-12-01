Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 76B696B0047
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 15:55:00 -0500 (EST)
Date: Thu, 1 Dec 2011 12:54:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: incorrect overflow check in shrink_slab()
Message-Id: <20111201125457.fdf79489.akpm@linux-foundation.org>
In-Reply-To: <20111201183202.2e5bd872.kamezawa.hiroyu@jp.fujitsu.com>
References: <0D9D9F79-204D-4460-8CE7-A583C5C38A1E@gmail.com>
	<20111201183202.2e5bd872.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Xi Wang <xi.wang@gmail.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 1 Dec 2011 18:32:02 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > total_scan is unsigned long, so the overflow check (total_scan < 0)
> > didn't work.
> > 
> > Signed-off-by: Xi Wang <xi.wang@gmail.com>
> 
> Nice catch but.... the 'total_scan" shouldn't be long ?
> Rather than type casting ?

Konstantin Khlebnikov's "vmscan: fix initial shrinker size handling"
does change it to `long'.  That patch is in -mm and linux-next and is
queued for 3.3.  It was queued for 3.2 but didn't make it due to some
me/Dave Chinner confusion.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
