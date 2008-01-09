Date: Wed, 9 Jan 2008 13:54:59 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: mmu notifiers
In-Reply-To: <20080109181908.GS6958@v2.random>
Message-ID: <Pine.LNX.4.64.0801091352320.12335@schroedinger.engr.sgi.com>
References: <20080109181908.GS6958@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: kvm-devel@lists.sourceforge.net, linux-mm@kvack.org, Daniel J Blueman <daniel.blueman@quadrics.com>
List-ID: <linux-mm.kvack.org>

On Wed, 9 Jan 2008, Andrea Arcangeli wrote:

> This patch is a first basic implementation of the mmu notifiers. More
> methods can be added in the future.
> 
> In short when the linux VM decides to free a page, it will unmap it
> from the linux pagetables. However when a page is mapped not just by
> the regular linux ptes, but also from the shadow pagetables, it's
> currently unfreeable by the linux VM.

Such a patch would also address issues that SGI has with exporting 
mappings via XPMEM. Plus a variety of other uses. Go ahead and lets do 
more in this area.

Are the KVM folks interested in exporting memory from one guest to 
another? That may also become possible with some of the work that we have 
in progress and that also requires a patch like this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
