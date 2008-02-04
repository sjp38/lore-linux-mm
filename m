Date: Mon, 4 Feb 2008 11:09:01 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v5
In-Reply-To: <20080203021704.GC7185@v2.random>
Message-ID: <Pine.LNX.4.64.0802041106370.9656@schroedinger.engr.sgi.com>
References: <20080131045750.855008281@sgi.com> <20080131171806.GN7185@v2.random>
 <Pine.LNX.4.64.0801311207540.25477@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0801311508080.23624@schroedinger.engr.sgi.com>
 <20080131234101.GS7185@v2.random> <Pine.LNX.4.64.0801311738570.24297@schroedinger.engr.sgi.com>
 <20080201120955.GX7185@v2.random> <Pine.LNX.4.64.0802011118060.18163@schroedinger.engr.sgi.com>
 <20080203021704.GC7185@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Sun, 3 Feb 2008, Andrea Arcangeli wrote:

> > Right but that pin requires taking a refcount which we cannot do.
> 
> GRU can use my patch without the pin. XPMEM obviously can't use my
> patch as my invalidate_page[s] are under the PT lock (a feature to fit
> GRU/KVM in the simplest way), this is why an incremental patch adding
> invalidate_range_start/end would be required to support XPMEM too.

Doesnt the kernel in some situations release the page before releasing the 
pte lock? Then there will be an external pte pointing to a page that may 
now have a different use. Its really bad if that pte does allow writes.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
