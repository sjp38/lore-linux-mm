Date: Tue, 20 Mar 2007 20:38:45 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [RFC][PATCH 0/6] per device dirty throttling
Message-ID: <20070320093845.GQ32602149@melbourne.sgi.com>
References: <20070319155737.653325176@programming.kicks-ass.net> <20070320074751.GP32602149@melbourne.sgi.com> <1174378104.16478.17.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1174378104.16478.17.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: David Chinner <dgc@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, neilb@suse.de, tomoki.sekiyama.qu@hitachi.com
List-ID: <linux-mm.kvack.org>

On Tue, Mar 20, 2007 at 09:08:24AM +0100, Peter Zijlstra wrote:
> On Tue, 2007-03-20 at 18:47 +1100, David Chinner wrote:
> > So overall we've lost about 15-20% of the theoretical aggregate
> > perfomrance, but we haven't starved any of the devices over a
> > long period of time.
> > 
> > However, looking at vmstat for total throughput, there are periods
> > of time where it appears that the fastest disk goes idle. That is,
> > we drop from an aggregate of about 550MB/s to below 300MB/s for
> > several seconds at a time. You can sort of see this from the file
> > size output above - long term the ratios remain the same, but in the
> > short term we see quite a bit of variability.
> 
> I suspect you did not apply 7/6? There is some trouble with signed vs
> unsigned in the initial patch set that I tried to 'fix' by masking out
> the MSB, but that doesn't work and results in 'time' getting stuck for
> about half the time.

I applied the fixes patch as well, so i had all that you posted...

> >  but it's almost
> > like it is throttling a device completely while it allows another
> > to finish writing it's quota (underestimating bandwidth?).
> 
> Yeah, there is some lumpy-ness in BIO submission or write completions it
> seems, and when that granularity (multiplied by the number of active
> devices) is larger than the 'time' period over with we average
> (indicated by vm_cycle_shift) very weird stuff can happen.

Sounds like the period is a bit too short atm if we can get into this
sort of problem with only 2 active devices....

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
