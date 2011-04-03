Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C13098D0040
	for <linux-mm@kvack.org>; Sun,  3 Apr 2011 14:41:26 -0400 (EDT)
Date: Sun, 3 Apr 2011 13:41:20 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/3] Unmapped page cache control (v5)
In-Reply-To: <20110402011040.GG6957@dastard>
Message-ID: <alpine.DEB.2.00.1104031339120.15317@router.home>
References: <20110331144145.0ECA.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1103311451530.28364@router.home> <20110401221921.A890.A69D9226@jp.fujitsu.com> <20110402011040.GG6957@dastard>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>

On Sat, 2 Apr 2011, Dave Chinner wrote:

> Fundamentally, if you just switch off memory reclaim to avoid the
> latencies involved with direct memory reclaim, then all you'll get
> instead is ENOMEM because there's no memory available and none will be
> reclaimed. That's even more fatal for the system than doing reclaim.

Not for my use cases here. No one will die if reclaim happens but its bad
for the bottom line. Reducing the chance of memory reclaim occurring in a
critical section is sufficient.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
