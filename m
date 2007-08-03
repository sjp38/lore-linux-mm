Date: Thu, 2 Aug 2007 18:02:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc] balance-on-fork NUMA placement
In-Reply-To: <20070803005700.GD14775@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0708021801010.13312@schroedinger.engr.sgi.com>
References: <20070731054142.GB11306@wotan.suse.de> <200707311114.09284.ak@suse.de>
 <Pine.LNX.4.64.0707311639450.31337@schroedinger.engr.sgi.com>
 <20070802034201.GA32631@wotan.suse.de> <Pine.LNX.4.64.0708021254160.8527@schroedinger.engr.sgi.com>
 <20070803002639.GC14775@wotan.suse.de> <Pine.LNX.4.64.0708021748110.13312@schroedinger.engr.sgi.com>
 <20070803005700.GD14775@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 3 Aug 2007, Nick Piggin wrote:

> > Ok. So MPOL_BIND on a single node. We would have to save the current 
> > memory policy on the stack and then restore it later. Then you would need 
> > a special call anyways.
> 
> Well the memory policy will already be set to MPOL_BIND at this point.
> The slab allocator I think would just have to honour the node at the
> object level.

Who set the policy? The parent process may have its own memory policy. If 
you set that then the earlier policy is lost.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
