Subject: Re: [PATCH] nommu: Push kobjsize() slab-specific logic down to
	ksize().
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <Pine.LNX.4.64.0805201149270.10868@schroedinger.engr.sgi.com>
References: <20080520095935.GB18633@linux-sh.org>
	 <2373.1211296724@redhat.com>
	 <Pine.LNX.4.64.0805200944210.6135@schroedinger.engr.sgi.com>
	 <1211307820.18026.190.camel@calx>
	 <Pine.LNX.4.64.0805201149270.10868@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 20 May 2008 14:00:23 -0500
Message-Id: <1211310023.18026.210.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: David Howells <dhowells@redhat.com>, Paul Mundt <lethal@linux-sh.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-05-20 at 11:51 -0700, Christoph Lameter wrote:
> On Tue, 20 May 2008, Matt Mackall wrote:
> 
> > > Hmm. That means we are sanctioning using ksize on arbitrary objects? SLUB 
> > > supports that but SLAB wont and neither will SLOB. I think we need to stay 
> > > with the strict definition that is needed by SLOB.
> > 
> > Of course SLUB won't be able to tell you the size of objects allocated
> > statically, through bootmem, etc.
> 
> Right the function actually give misleading results even if you just pass 
> a pointer to an int at an address that is page backed but not using a slab 
> allocator. Then PAGE_SIZE will be returned?
> 
> So the semantics are screwed up here. kobjsize() should only be called for 
> slab objects. 
> 
> Remove kobjsize completely and replace with calls to ksize? Callers must 
> not call ksize() on non slab objects.

What'd you think of my idea of adding WARN_ONs to SLAB and SLUB for
these cases? That is, warn whenever ksize() gets a non-kmalloced
address?

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
