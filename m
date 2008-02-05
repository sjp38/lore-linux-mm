Date: Tue, 5 Feb 2008 13:58:06 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: Support for statistics to help analyze allocator behavior
In-Reply-To: <47A8C508.6010305@cs.helsinki.fi>
Message-ID: <Pine.LNX.4.64.0802051355270.14665@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802042217460.6801@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0802050923220.14675@sbz-30.cs.Helsinki.FI>
 <Pine.LNX.4.64.0802051005010.11705@schroedinger.engr.sgi.com>
 <47A8C508.6010305@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 5 Feb 2008, Pekka Enberg wrote:

> > We could do that.... Any idea how to display that kind of information in a
> > meaningful way. Parameter conventions for slabinfo?
> 
> We could just print out one total summary and one summary for each CPU (and
> maybe show % of total allocations/fees. That way you can immediately spot if
> some CPUs are doing more allocations/freeing than others.

Ok that would work for small amounts of cpus. Note that we are moving 
to quad core, many standard enterprise servers already have 8 and will 
likely have 16 next year. Our machine can have thousands of processors 
(new "practical" limit is 4k cpus although we could reach 16k cpus 
easily). I was a bit scared to open that can of worms.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
