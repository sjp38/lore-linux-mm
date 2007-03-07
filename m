Date: Wed, 7 Mar 2007 07:34:38 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [SLUB 2/3] Large kmalloc pass through. Removal of large general
 slabs
In-Reply-To: <1173258077.6374.120.camel@twins>
Message-ID: <Pine.LNX.4.64.0703070732130.9460@schroedinger.engr.sgi.com>
References: <20070307023502.19658.39217.sendpatchset@schroedinger.engr.sgi.com>
  <20070307023513.19658.81228.sendpatchset@schroedinger.engr.sgi.com>
 <1173258077.6374.120.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: akpm@osdl.org, Marcelo Tosatti <marcelo@kvack.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Mar 2007, Peter Zijlstra wrote:

> >  	return -1;
> >  }
> 
> Perhaps so something with PAGE_SIZE here, as you know there are
> platforms/configs where PAGE_SIZE != 4k :-)

Any allocation > 2k just uses a regular allocation which will waste space.

I have a patch here to make this dependent on page size using a loop. The 
problem is that it does not work with some versions of gcc. On the 
other hand we really need this since one arch can 
actually have an order 22 page size!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
