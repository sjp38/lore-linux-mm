Message-Id: <200309092157.h89Lvkm31595@mail.osdl.org>
Subject: Re: 2.6.0-test5-mm1 
In-Reply-To: Message from Joshua Kwan <joshk@triplehelix.org>
   of "Tue, 09 Sep 2003 00:02:13 PDT." <20030909070213.GF7314@triplehelix.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Date: Tue, 09 Sep 2003 14:57:46 -0700
From: Cliff White <cliffw@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: joshk@triplehelix.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

OSDL's STP saw this problem, no tests ran on 2.6.0-test5-mm1

We've added this patch (PLM #2112) and are running tests now.
cliffw


> On Mon, Sep 08, 2003 at 11:50:28PM -0700, Andrew Morton wrote:
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test5/2.6.0-test5-mm1/
> 
> Needs the following patch to compile:
> 
> --- mm/slab.c~	2003-09-08 23:58:31.000000000 -0700
> +++ mm/slab.c	2003-09-08 23:58:33.000000000 -0700
> @@ -2794,11 +2794,13 @@
>  		} else {
>  			kernel_map_pages(virt_to_page(objp), c->objsize/PAGE_SIZE, 1);
>  
> +#if DEBUG
>  			if (c->flags & SLAB_RED_ZONE)
>  				printk("redzone: 0x%lx/0x%lx.\n", *dbg_redzone1(c, objp), *dbg_redzone2(c, objp));
>  
>  			if (c->flags & SLAB_STORE_USER)
>  				printk("Last user: %p.\n", *dbg_userword(c, objp));
> +#endif
>  		}
>  		spin_unlock_irqrestore(&c->spinlock, flags);
>  
> -- 
> Joshua Kwan


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
