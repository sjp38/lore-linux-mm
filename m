Date: Tue, 21 Nov 2006 11:49:01 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC 1/7] Remove declaration of sighand_cachep from slab.h
Message-Id: <20061121114901.54a36e4b.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0611211133300.30133@schroedinger.engr.sgi.com>
References: <20061118054342.8884.12804.sendpatchset@schroedinger.engr.sgi.com>
	<20061118054347.8884.36259.sendpatchset@schroedinger.engr.sgi.com>
	<20061118172739.30538d16.sfr@canb.auug.org.au>
	<Pine.LNX.4.64.0611200817020.16173@schroedinger.engr.sgi.com>
	<20061121000743.bb9ea2d0.akpm@osdl.org>
	<Pine.LNX.4.64.0611211133300.30133@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Nov 2006 11:36:19 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Tue, 21 Nov 2006, Andrew Morton wrote:
> 
> > Use `struct kmem_cache' instead of `kmem_cache_t' and lo, you can
> > forward-declare it in the header file without having to include slab.h.
> > 
> > Patches which rid us of kmem_cache_t are always welcome..
> 
> Ok. So this patch would be acceptable?
> 
> 
> Remore kmem_cache_t from mm.
> 
> This patch removed all uses of kmem_cache_t from the code in mm/*.
> The typedef is replaced with a define to allow other code to compile.
> 

spose so, although I wouldn't bother about the typedef->#define change.  
We just keep on plugging away at it until one day we can just remove the typedef.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
