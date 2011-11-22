Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8ABC56B0069
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 09:14:31 -0500 (EST)
Date: Tue, 22 Nov 2011 22:14:20 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/8] readahead: add /debug/readahead/stats
Message-ID: <20111122141420.GA29261@localhost>
References: <20111121091819.394895091@intel.com>
 <20111121093846.636765408@intel.com>
 <20111121141759.GE24062@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111121141759.GE24062@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

Andi,

On Mon, Nov 21, 2011 at 10:17:59PM +0800, Andi Kleen wrote:
> > +static unsigned long ra_stats[RA_PATTERN_MAX][RA_ACCOUNT_MAX];
> 
> Why not make it per cpu?  That should get the overhead down, probably
> even enough that it can be enabled by default.
> 
> BTW I have an older framework to make it really easy to add per
> cpu stats counters to debugfs. Will repost, that would simplify
> it even more.

That's definitely a good facility to have. I would be happy to become
its first user :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
