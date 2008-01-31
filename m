Date: Thu, 31 Jan 2008 02:18:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: MADV_WILLNEED implementation for anonymous memory
Message-Id: <20080131021802.b591bee8.akpm@linux-foundation.org>
In-Reply-To: <1201774213.28547.277.camel@lappy>
References: <1201714139.28547.237.camel@lappy>
	<20080130144049.73596898.akpm@linux-foundation.org>
	<1201769040.28547.245.camel@lappy>
	<20080131011227.257b9437.akpm@linux-foundation.org>
	<1201772118.28547.254.camel@lappy>
	<20080131014702.705f1040.akpm@linux-foundation.org>
	<1201773206.28547.259.camel@lappy>
	<20080131020516.be42c495.akpm@linux-foundation.org>
	<1201774213.28547.277.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: hugh@veritas.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de, riel@redhat.com, mztabzr@0pointer.de, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2008 11:10:13 +0100 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> 
> On Thu, 2008-01-31 at 02:05 -0800, Andrew Morton wrote:
> > On Thu, 31 Jan 2008 10:53:26 +0100 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > 
> > > 
> > > On Thu, 2008-01-31 at 01:47 -0800, Andrew Morton wrote:
> > > > On Thu, 31 Jan 2008 10:35:18 +0100 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > > > 
> > > > > 
> > > > > On Thu, 2008-01-31 at 01:12 -0800, Andrew Morton wrote:
> > > > > 
> > > > > > Implementation-wise: make_pages_present() _can_ be converted to do this. 
> > > > > > But it's a lot of patching, and the result will be a cleaner, faster and
> > > > > > smaller core MM.  Whereas your approach is easy, but adds more code and
> > > > > > leaves the old stuff slow-and-dirty.
> > > > > > 
> > > > > > Guess which approach is preferred? ;)
> > > > > 
> > > > > Ok, I'll look at using make_pages_present().
> > > > 
> > > > Am still curious to know what inspired this change.  What are the use
> > > > cases?  Performance testing results, etc?
> > > 
> > > Ah, that is Lennarts Pulse Audio thing, he has samples in memory which
> > > might not have been used for a while, and he wants to be able to
> > > pre-fetch those when he suspects they might need to be played. So that
> > > once the audio thread comes along and stuffs them down /dev/dsp its all
> > > nice in memory.
> > > 
> > > Since its all soft real-time at best he feels its better to do a best
> > > effort at not hitting swap than it is to strain the system with mlock
> > > usage.
> > 
> > hrm.  Does he know about pthread_create()?
> 
> I'm very sure he does. So you're suggesting to just create a thread and
> touch that memory and be done with it?
> 
> Lennart?

That would get him out of trouble.  But it certainly makes _sense_ for the
kernel to implement MADV_WILLNEED for anon memory.  From a consistency POV.

But I don't know that the usefulness of the feature is worth actually
expending code on.  Heck, after five-odd years I'm still asking every
second person I meet "why don't you use fadvise()?"  (Reponse: ooooh!)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
