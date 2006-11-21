Date: Tue, 21 Nov 2006 13:29:20 -0600
From: Matt Mackall <mpm@selenic.com>
Subject: Re: build error: sparsemem + SLOB
Message-ID: <20061121192920.GO4797@waste.org>
References: <Pine.LNX.4.64.0611201724340.23537@blonde.wat.veritas.com> <20061120183632.GD4797@waste.org> <20061121143253.51B5.Y-GOTO@jp.fujitsu.com> <20061121191410.GL4797@waste.org> <Pine.LNX.4.64.0611211130440.30133@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0611211130440.30133@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, Randy Dunlap <randy.dunlap@oracle.com>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 21, 2006 at 11:32:57AM -0800, Christoph Lameter wrote:
> On Tue, 21 Nov 2006, Matt Mackall wrote:
> 
> > Are there any implications for preemptible kernels here?
> 
> Matt: Would  you mind if I replace SLOB with my new slab design? It is as 
> memory efficient as yours (maybe even more since we do not have the 
> header for each allocation). It can work efficiently in an SMP system 
> (NUMA still under test). The code is more complex though. 
> Still needs to mature.

How's the code size compare? 

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
