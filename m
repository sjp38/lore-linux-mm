Subject: Re: 2.6.26: x86/kernel/pci_dma.c: gfp |= __GFP_NORETRY ?
From: Miquel van Smoorenburg <miquels@cistron.nl>
In-Reply-To: <1211484343.30678.15.camel@localhost.localdomain>
References: <20080521113028.GA24632@xs4all.net>
	 <48341A57.1030505@redhat.com>  <20080522084736.GC31727@one.firstfloor.org>
	 <1211484343.30678.15.camel@localhost.localdomain>
Content-Type: text/plain
Date: Sat, 24 May 2008 21:38:18 +0200
Message-Id: <1211657898.25661.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Glauber Costa <gcosta@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi-suse@firstfloor.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-05-22 at 21:25 +0200, Miquel van Smoorenburg wrote:
> Most drivers call pci_alloc_consistent() which calls
> dma_alloc_coherent(.... GFP_ATOMIC) which can dip deep into reserves so
> it won't fail so easily. Just a handful use dma_alloc_coherent()
> directly.
> 
> However, in 2.6.26-rc1, dpt_i2o.c was updated for 64 bit support, and
> all it's kmalloc(.... GFP_KERNEL) + virt_to_bus() calls have been
> replaced by dma_alloc_coherent(.... GFP_KERNEL).
> 
> In that case, it's not a very good idea to add __GFP_NORETRY.
>
> I think we should do something. How about one of these two patches.

And Andi wrote:

On Fri, 2008-05-23 at 00:59 +0200, Andi Kleen wrote:
> Anyways the reasoning is still valid. Longer term the mask allocator
> would be the right fix, shorter term a new GFP flag as proposed 
> sounds reasonable.

So how about linux-2.6.26-gfp-no-oom.patch (see previous mail) for
2.6.26 ?

Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
