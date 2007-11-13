Date: Mon, 12 Nov 2007 20:41:10 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: x86_64: Make sparsemem/vmemmap the default memory model
In-Reply-To: <2c0942db0711122027m5b11502cveded5705c0bc4f64@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0711122040380.30724@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0711121549370.29178@schroedinger.engr.sgi.com>
 <200711130059.34346.ak@suse.de>  <Pine.LNX.4.64.0711121615120.29328@schroedinger.engr.sgi.com>
  <200711130149.54852.ak@suse.de>  <Pine.LNX.4.64.0711121940410.30269@schroedinger.engr.sgi.com>
 <2c0942db0711122027m5b11502cveded5705c0bc4f64@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Lee <ray-lk@madrabbit.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <ak@suse.de>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Mon, 12 Nov 2007, Ray Lee wrote:

> Discontig obviously needs to die. However, FlatMem is consistently
> faster, averaging about 2.1% better overall for your numbers above. Is
> the page allocator not, erm, a fast path, where that matters?
> 
> Order	Flat	Sparse	% diff
> 0	639	641	0.3

IMHO Order 0 currently matters most and the difference is negligible 
there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
