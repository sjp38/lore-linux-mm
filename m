Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [RFC] using writepage to start io
Date: Mon, 6 Aug 2001 21:45:12 +0200
References: <651080000.997116708@tiny>
In-Reply-To: <651080000.997116708@tiny>
MIME-Version: 1.0
Message-Id: <0108062145120I.00294@starship>
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <mason@suse.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 06 August 2001 18:51, Chris Mason wrote:
> On Monday, August 06, 2001 06:13:20 PM +0200 Daniel Phillips
>
> <phillips@bonn-fries.net> wrote:
> >> I am saying that it should be possible to have the best buffer
> >> flushed under memory pressure (by kswapd/bdflush) and still get the
> >> old data to disk in time through kupdate.
> >
> > Yes, to phrase this more precisely, after we've submitted all the
> > too-old buffers we then gain the freedom to select which of the
> > younger buffers to flush.
>
> Almost ;-) memory pressure doesn't need to care about how long a
> buffer has been dirty, that's kupdate's job.  kupdate doesn't care if
> the buffer it is writing is a good candidate for freeing, that's taken
> care of elsewhere. The two never need to talk (aside from
> optimizations).

My point is, they should talk, in fact they should be the same function. 
It's never right for bdflush to submit younger buffers when there are 
dirty buffers whose flush time has already passed.

> > I don't see why it makes sense to have both a kupdate and a bdflush
> > thread.
>
> Having two threads is exactly what allows memory pressure to not be
> concerned about how long a buffer has been dirty.

I'm missing something.  How is it impossible for a single thread to act 
this way?

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
