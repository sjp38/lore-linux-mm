Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B82906B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 09:11:19 -0500 (EST)
Received: by qyk7 with SMTP id 7so1247920qyk.14
        for <linux-mm@kvack.org>; Tue, 30 Nov 2010 06:11:05 -0800 (PST)
From: Ben Gamari <bgamari.foss@gmail.com>
Subject: Re: [PATCH 2/3] Reclaim invalidated page ASAP
In-Reply-To: <20101130091822.GJ13268@csn.ul.ie>
References: <cover.1291043273.git.minchan.kim@gmail.com> <053e6a3308160a8992af5a47fb4163796d033b08.1291043274.git.minchan.kim@gmail.com> <20101130100933.82E9.A69D9226@jp.fujitsu.com> <20101130091822.GJ13268@csn.ul.ie>
Date: Tue, 30 Nov 2010 09:11:01 -0500
Message-ID: <87zksqeway.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010 09:18:22 +0000, Mel Gorman <mel@csn.ul.ie> wrote:
> I would agree except as said elsewhere, it's a chicken and egg problem.
> We don't have a real world test because fadvise is not useful in its
> current iteration. I'm hoping that there will be a test comparing
> 
> rsync		on vanilla kernel
> rsync		on patched kernel
> rsync+patch	on vanilla kernel
> rsync+patch	on patched kernel
> 
> Are the results of such a test likely to happen?
> 
Yes, absolutely, although I'm sorry it has taken so long. Between
thanksgiving and the impending end of the semester things have been a
bit hectic. Nevertheless, I just finished putting together a script to
record some metics from /proc/vmstat and /proc/[pid]/statm, so at this
point I'm ready to finally take some data. Any suggestions for
particular patterns to look for in the numbers or other metrics to
record are welcome. Cheers,

- Ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
