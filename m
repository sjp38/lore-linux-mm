Date: Tue, 15 Jun 2004 20:50:17 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Keeping mmap'ed files in core regression in 2.6.7-rc
Message-Id: <20040615205017.15dd1f1d.akpm@osdl.org>
In-Reply-To: <40CFBB75.1010702@yahoo.com.au>
References: <20040608142918.GA7311@traveler.cistron.net>
	<40CAA904.8080305@yahoo.com.au>
	<20040614140642.GE13422@traveler.cistron.net>
	<40CE66EE.8090903@yahoo.com.au>
	<20040615143159.GQ19271@traveler.cistron.net>
	<40CFBB75.1010702@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: miquels@cistron.nl, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>
> Can you send the test app over?

logical next step.

> Andrew, do you have any ideas about how to fix this so far?

Not sure what, if anything, is wrong yet.  It could be that reclaim is now
doing the "right" thing, but this particular workload preferred the "wrong"
thing.  Needs more investigation.


> > 
> > See how "cache" remains stable, but free/buffers memory is oscillating?
> > That shouldn't happen, right ? 
> > 
> 
> If it is doing IO to large regions of mapped memory, the page reclaim
> can start getting a bit chunky. Not much you can do about it, but it
> shouldn't do any harm.

shrink_zone() will free arbitrarily large amounts of memory as the scanning
priority increases.  Probably it shouldn't.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
