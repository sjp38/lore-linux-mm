Date: Mon, 10 Mar 2008 10:13:49 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] [8/13] Enable the mask allocator for x86
In-Reply-To: <20080308115408.GC27074@one.firstfloor.org>
Message-ID: <Pine.LNX.4.64.0803101011530.24069@schroedinger.engr.sgi.com>
References: <200803071007.493903088@firstfloor.org>
 <20080307090718.A609E1B419C@basil.firstfloor.org>
 <Pine.LNX.4.64.0803071832500.12220@schroedinger.engr.sgi.com>
 <20080308115408.GC27074@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 8 Mar 2008, Andi Kleen wrote:

> What sparsemem reference do you mean?

Its just the use of MAX_DMA_ADDRESS in mm/sparse-vmemmap.c

> But the ZONE_DMA32 actually makes sense, but changing the semantics
> under such a large driver base isn't a good idea. 

The driver base can only be the x86_64 only device drivers since the zone 
is not used by any other architectures. That is fairly small AFAICT.

> It depends on the requirements of the bootmem user.  Some do need
> memory <4GB, some do not. The mask allocator itself is a client in fact
> and it requires low memory of course.

The point is that it would be good to relocate as much memory allocated at 
boot as possible beyond 4GB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
