Date: Fri, 2 Mar 2007 08:20:23 -0800
From: Mark Gross <mgross@linux.intel.com>
Subject: Re: The performance and behaviour of the anti-fragmentation related patches
Message-ID: <20070302162023.GA4691@linux.intel.com>
Reply-To: mgross@linux.intel.com
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org> <Pine.LNX.4.64.0703011642190.12485@woody.linux-foundation.org> <45E7835A.8000908@in.ibm.com> <Pine.LNX.4.64.0703011939120.12485@woody.linux-foundation.org> <20070301195943.8ceb221a.akpm@linux-foundation.org> <Pine.LNX.4.64.0703012105080.3953@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703012105080.3953@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@in.ibm.com>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 01, 2007 at 09:11:58PM -0800, Linus Torvalds wrote:
> 
> On Thu, 1 Mar 2007, Andrew Morton wrote:
> >
> > On Thu, 1 Mar 2007 19:44:27 -0800 (PST) Linus Torvalds <torvalds@linux-foundation.org> wrote:
> > 
> > > In other words, I really don't see a huge upside. I see *lots* of 
> > > downsides, but upsides? Not so much. Almost everybody who wants unplug 
> > > wants virtualization, and right now none of the "big virtualization" 
> > > people would want to have kernel-level anti-fragmentation anyway sicne 
> > > they'd need to do it on their own.
> > 
> > Agree with all that, but you're missing the other application: power
> > saving.  FBDIMMs take eight watts a pop.
> 
> This is a hardware problem. Let's see how long it takes for Intel to 
> realize that FBDIMM's were a hugely bad idea from a power perspective.
> 
> Yes, the same issues exist for other DRAM forms too, but to a *much* 
> smaller degree.

DDR3-1333 may be better than FBDIMM's but don't count on it being much
better.

> 
> Also, IN PRACTICE you're never ever going to see this anyway. Almost 
> everybody wants bank interleaving, because it's a huge performance win on 
> many loads. That, in turn, means that your memory will be spread out over 
> multiple DIMM's even for a single page, much less any bigger area.

4-way interleave across banks on systems may not be as common as you may
think for future chip sets.  2-way interleave across DIMMs within a bank
will stay.

Also the performance gains between 2 and 4 way interleave have been
shown to be hard to measure.  It may be counter intuitive but its not
the huge performance win you may expect.  At least in some of the test
cases I've seen reported showed it to be under the noise floor of the
lmbench test cases.  


> 
> In other words - forget about DRAM power savings. It's not realistic. And 
> if you want low-power, don't use FBDIMM's. It really *is* that simple.
>

DDR3-1333 won't be much better.  

> (And yes, maybe FBDIMM controllers in a few years won't use 8 W per 
> buffer. I kind of doubt that, since FBDIMM fairly fundamentally is highish 
> voltage swings at high frequencies.)
> 
> Also, on a *truly* idle system, we'll see the power savings whatever we 
> do, because the working set will fit in D$, and to get those DRAM power 
> savings in reality you need to have the DRAM controller shut down on its 
> own anyway (ie sw would only help a bit).
> 
> The whole DRAM power story is a bedtime story for gullible children. Don't 
> fall for it. It's not realistic. The hardware support for it DOES NOT 
> EXIST today, and probably won't for several years. And the real fix is 
> elsewhere anyway (ie people will have to do a FBDIMM-2 interface, which 
> is against the whole point of FBDIMM in the first place, but that's what 
> you get when you ignore power in the first version!).
>

Hardware support for some of this is coming this year in the ATCA space
on the MPCBL0050.  The feature is a bit experimental, and
power/performance benefits will be workload and configuration
dependent.  Its not a bed time story.

--mgross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
