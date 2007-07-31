Date: Tue, 31 Jul 2007 16:40:18 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc] balance-on-fork NUMA placement
In-Reply-To: <200707311114.09284.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0707311639450.31337@schroedinger.engr.sgi.com>
References: <20070731054142.GB11306@wotan.suse.de> <200707311114.09284.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Jul 2007, Andi Kleen wrote:

> On Tuesday 31 July 2007 07:41, Nick Piggin wrote:
> 
> > I haven't given this idea testing yet, but I just wanted to get some
> > opinions on it first. NUMA placement still isn't ideal (eg. tasks with
> > a memory policy will not do any placement, and process migrations of
> > course will leave the memory behind...), but it does give a bit more
> > chance for the memory controllers and interconnects to get evenly
> > loaded.
> 
> I didn't think slab honored mempolicies by default? 
> At least you seem to need to set special process flags.

It does in the sense that slabs are allocated following policies. If you 
want to place individual objects then you need to use kmalloc_node().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
