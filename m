Date: Fri, 17 Dec 2004 11:26:49 -0800 (PST)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [patch] CONFIG_ARCH_HAS_ATOMIC_UNSIGNED
In-Reply-To: <20041217163308.GE14229@wotan.suse.de>
Message-ID: <Pine.LNX.4.58.0412171118430.20902@server.graphe.net>
References: <E1Cf6EG-00015y-00@kernel.beaverton.ibm.com>
 <20041217061150.GF12049@wotan.suse.de> <Pine.LNX.4.58.0412170827280.17806@server.graphe.net>
 <20041217163308.GE14229@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Dec 2004, Andi Kleen wrote:

> > Put the order of the page there for compound pages instead of having that
> > in index?
>
> That would waste memory on the 64bit architectures that cannot tolerate
> 32bit atomic flags or on true 32bit architecture.

Would be great to have 64 bit atomic support to fill this hole then.

> Also what's the problem of having it in index?

It implies that huge pages cannot be handled in the same way as regular
pages. F.e. if huge pages should ever be able to map files then huge
pages will also need page->index. Maybe its best to encode the order in
a 64 bit page flags on 64 bit machines? It will be zero in most cases and
one could then simply check for having a hugepage and get to the first page
without a pointer if the huge pages are properly aligned in their address
space.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
