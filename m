Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [RFC] using writepage to start io
Date: Mon, 6 Aug 2001 23:18:26 +0200
References: <755760000.997128720@tiny>
In-Reply-To: <755760000.997128720@tiny>
MIME-Version: 1.0
Message-Id: <01080623182601.01864@starship>
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <mason@suse.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 06 August 2001 22:12, Chris Mason wrote:
> On Monday, August 06, 2001 09:45:12 PM +0200 Daniel Phillips
>
> <phillips@bonn-fries.net> wrote:
> >> Almost ;-) memory pressure doesn't need to care about how long a
> >> buffer has been dirty, that's kupdate's job.  kupdate doesn't care
> >> if the buffer it is writing is a good candidate for freeing, that's
> >> taken care of elsewhere. The two never need to talk (aside from
> >> optimizations).
> >
> > My point is, they should talk, in fact they should be the same
> > function. It's never right for bdflush to submit younger buffers
> > when there are dirty buffers whose flush time has already passed.
>
> Grin, we're talking in circles.  My point is that by having two
> threads, bdflush is allowed to skip over older buffers in favor of
> younger ones because somebody else is responsible for writing the
> older ones out.

Yes, and you can't imagine an algorithm that could do that with *one* 
thread?

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
