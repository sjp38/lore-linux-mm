Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 6DB4F6B005C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 21:50:31 -0500 (EST)
Date: Wed, 6 Feb 2013 11:50:28 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] zsmalloc: Add Kconfig for enabling PTE method
Message-ID: <20130206025028.GH11197@blaptop>
References: <1360117028-5625-1-git-send-email-minchan@kernel.org>
 <20130206022854.GA1681@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130206022854.GA1681@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>

On Tue, Feb 05, 2013 at 06:28:54PM -0800, Greg Kroah-Hartman wrote:
> On Wed, Feb 06, 2013 at 11:17:08AM +0900, Minchan Kim wrote:
> > diff --git a/drivers/staging/zsmalloc/Kconfig b/drivers/staging/zsmalloc/Kconfig
> > index 9084565..232b3b6 100644
> > --- a/drivers/staging/zsmalloc/Kconfig
> > +++ b/drivers/staging/zsmalloc/Kconfig
> > @@ -8,3 +8,15 @@ config ZSMALLOC
> >  	  non-standard allocator interface where a handle, not a pointer, is
> >  	  returned by an alloc().  This handle must be mapped in order to
> >  	  access the allocated space.
> > +
> > +config PGTABLE_MAPPING
> > +        bool "Use page table mapping to access allocations that span two pages"
> 
> No tabs?
> 
> Please also put "ZSmalloc somewhere in the text here, otherwise it
> really doesn't make much sense when seeing it in a menu.
> 
> > +        depends on ZSMALLOC
> > +        default n
> 
> That's the default, so it can be dropped.
> 
> > +        help
> > +	  By default, zsmalloc uses a copy-based object mapping method to access
> > +	  allocations that span two pages. However, if a particular architecture
> > +	  performs VM mapping faster than copying, then you should select this.
> > +	  This causes zsmalloc to use page table mapping rather than copying
> > +	  for object mapping. You can check speed with zsmalloc benchmark[1].
> > +	  [1] https://github.com/spartacus06/zsmalloc
> 
> Care to specify exactly _what_ architectures this should be set for or
> not?  That will help the distros out a lot in determining if this should
> be enabled or not.
> 
> > diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
> > index 06f73a9..2c1805c 100644
> > --- a/drivers/staging/zsmalloc/zsmalloc-main.c
> > +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
> > @@ -207,6 +207,7 @@ struct zs_pool {
> >  	struct size_class size_class[ZS_SIZE_CLASSES];
> >  
> >  	gfp_t flags;	/* allocation flags used when growing pool */
> > +
> >  };
> >  
> >  /*
> 
> Why add this extra line?
> 
> thanks,
> 
> greg k-h

Sorry for bothering you.
I fixed all you pointed out.
Thanks for the review, Greg!

Here it goes.

------------------- 8< -------------------
