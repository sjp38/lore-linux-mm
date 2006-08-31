Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7VHvlhC022590
	for <linux-mm@kvack.org>; Thu, 31 Aug 2006 13:57:47 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7VHvlVU294994
	for <linux-mm@kvack.org>; Thu, 31 Aug 2006 13:57:47 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7VHvloa007826
	for <linux-mm@kvack.org>; Thu, 31 Aug 2006 13:57:47 -0400
Subject: Re: [RFC][PATCH 3/9] actual generic PAGE_SIZE infrastructure
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0608301658130.5789@schroedinger.engr.sgi.com>
References: <20060830221604.E7320C0F@localhost.localdomain>
	 <20060830221606.40937644@localhost.localdomain>
	 <Pine.LNX.4.64.0608301658130.5789@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 31 Aug 2006 10:57:38 -0700
Message-Id: <1157047058.31295.28.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2006-08-30 at 17:08 -0700, Christoph Lameter wrote:
> On Wed, 30 Aug 2006, Dave Hansen wrote:
> 
> >  #endif	/* CONFIG_ARCH_HAVE_GET_ORDER */
> > -#endif /*  __ASSEMBLY__ */
> > +#endif  /* __ASSEMBLY__ */
>          ^^^ Extra blank.

OK.  I'll fix that.

> > +	prompt "Kernel Page Size"
> 	               page size?

Sure.

> > +	  This lets you select the page size of the kernel.  For best
> > +	  32-bit compatibility on 64-bit architectures, a page size of 4KB
> > +	  should be selected (although most binaries work perfectly fine with
> > +	  a larger page size).  For best performance, a page size of larger
> > +	  than 4KB is recommended.  However, there are a number of
> > +	  side-effects of larger page sizes, like small files fitting poorly
> > +	  into the page cache.
> 
> Could we change this somewhat? Avoid the direct address and maybe say:
> 
>  The kernel page size determines the basic chunk of memory handled
>  by the Linux VM. The bigger the page size the less page objects
>  have to be managed by the kernel which reduces the VM overhead in
>  handling large amounts of data. However, larger pages also lead
>  to memory being wasted by the kernel since small files will
>  at mininum require one page of memory. A 4K pagesize is fairly standard 
>  and may be required for 32 bit compatibility on many platforms.
> 
>  It is usually not wise to select another page size than the default
>  unless one knows what one is doing or has some time to spend on
>  getting to know the kernel.

This is very nice.  I'll incorporate it.  

> Note that the default pagesize on IA64 is 16K and some important things 
> would change if a lesser size is selected. I have never run a 4K kernel. 
> I do not think we can just say that 4KB is okay. There may be other 
> platforms that have other default page sizes.

If we can't just say that it is OK, then we should probably disable it
in Kconfig.  Should we do that?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
