Date: Wed, 23 May 2007 21:23:22 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
In-Reply-To: <20070524041339.GC20252@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0705232115140.24618@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705222212200.3232@schroedinger.engr.sgi.com>
 <20070523052206.GD29045@wotan.suse.de> <Pine.LNX.4.64.0705222224380.12076@schroedinger.engr.sgi.com>
 <20070523061702.GA9449@wotan.suse.de> <20070523074636.GA10070@wotan.suse.de>
 <Pine.LNX.4.64.0705231006370.19822@schroedinger.engr.sgi.com>
 <20070523193547.GE11115@waste.org> <Pine.LNX.4.64.0705231256001.21541@schroedinger.engr.sgi.com>
 <20070524033925.GD14349@wotan.suse.de> <Pine.LNX.4.64.0705232052040.24352@schroedinger.engr.sgi.com>
 <20070524041339.GC20252@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 24 May 2007, Nick Piggin wrote:

> > It would also work fine with SLUB? Its about 12k code + data on 
> > x86_64. I doubt that this would be too much of an issue.
> 
> Well as I said, I am not the one to ask about whether SLUB could replace
> SLOB or not. All else being equal, of course it is a good idea.
> 
> But what I think is clear is that SLOB simply uses memory more
> efficiently than SLUB (in my test, anyway). I don't know how this can
> still be in dispute?

You have shown that SLUB used more memory than SLOB after bootup on PPC64.
But why is still an open question.

It could be the way that SLOB can exploit the page for multiple object 
sizes which creates the advantage. If that is the case then we can do 
nothing with SLUB.

But there could still be excessive memory allocs with SLUB that we are not 
aware of at this point. For example if the page size > 4k then SLUB will 
use higher order allocs by default which will increase wastage.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
