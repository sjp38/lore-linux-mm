Date: Wed, 23 May 2007 21:35:52 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
In-Reply-To: <20070524043144.GB12121@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0705232133130.24738@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705222224380.12076@schroedinger.engr.sgi.com>
 <20070523061702.GA9449@wotan.suse.de> <20070523074636.GA10070@wotan.suse.de>
 <Pine.LNX.4.64.0705231006370.19822@schroedinger.engr.sgi.com>
 <20070523193547.GE11115@waste.org> <Pine.LNX.4.64.0705231256001.21541@schroedinger.engr.sgi.com>
 <20070524033925.GD14349@wotan.suse.de> <Pine.LNX.4.64.0705232052040.24352@schroedinger.engr.sgi.com>
 <20070524041339.GC20252@wotan.suse.de> <Pine.LNX.4.64.0705232115140.24618@schroedinger.engr.sgi.com>
 <20070524043144.GB12121@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 24 May 2007, Nick Piggin wrote:

> I'll take an educated guess and say that SLUB would have more external
> fragmentation which would be especially pronounced in small memory
> setups. Also, that SLUB's kmalloc slabs would suffer from a lot more
> internal fragmentation too, which could be equally significant if not
> more (I think this would become relatively more significant than external
> fregmentation as you increased memory size).

Hmmmm... Could be. The kmalloc array is potentially wasting a lot of 
memory. I added more smaller kmalloc array elements to SLUB to avoid that 
but maybe that is not enough.

> If you don't think the test is very interesting, I could try any other
> sort of test and with i386 or x86-64 if you like.

Let me try some tests on my own first. Just ran a SLOB baseline, should 
have some numbers soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
