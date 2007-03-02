Date: Thu, 1 Mar 2007 21:11:58 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
In-Reply-To: <20070301195943.8ceb221a.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0703012105080.3953@woody.linux-foundation.org>
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0703011642190.12485@woody.linux-foundation.org>
 <45E7835A.8000908@in.ibm.com> <Pine.LNX.4.64.0703011939120.12485@woody.linux-foundation.org>
 <20070301195943.8ceb221a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@in.ibm.com>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Thu, 1 Mar 2007, Andrew Morton wrote:
>
> On Thu, 1 Mar 2007 19:44:27 -0800 (PST) Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
> > In other words, I really don't see a huge upside. I see *lots* of 
> > downsides, but upsides? Not so much. Almost everybody who wants unplug 
> > wants virtualization, and right now none of the "big virtualization" 
> > people would want to have kernel-level anti-fragmentation anyway sicne 
> > they'd need to do it on their own.
> 
> Agree with all that, but you're missing the other application: power
> saving.  FBDIMMs take eight watts a pop.

This is a hardware problem. Let's see how long it takes for Intel to 
realize that FBDIMM's were a hugely bad idea from a power perspective.

Yes, the same issues exist for other DRAM forms too, but to a *much* 
smaller degree.

Also, IN PRACTICE you're never ever going to see this anyway. Almost 
everybody wants bank interleaving, because it's a huge performance win on 
many loads. That, in turn, means that your memory will be spread out over 
multiple DIMM's even for a single page, much less any bigger area.

In other words - forget about DRAM power savings. It's not realistic. And 
if you want low-power, don't use FBDIMM's. It really *is* that simple.

(And yes, maybe FBDIMM controllers in a few years won't use 8 W per 
buffer. I kind of doubt that, since FBDIMM fairly fundamentally is highish 
voltage swings at high frequencies.)

Also, on a *truly* idle system, we'll see the power savings whatever we 
do, because the working set will fit in D$, and to get those DRAM power 
savings in reality you need to have the DRAM controller shut down on its 
own anyway (ie sw would only help a bit).

The whole DRAM power story is a bedtime story for gullible children. Don't 
fall for it. It's not realistic. The hardware support for it DOES NOT 
EXIST today, and probably won't for several years. And the real fix is 
elsewhere anyway (ie people will have to do a FBDIMM-2 interface, which 
is against the whole point of FBDIMM in the first place, but that's what 
you get when you ignore power in the first version!).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
