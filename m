Date: Wed, 6 Feb 2008 00:19:14 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: SLUB: Support for statistics to help analyze allocator behavior
In-Reply-To: <Pine.LNX.4.64.0802051355270.14665@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0802060015420.20750@sbz-30.cs.Helsinki.FI>
References: <Pine.LNX.4.64.0802042217460.6801@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0802050923220.14675@sbz-30.cs.Helsinki.FI>
 <Pine.LNX.4.64.0802051005010.11705@schroedinger.engr.sgi.com>
 <47A8C508.6010305@cs.helsinki.fi> <Pine.LNX.4.64.0802051355270.14665@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On Tue, 5 Feb 2008, Pekka Enberg wrote:
> > > We could do that.... Any idea how to display that kind of information in a
> > > meaningful way. Parameter conventions for slabinfo?
> > 
> > We could just print out one total summary and one summary for each CPU (and
> > maybe show % of total allocations/fees. That way you can immediately spot if
> > some CPUs are doing more allocations/freeing than others.
 
On Tue, 5 Feb 2008, Christoph Lameter wrote:
> Ok that would work for small amounts of cpus. Note that we are moving 
> to quad core, many standard enterprise servers already have 8 and will 
> likely have 16 next year. Our machine can have thousands of processors 
> (new "practical" limit is 4k cpus although we could reach 16k cpus 
> easily). I was a bit scared to open that can of worms.

I can see why. I think we can change the format summary a bit and have one 
line per CPU only:

      Allocation                                           Deallocation
                        Page    Add     Remove  RemoveObj/                   Page    Add     Remove  RemoveObj/
CPU   Fast      Slow    Alloc   Partial Partial SlabFrozen Fast      Slow    Alloc   Partial Partial SlabFrozen
16000 111953360 1044    272     25      86      350        111946981 7423    264     325     264     4832

In addition, we can probably add some sort of option for determining how 
many CPUs you're interested in seeing (sorted by CPUs that have most the 
activity first).

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
