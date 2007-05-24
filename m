Date: Thu, 24 May 2007 06:31:44 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/3] slob: rework freelist handling
Message-ID: <20070524043144.GB12121@wotan.suse.de>
References: <Pine.LNX.4.64.0705222224380.12076@schroedinger.engr.sgi.com> <20070523061702.GA9449@wotan.suse.de> <20070523074636.GA10070@wotan.suse.de> <Pine.LNX.4.64.0705231006370.19822@schroedinger.engr.sgi.com> <20070523193547.GE11115@waste.org> <Pine.LNX.4.64.0705231256001.21541@schroedinger.engr.sgi.com> <20070524033925.GD14349@wotan.suse.de> <Pine.LNX.4.64.0705232052040.24352@schroedinger.engr.sgi.com> <20070524041339.GC20252@wotan.suse.de> <Pine.LNX.4.64.0705232115140.24618@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705232115140.24618@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 23, 2007 at 09:23:22PM -0700, Christoph Lameter wrote:
> On Thu, 24 May 2007, Nick Piggin wrote:
> 
> > > It would also work fine with SLUB? Its about 12k code + data on 
> > > x86_64. I doubt that this would be too much of an issue.
> > 
> > Well as I said, I am not the one to ask about whether SLUB could replace
> > SLOB or not. All else being equal, of course it is a good idea.
> > 
> > But what I think is clear is that SLOB simply uses memory more
> > efficiently than SLUB (in my test, anyway). I don't know how this can
> > still be in dispute?
> 
> You have shown that SLUB used more memory than SLOB after bootup on PPC64.
> But why is still an open question.

I'll take an educated guess and say that SLUB would have more external
fragmentation which would be especially pronounced in small memory
setups. Also, that SLUB's kmalloc slabs would suffer from a lot more
internal fragmentation too, which could be equally significant if not
more (I think this would become relatively more significant than external
fregmentation as you increased memory size).

If you don't think the test is very interesting, I could try any other
sort of test and with i386 or x86-64 if you like.


> It could be the way that SLOB can exploit the page for multiple object 
> sizes which creates the advantage. If that is the case then we can do 
> nothing with SLUB.
> 
> But there could still be excessive memory allocs with SLUB that we are not 
> aware of at this point. For example if the page size > 4k then SLUB will 
> use higher order allocs by default which will increase wastage.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
