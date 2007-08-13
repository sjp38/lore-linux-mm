Date: Mon, 13 Aug 2007 16:25:23 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/4] Embed zone_id information within the zonelist->zones
 pointer
In-Reply-To: <20070814001624.GO3406@bingen.suse.de>
Message-ID: <Pine.LNX.4.64.0708131622380.19910@schroedinger.engr.sgi.com>
References: <20070813225020.GE3406@bingen.suse.de>
 <Pine.LNX.4.64.0708131457190.28445@schroedinger.engr.sgi.com>
 <20070813225841.GG3406@bingen.suse.de> <Pine.LNX.4.64.0708131506030.28502@schroedinger.engr.sgi.com>
 <20070813230801.GH3406@bingen.suse.de> <Pine.LNX.4.64.0708131518320.28626@schroedinger.engr.sgi.com>
 <20070813234217.GI3406@bingen.suse.de> <Pine.LNX.4.64.0708131550100.30626@schroedinger.engr.sgi.com>
 <20070813235518.GK3406@bingen.suse.de> <Pine.LNX.4.64.0708131611001.19910@schroedinger.engr.sgi.com>
 <20070814001624.GO3406@bingen.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Mel Gorman <mel@skynet.ie>, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 14 Aug 2007, Andi Kleen wrote:

> > But they use GFP_DMA right now and drivers cannot use DMA32 if they want 
> 
> The way it was originally designed was that they use GFP_DMA32,
> which would map to itself on x86-64, to GFP_DMA on ia64 and to
> GFP_KERNEL on i386. Unfortunately that seems to have bitrotted
> (perhaps I should have better documented it) 

The DMA boundaries are hardware depending. A 4GB boundary 
may not make sense on certain platforms. 

> > to be cross platforms compatible? Doesnt the dma API completely do away 
> > with these things?
> 
> No GFP_DMA32 in my current plan is still there.

AFAIK GFP_DMA32 is a x86_64 special that would be easy to remove. Dealing 
with physical boundaries is current done via the dma interface right? Lets 
keep it there?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
