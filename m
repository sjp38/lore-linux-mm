Date: Wed, 19 Jun 2002 14:35:45 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] (1/2) reverse mapping VM for 2.5.23 (rmap-13b)
In-Reply-To: <20020619191136.H29373@suse.de>
Message-ID: <Pine.LNX.4.44L.0206191429300.2598-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Jones <davej@suse.de>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Craig Kulesa <ckulesa@as.arizona.edu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, rwhron@earthlink.net
List-ID: <linux-mm.kvack.org>

On Wed, 19 Jun 2002, Dave Jones wrote:
> On Wed, Jun 19, 2002 at 07:00:57PM +0200, Daniel Phillips wrote:
>  > > ...Hope this is of use to someone!  It's certainly been a fun and
>  > > instructive exercise for me so far.  ;)
>  > It's intensely useful.  It changes the whole character of the VM discussion
>  > at the upcoming kernel summit from 'should we port rmap to mainline?' to 'how
>  > well does it work' and 'what problems need fixing'.  Much more useful.
>
> Absolutely.  Maybe Randy Hron (added to Cc) can find some spare time
> to benchmark these sometime before the summit too[1]. It'll be very
> interesting to see where it fits in with the other benchmark results
> he's collected on varying workloads.

Note that either version is still untuned and rmap for 2.5
still needs pte-highmem support.

I am encouraged by Craig's test results, which show that
rmap did a LOT less swapin IO and rmap with page aging even
less. The fact that it did too much swapout IO means one
part of the system needs tuning but doesn't say much about
the thing as a whole.

In fact, I have a feeling that our tools are still too
crude, we really need/want some statistics of what's
happening inside the VM ... I'll work on those shortly.

Once we do have the tools to look at what's happening
inside the VM we should be much better able to tune the
right places inside the VM.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
