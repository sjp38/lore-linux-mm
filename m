Subject: Re: [PATCH 0/5] make slab gfp fair
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0705141303570.12167@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
	 <Pine.LNX.4.64.0705140852150.10442@schroedinger.engr.sgi.com>
	 <20070514161224.GC11115@waste.org>
	 <Pine.LNX.4.64.0705140927470.10801@schroedinger.engr.sgi.com>
	 <1179164453.2942.26.camel@lappy>
	 <Pine.LNX.4.64.0705141051170.11251@schroedinger.engr.sgi.com>
	 <1179170912.2942.37.camel@lappy>
	 <Pine.LNX.4.64.0705141253130.12045@schroedinger.engr.sgi.com>
	 <1179172994.2942.49.camel@lappy>
	 <Pine.LNX.4.64.0705141303570.12167@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 14 May 2007 22:12:36 +0200
Message-Id: <1179173556.2942.54.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-05-14 at 13:06 -0700, Christoph Lameter wrote:
> On Mon, 14 May 2007, Peter Zijlstra wrote:
> 
> > > Hmmm.. Maybe we could do that.... But what I had in mind was simply to 
> > > set a page flag (DebugSlab()) if you know in alloc_slab that the slab 
> > > should be only used for emergency allocation. If DebugSlab is set then the
> > > fastpath will not be called. You can trap all allocation attempts and 
> > > insert whatever fancy logic you want in the debug path since its not 
> > > performance critical.
> > 
> > I might have missed some detail when I looked at SLUB, but I did not see
> > how setting SlabDebug would trap subsequent allocations to that slab.
> 
> Ok its not evident in slab_alloc. But if SlabDebug is set then 
> page->lockless_list is always NULL and we always fall back to 
> __slab_alloc.

Ah, indeed, that is the detail I missed. Yes that would work out.

>  There we check for SlabDebug and go to the debug: label. 
> There you can insert any fancy processing you want.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
