Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 60F1F8D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 09:47:08 -0500 (EST)
Date: Tue, 22 Feb 2011 15:46:31 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v6 0/4] fadvise(DONTNEED) support
Message-ID: <20110222144631.GZ13092@random.random>
References: <cover.1298212517.git.minchan.kim@gmail.com>
 <20110221190713.GM13092@random.random>
 <AANLkTimOhgK953rmOw4PqnoFq_e7y6j1m+NBDYJehkds@mail.gmail.com>
 <20110222132804.GQ13092@random.random>
 <20110222142610.GA6093@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110222142610.GA6093@barrios-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steven Barrett <damentz@liquorix.net>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue, Feb 22, 2011 at 11:26:10PM +0900, Minchan Kim wrote:
> I agree your opinion but I hope the patch is going on 2.6.38 or 39.
> That's because if we find regression's root cause, how could this series be changed?
> I think it's no difference before and after.
> Of course, if rsync like applicatoin start to use fadvise agressively, the problem
> could be buried on toe but we still have a older kernel and older rsync so we can
> reproduce it then we can find the root cause.

No risk to hide it (I do backups with tar ;). I'm also assuming your
modification to rsync isn't going to be on by default (for small
working set, it's ok if rsync holds the cache and doesn't discard it).

> What's the problem if the series is merged?
> If it is reasonable, it's no problem to pend the series.

I've absolutely no problem with the objective of this series. The
objective looks very good and it can increase performance (like showed
by your benchmark saving 2min from your workload under stress and only
running a few seconds slower without stress).

> I _totally_ agree your opinion and I want to find root cause of the regression, too.
> But unfortunatly, I don't have any time and enviroment to reproduce it. ;(
> I hope clever people like you would have a time to find it and report it to linux-mm
> in future.
> 
> Ben. Could you test your workload on older 2.6.18 kernel if you see the thread?
> It could help us very much.

Exactly, I only wanted to suggest to check what happens with 2.6.18 to
at least know if it's a regression or not. Because if we have a
regression, we need more work on this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
