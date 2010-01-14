Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 279B46B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 10:01:39 -0500 (EST)
Date: Thu, 14 Jan 2010 09:01:33 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
In-Reply-To: <20100114005304.GC27766@ldl.fc.hp.com>
Message-ID: <alpine.DEB.2.00.1001140858460.14164@router.home>
References: <20100113002923.GF2985@ldl.fc.hp.com> <alpine.DEB.2.00.1001130851310.24496@router.home> <20100114005304.GC27766@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alex Chiang <achiang@hp.com>
Cc: penberg@cs.helsinki.fi, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Jan 2010, Alex Chiang wrote:

> Firmware puts each cell into a NUMA node, so we should really
> only have 2 nodes, but for some reason, that 3rd node gets
> created too. I haven't inspected the SRAT/SLIT on this machine
> recently, but can do so if you want me to.

May not have anything to do with the problem we are looking at but memory
setup is screwed up. Funky effects may follow.

> > Maybe we miscalculated the number of DMA caches needed.
> > Does this patch fix it?
>
> Nope, same oops.

Duh. Have to look at this in more detail.

> ACPI: SLIT table looks invalid. Not used.
> Number of logical nodes in system = 3
> Number of memory chunks in system = 5

SLIT table just contain the distances if I remember correctly. The memory
maps are separate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
