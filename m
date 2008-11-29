Date: Sat, 29 Nov 2008 12:29:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] vmscan: skip freeing memory from zones with lots free
Message-Id: <20081129122901.6243d2fa.akpm@linux-foundation.org>
In-Reply-To: <49319109.7030904@redhat.com>
References: <20081128060803.73cd59bd@bree.surriel.com>
	<20081128231933.8daef193.akpm@linux-foundation.org>
	<4931721D.7010001@redhat.com>
	<20081129094537.a224098a.akpm@linux-foundation.org>
	<493182C8.1080303@redhat.com>
	<20081129102608.f8228afd.akpm@linux-foundation.org>
	<49318CDE.4020505@redhat.com>
	<20081129105120.cfb8c035.akpm@linux-foundation.org>
	<49319109.7030904@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Sat, 29 Nov 2008 13:59:21 -0500 Rik van Riel <riel@redhat.com> wrote:

> Andrew Morton wrote:
> > On Sat, 29 Nov 2008 13:41:34 -0500 Rik van Riel <riel@redhat.com> wrote:
> > 
> >> Andrew Morton wrote:
> >>> On Sat, 29 Nov 2008 12:58:32 -0500 Rik van Riel <riel@redhat.com> wrote:
> >>>
> >>>>> Will this new patch reintroduce the problem which
> >>>>> 26e4931632352e3c95a61edac22d12ebb72038fe fixed?
> >> No, that problem is already taken care of by the fact that
> >> active pages always get deactivated in the current VM,
> >> regardless of whether or not they were referenced.
> > 
> > err, sorry, that was the wrong commit. 
> > 26e4931632352e3c95a61edac22d12ebb72038fe _introduced_ the problem, as
> > predicted in the changelog.
> > 
> > 265b2b8cac1774f5f30c88e0ab8d0bcf794ef7b3 later fixed it up.
> 
> The patch I sent in this thread does not do any baling out,
> it only skips zones where the number of free pages is more
> than 4 times zone->pages_high.

But that will have the same effect as baling out.  Moreso, in fact.

> Equal pressure is still applied to the other zones.
> 
> This should not be a problem since we do not enter direct
> reclaim unless the free pages in every zone in our zonelist
> are below zone->pages_low.
> 
> Zone skipping is only done by tasks that have been in the
> direct reclaim code for a long time.

>From 265b2b8cac1774f5f30c88e0ab8d0bcf794ef7b3:

    We currently have a problem with the balancing of reclaim
    between zones: much more reclaim happens against highmem than
    against lowmem.

This problem will be reintroduced, will it not?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
