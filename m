Date: Mon, 10 Mar 2008 10:14:43 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] [0/13] General DMA zone rework
In-Reply-To: <20080308115703.GD27074@one.firstfloor.org>
Message-ID: <Pine.LNX.4.64.0803101014070.24069@schroedinger.engr.sgi.com>
References: <200803071007.493903088@firstfloor.org>
 <Pine.LNX.4.64.0803071841020.12220@schroedinger.engr.sgi.com>
 <20080308115703.GD27074@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 8 Mar 2008, Andi Kleen wrote:

> I'm afraid it would not help you directly because you would still need 
> to maintain that code for s390 (seems to be a heavy GFP_DMA user)
> and probably some other architectures (unless you can get these
> maintainers to get rid of GFP_DMA too) With my plan it can be just ifdefed
> and the ifdef not enabled on x86.

Undefining ZONE_DMA will remove support for GFP_DMA from the slab 
allocators. Your patch is already doing that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
