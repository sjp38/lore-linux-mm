Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 15 Dec 2008 09:03:24 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [rfc][patch] SLQB slab allocator
In-Reply-To: <20081215141647.GC30163@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0812150902210.20082@quilx.com>
References: <20081212002518.GH8294@wotan.suse.de> <Pine.LNX.4.64.0812122013390.15781@quilx.com>
 <20081214230407.GB7318@wotan.suse.de> <Pine.LNX.4.64.0812150758020.16821@quilx.com>
 <20081215141647.GC30163@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, bcrl@kvack.org, list-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 Dec 2008, Nick Piggin wrote:

> > A memoryless node is a case where all allocations will be like that.
>
> Yes. Can the memoryless node revert to a default (closest) memory node?

It should do that but the node we allocat from will still be not the
local node. The local_node will only have processors. No memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
