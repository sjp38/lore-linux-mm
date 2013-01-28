Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id B969A6B0007
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 18:33:32 -0500 (EST)
Date: Tue, 29 Jan 2013 08:33:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/4] staging: zsmalloc: add gfp flags to zs_create_pool
Message-ID: <20130128233330.GA4752@blaptop>
References: <1359135978-15119-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1359135978-15119-2-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130128033944.GB3321@blaptop>
 <20130128151637.GC4838@konrad-lan.dumpdata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130128151637.GC4838@konrad-lan.dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Mon, Jan 28, 2013 at 10:16:38AM -0500, Konrad Rzeszutek Wilk wrote:
> On Mon, Jan 28, 2013 at 12:39:44PM +0900, Minchan Kim wrote:
> > Hi Seth,
> > 
> > On Fri, Jan 25, 2013 at 11:46:15AM -0600, Seth Jennings wrote:
> > > zs_create_pool() currently takes a gfp flags argument
> > > that is used when growing the memory pool.  However
> > > it is not used in allocating the metadata for the pool
> > > itself.  That is currently hardcoded to GFP_KERNEL.
> > > 
> > > zswap calls zs_create_pool() at swapon time which is done
> > > in atomic context, resulting in a "might sleep" warning.
> > > 
> > > This patch changes the meaning of the flags argument in
> > > zs_create_pool() to mean the flags for the metadata allocation,
> > > and adds a flags argument to zs_malloc that will be used for
> > > memory pool growth if required.
> > 
> > As I mentioned, I'm not strongly against with this patch but it
> > should be last resort in case of not being able to address
> > frontswap's init routine's dependency with swap_lock.
> > 
> > I sent a patch and am waiting reply of Konrand or Dan.
> > If we can fix frontswap, it would be better rather than
> > changing zsmalloc.
> 
> Could you point me to the subject/title of it please? Thanks.

I am very happy if you review it.

https://lkml.org/lkml/2013/1/27/262

Thanks.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
