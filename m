Date: Tue, 14 Aug 2007 12:56:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/4] Embed zone_id information within the zonelist->zones
 pointer
In-Reply-To: <20070814002635.GR3406@bingen.suse.de>
Message-ID: <Pine.LNX.4.64.0708141255340.30766@schroedinger.engr.sgi.com>
References: <20070813225841.GG3406@bingen.suse.de>
 <Pine.LNX.4.64.0708131506030.28502@schroedinger.engr.sgi.com>
 <20070813230801.GH3406@bingen.suse.de> <Pine.LNX.4.64.0708131536340.29946@schroedinger.engr.sgi.com>
 <20070813234322.GJ3406@bingen.suse.de> <Pine.LNX.4.64.0708131553050.30626@schroedinger.engr.sgi.com>
 <20070814000041.GL3406@bingen.suse.de> <Pine.LNX.4.64.0708131614270.19910@schroedinger.engr.sgi.com>
 <20070814001659.GP3406@bingen.suse.de> <Pine.LNX.4.64.0708131625320.19910@schroedinger.engr.sgi.com>
 <20070814002635.GR3406@bingen.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Mel Gorman <mel@skynet.ie>, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 14 Aug 2007, Andi Kleen wrote:

> > pci_set_consistent_dma_mask
> > 
> > has that.
> 
> While on x86 it is roughly identical (although the low level
> allocator is currently not very reliable) it makes a significant
> difference on some platforms. e.g. I was told on PA-RISC
> consistent memory is much more costly than non consistent ones.
> That's probably true on anything that's not full IO cache
> consistent.
> 
> So while it would be reasonable semantics for x86 and IA64
> it's not for everybody else.

Right. That is the point of the function. It isolates these strange 
platform dependencies. That is why there is no need for ZONE_DMA32 on any 
other platform.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
