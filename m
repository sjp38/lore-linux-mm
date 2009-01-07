Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 070616B0044
	for <linux-mm@kvack.org>; Wed,  7 Jan 2009 11:25:46 -0500 (EST)
Subject: Re: Increase dirty_ratio and dirty_background_ratio?
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20090107154517.GA5565@duck.suse.cz>
References: <20090107154517.GA5565@duck.suse.cz>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Wed, 07 Jan 2009 17:25:46 +0100
Message-Id: <1231345546.11687.314.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-01-07 at 16:45 +0100, Jan Kara wrote:
> Hi,
> 
>   I'm writing mainly to gather opinions of clever people here ;). In commit
> 07db59bd6b0f279c31044cba6787344f63be87ea (in April 2007) Linus has
> decreased default /proc/sys/vm/dirty_ratio from 40 to 10 and
> /proc/sys/vm/dirty_background_ratio from 10 to 5. 

> While tracking
> performance regressions in SLES11 wrt SLES10 we noted that this has severely
> affected perfomance of some workloads using Berkeley DB (basically because
> what the database does is that it creates a file almost as big as available
> memory, mmaps it and randomly scribbles all over it and with lower limits
> it gets much earlier throttled / pdflush is more aggressive writing back
> stuff which is counterproductive in this particular case).

>   So the question is: What kind of workloads are lower limits supposed to
> help? Desktop? Has anybody reported that they actually help? I'm asking
> because we are probably going to increase limits to the old values for
> SLES11 if we don't see serious negative impact on other workloads...

Adding some CCs.

The idea was that 40% of the memory is a _lot_ these days, and writeback
times will be huge for those hitting sync or similar. By lowering these
you'd smooth that out a bit.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
