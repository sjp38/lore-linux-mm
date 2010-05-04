Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 03F046B023E
	for <linux-mm@kvack.org>; Tue,  4 May 2010 13:35:47 -0400 (EDT)
Date: Tue, 4 May 2010 19:35:15 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/2] Fix migration races in rmap_walk() V3
Message-ID: <20100504173515.GA854@random.random>
References: <1272529930-29505-1-git-send-email-mel@csn.ul.ie>
 <20100430182853.GK22108@random.random>
 <20100501135110.GP20640@cmpxchg.org>
 <20100503153301.GD19891@random.random>
 <20100503234132.GK5336@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100503234132.GK5336@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 04, 2010 at 01:41:32AM +0200, Johannes Weiner wrote:
> Although not strictly required, it's probably nicer to keep the
> function signatures in this code alike.  So everything fine with
> me as it stands :)

Too late I already optimized mincore...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
