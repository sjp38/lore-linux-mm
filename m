Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id MAA08160
	for <linux-mm@kvack.org>; Mon, 9 Sep 2002 12:03:37 -0700 (PDT)
Message-ID: <3D7CF077.FB251EC7@digeo.com>
Date: Mon, 09 Sep 2002 12:03:19 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] modified segq for 2.5
References: <3D7C6C0A.1BBEBB2D@digeo.com> <Pine.LNX.4.44L.0209091004200.1857-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: William Lee Irwin III <wli@holomorphy.com>, sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Mon, 9 Sep 2002, Andrew Morton wrote:
> 
> > I fiddled with it a bit:  did you forget to move the write(2) pages
> > to the inactive list?  I changed it to do that at IO completion.
> > It had little effect.  Probably should be looking at the page state
> > before doing that.
> 
> Hmmm indeed, I forgot this.  Note that IO completion state is
> too late, since then you'll have already pushed other pages
> out to the inactive list...

OK.  So how would you like to handle those pages?

> > The inactive list was smaller with this patch.  Around 10%
> > of allocatable memory usually.
> 
> It should be a bit bigger than this, I think.  If it isn't
> something may be going wrong ;)

Well the working set _was_ large.  Sure, we'll be running refill_inactive
a lot.  But spending some CPU in there with this sort of workload is the
right thing to do, if it ends up in better replacement decisions.  So
it doesn't seem to be a problem per-se?

(It's soaking CPU when the VM isn't adding value which offends me ;))


Generally, where do you want to go with this code?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
