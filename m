Date: Sat, 17 Aug 2002 13:21:53 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: VM Regress 0.5 - Compile error with CONFIG_HIGHMEM
Message-ID: <20020817132153.A11758@infradead.org>
References: <Pine.LNX.4.44.0208150312220.20123-100000@skynet> <Pine.LNX.4.44.0208171206200.7887-100000@skynet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0208171206200.7887-100000@skynet>; from mel@csn.ul.ie on Sat, Aug 17, 2002 at 12:09:20PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 17, 2002 at 12:09:20PM +0100, Mel wrote:
> On Thu, 15 Aug 2002, Mel wrote:
> 
> >
> > Project page: http://www.csn.ul.ie/~mel/projects/vmregress/
> > Download:     http://www.csn.ul.ie/~mel/projects/vmregress/vmregress-0.5.tar.gz
> 
> 0.5 won't compile with CONFIG_HIGHMEM set. Apply the following trivial
> patch and it will compile at least. VM Regress has not been tested with
> CONFIG_HIGHMEM set at all but there is no reason for it to fail because no
> presumptions has been made about the number of nodes or zones in the
> machine
> 
> 
> --- vmregress-0.5/src/sense/kvirtual.c	Tue Aug 13 22:43:48 2002
> +++ vmregress-0.5-highmem/src/sense/kvirtual.c	Sat Aug 17 12:03:02 2002
> @@ -29,6 +29,11 @@
>  #include <linux/mm.h>
>  #include <linux/sched.h>
> 
> +#ifdef CONFIG_HIGHMEM
> +#include <linux/highmem.h>
> +#include <asm/highmem.h>
> +#endif

Shouldn't an undonditional #include <linux/highmem.h> do it much cleaner?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
