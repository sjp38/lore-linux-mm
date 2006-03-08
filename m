From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: yield during swap prefetching
Date: Wed, 8 Mar 2006 13:22:02 +1100
References: <200603081013.44678.kernel@kolivas.org> <200603081312.51058.kernel@kolivas.org> <1141784295.767.126.camel@mindpipe>
In-Reply-To: <1141784295.767.126.camel@mindpipe>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200603081322.02306.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Revell <rlrevell@joe-job.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Mar 2006 01:18 pm, Lee Revell wrote:
> On Wed, 2006-03-08 at 13:12 +1100, Con Kolivas wrote:
> > On Wed, 8 Mar 2006 01:08 pm, Lee Revell wrote:
> > > On Wed, 2006-03-08 at 12:28 +1100, Con Kolivas wrote:
> > > > I can't distinguish between when cpu activity is important (game) and
> > > > when it is not (compile), and assuming worst case scenario and not
> > > > doing any swap prefetching is my intent. I could add cpu accounting
> > > > to prefetch_suitable() instead, but that gets rather messy and
> > > > yielding achieves the same endpoint.
> > >
> > > Shouldn't the game be running with RT priority or at least at a low
> > > nice value?
> >
> > No way. Games run nice 0 SCHED_NORMAL.
>
> Maybe this is a stupid/OT question (answer off list if you think so) but
> why not?  Isn't that the standard way of telling the scheduler that you
> have a realtime constraint?  It's how pro audio stuff works which I
> would think has similar RT requirements.
>
> How is the scheduler supposed to know to penalize a kernel compile
> taking 100% CPU but not a game using 100% CPU?

Because being a serious desktop operating system that we are (bwahahahaha) 
means the user should not have special privileges to run something as simple 
as a game. Games should not need special scheduling classes. We can always 
use 'nice' for a compile though. Real time audio is a completely different 
world to this. 

Cheers,
Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
