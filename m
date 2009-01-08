Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4753D6B0047
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 11:49:00 -0500 (EST)
Date: Thu, 8 Jan 2009 08:48:23 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Increase dirty_ratio and dirty_background_ratio?
In-Reply-To: <20090108.082413.156881254.davem@davemloft.net>
Message-ID: <alpine.LFD.2.00.0901080842180.3283@localhost.localdomain>
References: <alpine.LFD.2.00.0901070833430.3057@localhost.localdomain> <20090107.125133.214628094.davem@davemloft.net> <20090108030245.e7c8ceaf.akpm@linux-foundation.org> <20090108.082413.156881254.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Miller <davem@davemloft.net>
Cc: akpm@linux-foundation.org, peterz@infradead.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>



On Thu, 8 Jan 2009, David Miller wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Thu, 8 Jan 2009 03:02:45 -0800
> 
> > The kernel can't get this right - it doesn't know the usage
> > patterns/workloads, etc.
> 
> I don't agree with that.

We can certainly try to tune it better. 

And I do agree that we did a very drastic reduction in the dirty limits, 
and we can probably look at raising it up a bit. I definitely do not want 
to go back to the old 40% dirty model, but I could imagine 10/20% for 
async/sync (it's 5/10 now, isn't it?)

But I do not want to be guided by benchmarks per se, unless they are 
latency-sensitive. And one of the reasons for the drastic reduction was 
that there was actually a real deadlock situation with the old limits, 
although we solved that one twice - first by reducing the limits 
drastically, and then by making them be relative to the non-highmem memory 
(rather than all of it).

So in effect, we actually reduced the limits more than originally 
intended, although that particular effect should be noticeable mainly just 
on 32-bit x86.

I'm certainly open to tuning. As long as "tuning" doesn't involve 
something insane like dbench numbers.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
