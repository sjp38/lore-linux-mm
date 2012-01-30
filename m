Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 656696B005A
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 08:25:16 -0500 (EST)
Date: Mon, 30 Jan 2012 13:25:12 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCHv19 00/15] Contiguous Memory Allocator
Message-ID: <20120130132512.GO25268@csn.ul.ie>
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
 <201201261531.40551.arnd@arndb.de>
 <20120127162624.40cba14e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120127162624.40cba14e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

On Fri, Jan 27, 2012 at 04:26:24PM -0800, Andrew Morton wrote:
> On Thu, 26 Jan 2012 15:31:40 +0000
> Arnd Bergmann <arnd@arndb.de> wrote:
> 
> > On Thursday 26 January 2012, Marek Szyprowski wrote:
> > > Welcome everyone!
> > > 
> > > Yes, that's true. This is yet another release of the Contiguous Memory
> > > Allocator patches. This version mainly includes code cleanups requested
> > > by Mel Gorman and a few minor bug fixes.
> > 
> > Hi Marek,
> > 
> > Thanks for keeping up this work! I really hope it works out for the
> > next merge window.
> 
> Someone please tell me when it's time to start paying attention
> again ;)
> 
> These patches don't seem to have as many acked-bys and reviewed-bys as
> I'd expect. 

I reviewed the core MM changes and I've acked most of them so the
next release should have a few acks where you expect them. I did not
add a reviewed-by because I did not build and test the thing.

For me, Patch 2 is the only one that must be fixed prior to merging
as it can interfere with pages on a remote per-cpu list which is
dangerous. I know your suggestion will be to delete the per-cpu lists
and be done with it but I am a bit away from doing that just yet.

Patch 8 could do with a bit more care too but it is not a
potential hand grenade like patch 2 and could be fixed as part of
a follow-up. Even if you don't see an ack from me there, it should not
be treated as a show stopper.

I highlighted some issues on how CMA interacts with reclaim but I
think this is a problem specific to CMA and should not prevent it being
merged. I just wanted to be sure that the CMA people were aware of the
potential issues so they will recognise the class of bug if it occurs.

> Given the scope and duration of this, it would be useful
> to gather these up.  But please ensure they are real ones - people
> sometimes like to ack things without showing much sign of having
> actually read them.
> 

FWIW, the acks I put on the core MM changes are real acks :)

> The patches do seem to have been going round in ever-decreasing circles
> lately and I think we have decided to merge them (yes?) so we may as well
> get on and do that and sort out remaining issues in-tree.
> 

I'm a lot happier with the core MM patches than I was when I reviewed
this first around last September or October.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
