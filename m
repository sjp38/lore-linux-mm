Date: Wed, 7 Mar 2007 10:23:36 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [SLUB 2/3] Large kmalloc pass through. Removal of large general
 slabs
In-Reply-To: <20070307180359.GU23311@waste.org>
Message-ID: <Pine.LNX.4.64.0703071022230.22448@schroedinger.engr.sgi.com>
References: <20070307023502.19658.39217.sendpatchset@schroedinger.engr.sgi.com>
 <20070307023513.19658.81228.sendpatchset@schroedinger.engr.sgi.com>
 <1173258077.6374.120.camel@twins> <Pine.LNX.4.64.0703070732130.9460@schroedinger.engr.sgi.com>
 <20070307180359.GU23311@waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, akpm@osdl.org, Marcelo Tosatti <marcelo@kvack.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Mar 2007, Matt Mackall wrote:

> > I have a patch here to make this dependent on page size using a loop. The 
> > problem is that it does not work with some versions of gcc. On the 
> > other hand we really need this since one arch can 
> > actually have an order 22 page size!
> 
> You don't need a loop, you need an if (s >= PAGE_SIZE) at the head of
> your static list.

As I just said: PAGE_SIZE may be quite high. So I would need a looong 
static list. We already check for the size being bigger than 2048 which is 
half the usual page size. Anything larger will get passed through.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
