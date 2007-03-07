Date: Wed, 7 Mar 2007 12:03:59 -0600
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [SLUB 2/3] Large kmalloc pass through. Removal of large general slabs
Message-ID: <20070307180359.GU23311@waste.org>
References: <20070307023502.19658.39217.sendpatchset@schroedinger.engr.sgi.com> <20070307023513.19658.81228.sendpatchset@schroedinger.engr.sgi.com> <1173258077.6374.120.camel@twins> <Pine.LNX.4.64.0703070732130.9460@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703070732130.9460@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, akpm@osdl.org, Marcelo Tosatti <marcelo@kvack.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 07, 2007 at 07:34:38AM -0800, Christoph Lameter wrote:
> On Wed, 7 Mar 2007, Peter Zijlstra wrote:
> 
> > >  	return -1;
> > >  }
> > 
> > Perhaps so something with PAGE_SIZE here, as you know there are
> > platforms/configs where PAGE_SIZE != 4k :-)
> 
> Any allocation > 2k just uses a regular allocation which will waste space.
> 
> I have a patch here to make this dependent on page size using a loop. The 
> problem is that it does not work with some versions of gcc. On the 
> other hand we really need this since one arch can 
> actually have an order 22 page size!

You don't need a loop, you need an if (s >= PAGE_SIZE) at the head of
your static list.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
